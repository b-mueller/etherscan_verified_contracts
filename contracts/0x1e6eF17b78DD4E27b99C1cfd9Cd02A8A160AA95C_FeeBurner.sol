pragma solidity 0.4.18;

interface FeeBurnerInterface {
    function handleFees (uint tradeWeiAmount, address reserve, address wallet) public returns(bool);
}

contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address=&gt;bool) internal operators;
    mapping(address=&gt;bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint constant internal MAX_GROUP_SIZE = 50;

    function PermissionGroups() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {
        require(alerters[msg.sender]);
        _;
    }

    function getOperators () external view returns(address[]) {
        return operatorsGroup;
    }

    function getAlerters () external view returns(address[]) {
        return alertersGroup;
    }

    event TransferAdminPending(address pendingAdmin);

    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(pendingAdmin);
        pendingAdmin = newAdmin;
    }

    /**
     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(newAdmin);
        AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender);
        AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event AlerterAdded (address newAlerter, bool isAdd);

    function addAlerter(address newAlerter) public onlyAdmin {
        require(!alerters[newAlerter]); // prevent duplicates.
        require(alertersGroup.length &lt; MAX_GROUP_SIZE);

        AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function removeAlerter (address alerter) public onlyAdmin {
        require(alerters[alerter]);
        alerters[alerter] = false;

        for (uint i = 0; i &lt; alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.length--;
                AlerterAdded(alerter, false);
                break;
            }
        }
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator]); // prevent duplicates.
        require(operatorsGroup.length &lt; MAX_GROUP_SIZE);

        OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator (address operator) public onlyAdmin {
        require(operators[operator]);
        operators[operator] = false;

        for (uint i = 0; i &lt; operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.length -= 1;
                OperatorAdded(operator, false);
                break;
            }
        }
    }
}

contract Utils {

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint  constant internal PRECISION = (10**18);
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint  constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint  constant internal MAX_DECIMALS = 18;
    uint  constant internal ETH_DECIMALS = 18;
    mapping(address=&gt;uint) internal decimals;

    function setDecimals(ERC20 token) internal {
        if (token == ETH_TOKEN_ADDRESS) decimals[token] = ETH_DECIMALS;
        else decimals[token] = token.decimals();
    }

    function getDecimals(ERC20 token) internal view returns(uint) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint tokenDecimals = decimals[token];
        // technically, there might be token with decimals 0
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        if(tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(srcQty &lt;= MAX_QTY);
        require(rate &lt;= MAX_RATE);

        if (dstDecimals &gt;= srcDecimals) {
            require((dstDecimals - srcDecimals) &lt;= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) &lt;= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(dstQty &lt;= MAX_QTY);
        require(rate &lt;= MAX_RATE);

        //source quantity is rounded up. to avoid dest quantity being too low.
        uint numerator;
        uint denominator;
        if (srcDecimals &gt;= dstDecimals) {
            require((srcDecimals - dstDecimals) &lt;= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) &lt;= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }
}

contract Withdrawable is PermissionGroups {

    event TokenWithdraw(ERC20 token, uint amount, address sendTo);

    /**
     * @dev Withdraw all ERC20 compatible tokens
     * @param token ERC20 The address of the token contract
     */
    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
        require(token.transfer(sendTo, amount));
        TokenWithdraw(token, amount, sendTo);
    }

    event EtherWithdraw(uint amount, address sendTo);

    /**
     * @dev Withdraw Ethers
     */
    function withdrawEther(uint amount, address sendTo) external onlyAdmin {
        sendTo.transfer(amount);
        EtherWithdraw(amount, sendTo);
    }
}

interface BurnableToken {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function burnFrom(address _from, uint256 _value) public returns (bool);
}

contract FeeBurner is Withdrawable, FeeBurnerInterface, Utils {

    mapping(address=&gt;uint) public reserveFeesInBps;
    mapping(address=&gt;address) public reserveKNCWallet;
    mapping(address=&gt;uint) public walletFeesInBps;
    mapping(address=&gt;uint) public reserveFeeToBurn;
    mapping(address=&gt;mapping(address=&gt;uint)) public reserveFeeToWallet;

    BurnableToken public knc;
    address public kyberNetwork;
    uint public kncPerETHRate = 300;

    function FeeBurner(address _admin, BurnableToken kncToken) public {
        require(_admin != address(0));
        require(kncToken != address(0));
        admin = _admin;
        knc = kncToken;
    }

    function setReserveData(address reserve, uint feesInBps, address kncWallet) public onlyAdmin {
        require(feesInBps &lt; 100); // make sure it is always &lt; 1%
        require(kncWallet != address(0));
        reserveFeesInBps[reserve] = feesInBps;
        reserveKNCWallet[reserve] = kncWallet;
    }

    function setWalletFees(address wallet, uint feesInBps) public onlyAdmin {
        require(feesInBps &lt; 10000); // under 100%
        walletFeesInBps[wallet] = feesInBps;
    }

    function setKyberNetwork(address _kyberNetwork) public onlyAdmin {
        require(_kyberNetwork != address(0));
        kyberNetwork = _kyberNetwork;
    }

    function setKNCRate(uint rate) public onlyAdmin {
        require(kncPerETHRate &lt;= MAX_RATE);
        kncPerETHRate = rate;
    }

    event AssignFeeToWallet(address reserve, address wallet, uint walletFee);
    event AssignBurnFees(address reserve, uint burnFee);

    function handleFees(uint tradeWeiAmount, address reserve, address wallet) public returns(bool) {
        require(msg.sender == kyberNetwork);
        require(tradeWeiAmount &lt;= MAX_QTY);
        require(kncPerETHRate &lt;= MAX_RATE);

        uint kncAmount = tradeWeiAmount * kncPerETHRate;
        uint fee = kncAmount * reserveFeesInBps[reserve] / 10000;

        uint walletFee = fee * walletFeesInBps[wallet] / 10000;
        require(fee &gt;= walletFee);
        uint feeToBurn = fee - walletFee;

        if (walletFee &gt; 0) {
            reserveFeeToWallet[reserve][wallet] += walletFee;
            AssignFeeToWallet(reserve, wallet, walletFee);
        }

        if (feeToBurn &gt; 0) {
            AssignBurnFees(reserve, feeToBurn);
            reserveFeeToBurn[reserve] += feeToBurn;
        }

        return true;
    }

    // this function is callable by anyone
    event BurnAssignedFees(address indexed reserve, address sender);

    function burnReserveFees(address reserve) public {
        uint burnAmount = reserveFeeToBurn[reserve];
        require(burnAmount &gt; 1);
        reserveFeeToBurn[reserve] = 1; // leave 1 twei to avoid spikes in gas fee
        require(knc.burnFrom(reserveKNCWallet[reserve], burnAmount - 1));

        BurnAssignedFees(reserve, msg.sender);
    }

    event SendWalletFees(address indexed wallet, address reserve, address sender);

    // this function is callable by anyone
    function sendFeeToWallet(address wallet, address reserve) public {
        uint feeAmount = reserveFeeToWallet[reserve][wallet];
        require(feeAmount &gt; 1);
        reserveFeeToWallet[reserve][wallet] = 1; // leave 1 twei to avoid spikes in gas fee
        require(knc.transferFrom(reserveKNCWallet[reserve], wallet, feeAmount - 1));

        SendWalletFees(wallet, reserve, msg.sender);
    }
}

interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}