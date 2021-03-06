pragma solidity 0.4.18;

// File: contracts/FeeBurnerInterface.sol

interface FeeBurnerInterface {
    function handleFees (uint tradeWeiAmount, address reserve, address wallet) public returns(bool);
}

// File: contracts/ERC20Interface.sol

// https://github.com/ethereum/EIPs/issues/20
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

// File: contracts/Utils.sol

/// @title Kyber constants contract
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

// File: contracts/PermissionGroups.sol

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

// File: contracts/Withdrawable.sol

/**
 * @title Contracts that should be able to recover tokens or ethers
 * @author Ilan Doron
 * @dev This allows to recover any tokens or Ethers received in a contract.
 * This will prevent any accidental loss of tokens.
 */
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

// File: contracts/FeeBurner.sol

interface BurnableToken {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function burnFrom(address _from, uint256 _value) public returns (bool);
}


contract FeeBurner is Withdrawable, FeeBurnerInterface, Utils {

    mapping(address=&gt;uint) public reserveFeesInBps;
    mapping(address=&gt;address) public reserveKNCWallet; //wallet holding knc per reserve. from here burn and send fees.
    mapping(address=&gt;uint) public walletFeesInBps; // wallet that is the source of tx is entitled so some fees.
    mapping(address=&gt;uint) public reserveFeeToBurn;
    mapping(address=&gt;uint) public feePayedPerReserve; // track burned fees and sent wallet fees per reserve.
    mapping(address=&gt;mapping(address=&gt;uint)) public reserveFeeToWallet;
    address public taxWallet;
    uint public taxFeeBps = 0; // burned fees are taxed. % out of burned fees.

    BurnableToken public knc;
    address public kyberNetwork;
    uint public kncPerETHRate = 300;

    function FeeBurner(address _admin, BurnableToken kncToken, address _kyberNetwork) public {
        require(_admin != address(0));
        require(kncToken != address(0));
        require(_kyberNetwork != address(0));
        kyberNetwork = _kyberNetwork;
        admin = _admin;
        knc = kncToken;
    }

    event ReserveDataSet(address reserve, uint feeInBps, address kncWallet);
    function setReserveData(address reserve, uint feesInBps, address kncWallet) public onlyAdmin {
        require(feesInBps &lt; 100); // make sure it is always &lt; 1%
        require(kncWallet != address(0));
        reserveFeesInBps[reserve] = feesInBps;
        reserveKNCWallet[reserve] = kncWallet;
        ReserveDataSet(reserve, feesInBps, kncWallet);
    }

    event WalletFeesSet(address wallet, uint feesInBps);
    function setWalletFees(address wallet, uint feesInBps) public onlyAdmin {
        require(feesInBps &lt; 10000); // under 100%
        walletFeesInBps[wallet] = feesInBps;
        WalletFeesSet(wallet, feesInBps);
    }

    event TaxFeesSet(uint feesInBps);
    function setTaxInBps(uint _taxFeeBps) public onlyAdmin {
        require(_taxFeeBps &lt; 10000); // under 100%
        taxFeeBps = _taxFeeBps;
        TaxFeesSet(_taxFeeBps);
    }

    event TaxWalletSet(address taxWallet);
    function setTaxWallet(address _taxWallet) public onlyAdmin {
        require(_taxWallet != address(0));
        taxWallet = _taxWallet;
        TaxWalletSet(_taxWallet);
    }

    function setKNCRate(uint rate) public onlyAdmin {
        require(rate &lt;= MAX_RATE);
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

    event BurnAssignedFees(address indexed reserve, address sender, uint quantity);

    event SendTaxFee(address indexed reserve, address sender, address taxWallet, uint quantity);

    // this function is callable by anyone
    function burnReserveFees(address reserve) public {
        uint burnAmount = reserveFeeToBurn[reserve];
        uint taxToSend = 0;
        require(burnAmount &gt; 2);
        reserveFeeToBurn[reserve] = 1; // leave 1 twei to avoid spikes in gas fee
        if (taxWallet != address(0) &amp;&amp; taxFeeBps != 0) {
            taxToSend = (burnAmount - 1) * taxFeeBps / 10000;
            require(burnAmount - 1 &gt; taxToSend);
            burnAmount -= taxToSend;
            if (taxToSend &gt; 0) {
                require(knc.transferFrom(reserveKNCWallet[reserve], taxWallet, taxToSend));
                SendTaxFee(reserve, msg.sender, taxWallet, taxToSend);
            }
        }
        require(knc.burnFrom(reserveKNCWallet[reserve], burnAmount - 1));

        //update reserve &quot;payments&quot; so far
        feePayedPerReserve[reserve] += (taxToSend + burnAmount - 1);

        BurnAssignedFees(reserve, msg.sender, (burnAmount - 1));
    }

    event SendWalletFees(address indexed wallet, address reserve, address sender);

    // this function is callable by anyone
    function sendFeeToWallet(address wallet, address reserve) public {
        uint feeAmount = reserveFeeToWallet[reserve][wallet];
        require(feeAmount &gt; 1);
        reserveFeeToWallet[reserve][wallet] = 1; // leave 1 twei to avoid spikes in gas fee
        require(knc.transferFrom(reserveKNCWallet[reserve], wallet, feeAmount - 1));

        feePayedPerReserve[reserve] += (feeAmount - 1);
        SendWalletFees(wallet, reserve, msg.sender);
    }
}

// File: contracts/wrapperContracts/WrapperBase.sol

contract WrapperBase is Withdrawable {

    PermissionGroups public wrappedContract;

    struct DataTracker {
        address[] approveSignatureArray;
        uint lastSetNonce;
    }

    DataTracker[] internal dataInstances;

    function WrapperBase(PermissionGroups _wrappedContract, address _admin, uint _numDataInstances) public
        Withdrawable()
    {
        require(_wrappedContract != address(0));
        require(_admin != address(0));
        wrappedContract = _wrappedContract;
        admin = _admin;

        for (uint i = 0; i &lt; _numDataInstances; i++){
            addDataInstance();
        }
    }

    function claimWrappedContractAdmin() public onlyOperator {
        wrappedContract.claimAdmin();
    }

    function transferWrappedContractAdmin (address newAdmin) public onlyAdmin {
        wrappedContract.transferAdmin(newAdmin);
    }

    function addDataInstance() internal {
        address[] memory add = new address[](0);
        dataInstances.push(DataTracker(add, 0));
    }

    function setNewData(uint dataIndex) internal {
        require(dataIndex &lt; dataInstances.length);
        dataInstances[dataIndex].lastSetNonce++;
        dataInstances[dataIndex].approveSignatureArray.length = 0;
    }

    function addSignature(uint dataIndex, uint signedNonce, address signer) internal returns(bool allSigned) {
        require(dataIndex &lt; dataInstances.length);
        require(dataInstances[dataIndex].lastSetNonce == signedNonce);

        for (uint i = 0; i &lt; dataInstances[dataIndex].approveSignatureArray.length; i++) {
            if (signer == dataInstances[dataIndex].approveSignatureArray[i]) revert();
        }
        dataInstances[dataIndex].approveSignatureArray.push(signer);

        if (dataInstances[dataIndex].approveSignatureArray.length == operatorsGroup.length) {
            allSigned = true;
        } else {
            allSigned = false;
        }
    }

    function getDataTrackingParameters(uint index) internal view returns (address[], uint) {
        require(index &lt; dataInstances.length);
        return(dataInstances[index].approveSignatureArray, dataInstances[index].lastSetNonce);
    }
}

// File: contracts/wrapperContracts/WrapFeeBurner.sol

contract WrapFeeBurner is WrapperBase {

    FeeBurner public feeBurnerContract;
    address[] internal feeSharingWallets;
    uint public feeSharingBps = 3000; // out of 10000 = 30%

    //knc rate range
    struct KncPerEth {
        uint minRate;
        uint maxRate;
        uint pendingMinRate;
        uint pendingMaxRate;
    }

    KncPerEth internal kncPerEth;

    //add reserve pending data
    struct AddReserveData {
        address reserve;
        uint    feeBps;
        address kncWallet;
    }

    AddReserveData internal addReserve;

    //wallet fee pending parameters
    struct WalletFee {
        address walletAddress;
        uint    feeBps;
    }

    WalletFee internal walletFee;

    //tax pending parameters
    struct TaxData {
        address wallet;
        uint    feeBps;
    }

    TaxData internal taxData;
    
    //data indexes
    uint internal constant KNC_RATE_RANGE_INDEX = 0;
    uint internal constant ADD_RESERVE_INDEX = 1;
    uint internal constant WALLET_FEE_INDEX = 2;
    uint internal constant TAX_DATA_INDEX = 3;
    uint internal constant LAST_DATA_INDEX = 4;

    //general functions
    function WrapFeeBurner(FeeBurner feeBurner, address _admin) public
        WrapperBase(PermissionGroups(address(feeBurner)), _admin, LAST_DATA_INDEX)
    {
        require(feeBurner != address(0));
        feeBurnerContract = feeBurner;
    }

    //register wallets for fee sharing
    /////////////////////////////////
    function setFeeSharingValue(uint feeBps) public onlyAdmin {
        require(feeBps &lt; 10000);
        feeSharingBps = feeBps;
    }

    function getFeeSharingWallets() public view returns(address[]) {
        return feeSharingWallets;
    }

    event WalletRegisteredForFeeSharing(address sender, address walletAddress);
    function registerWalletForFeeSharing(address walletAddress) public {
        require(feeBurnerContract.walletFeesInBps(walletAddress) == 0);

        // if fee sharing value is 0. means the wallet wasn&#39;t added.
        feeBurnerContract.setWalletFees(walletAddress, feeSharingBps);
        feeSharingWallets.push(walletAddress);
        WalletRegisteredForFeeSharing(msg.sender, walletAddress);
    }

    // knc rate handling
    //////////////////////
    function setPendingKNCRateRange(uint minRate, uint maxRate) public onlyOperator {
        require(minRate &lt; maxRate);
        require(minRate &gt; 0);

        //update data tracking
        setNewData(KNC_RATE_RANGE_INDEX);

        kncPerEth.pendingMinRate = minRate;
        kncPerEth.pendingMaxRate = maxRate;
    }

    function getPendingKNCRateRange() public view returns(uint minRate, uint maxRate, uint nonce) {
        address[] memory signatures;
        minRate = kncPerEth.pendingMinRate;
        maxRate = kncPerEth.pendingMaxRate;
        (signatures, nonce) = getDataTrackingParameters(KNC_RATE_RANGE_INDEX);

        return(minRate, maxRate, nonce);
    }

    function getKNCRateRangeSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(KNC_RATE_RANGE_INDEX);
        return(signatures);
    }

    function approveKNCRateRange(uint nonce) public onlyOperator {
        if (addSignature(KNC_RATE_RANGE_INDEX, nonce, msg.sender)) {
            // can perform operation.
            kncPerEth.minRate = kncPerEth.pendingMinRate;
            kncPerEth.maxRate = kncPerEth.pendingMaxRate;
        }
    }

    function getKNCRateRange() public view returns(uint minRate, uint maxRate) {
        minRate = kncPerEth.minRate;
        maxRate = kncPerEth.maxRate;
        return(minRate, maxRate);
    }

    ///@dev here the operator can set rate without other operators validation. It has to be inside range.
    function setKNCPerEthRate(uint kncPerEther) public onlyOperator {
        require(kncPerEther &gt;= kncPerEth.minRate);
        require(kncPerEther &lt;= kncPerEth.maxRate);
        feeBurnerContract.setKNCRate(kncPerEther);
    }

    //set reserve data
    //////////////////
    function setPendingReserveData(address reserve, uint feeBps, address kncWallet) public onlyOperator {
        require(reserve != address(0));
        require(kncWallet != address(0));
        require(feeBps &gt; 0);
        require(feeBps &lt; 10000);

        addReserve.reserve = reserve;
        addReserve.feeBps = feeBps;
        addReserve.kncWallet = kncWallet;
        setNewData(ADD_RESERVE_INDEX);
    }

    function getPendingAddReserveData() public view
        returns(address reserve, uint feeBps, address kncWallet, uint nonce)
    {
        address[] memory signatures;
        (signatures, nonce) = getDataTrackingParameters(ADD_RESERVE_INDEX);
        return(addReserve.reserve, addReserve.feeBps, addReserve.kncWallet, nonce);
    }

    function getAddReserveSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(ADD_RESERVE_INDEX);
        return(signatures);
    }

    function approveAddReserveData(uint nonce) public onlyOperator {
        if (addSignature(ADD_RESERVE_INDEX, nonce, msg.sender)) {
            // can perform operation.
            feeBurnerContract.setReserveData(addReserve.reserve, addReserve.feeBps, addReserve.kncWallet);
        }
    }

    //wallet fee
    /////////////
    function setPendingWalletFee(address wallet, uint feeBps) public onlyOperator {
        require(wallet != address(0));
        require(feeBps &gt; 0);
        require(feeBps &lt; 10000);

        walletFee.walletAddress = wallet;
        walletFee.feeBps = feeBps;
        setNewData(WALLET_FEE_INDEX);
    }

    function getPendingWalletFeeData() public view returns(address wallet, uint feeBps, uint nonce) {
        address[] memory signatures;
        (signatures, nonce) = getDataTrackingParameters(WALLET_FEE_INDEX);
        return(walletFee.walletAddress, walletFee.feeBps, nonce);
    }

    function getWalletFeeSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(WALLET_FEE_INDEX);
        return(signatures);
    }

    function approveWalletFeeData(uint nonce) public onlyOperator {
        if (addSignature(WALLET_FEE_INDEX, nonce, msg.sender)) {
            // can perform operation.
            feeBurnerContract.setWalletFees(walletFee.walletAddress, walletFee.feeBps);
        }
    }

    //tax parameters
    ////////////////
    function setPendingTaxParameters(address taxWallet, uint feeBps) public onlyOperator {
        require(taxWallet != address(0));
        require(feeBps &gt; 0);
        require(feeBps &lt; 10000);

        taxData.wallet = taxWallet;
        taxData.feeBps = feeBps;
        setNewData(TAX_DATA_INDEX);
    }

    function getPendingTaxData() public view returns(address wallet, uint feeBps, uint nonce) {
        address[] memory signatures;
        (signatures, nonce) = getDataTrackingParameters(TAX_DATA_INDEX);
        return(taxData.wallet, taxData.feeBps, nonce);
    }

    function getTaxDataSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(TAX_DATA_INDEX);
        return(signatures);
    }

    function approveTaxData(uint nonce) public onlyOperator {
        if (addSignature(TAX_DATA_INDEX, nonce, msg.sender)) {
            // can perform operation.
            feeBurnerContract.setTaxInBps(taxData.feeBps);
            feeBurnerContract.setTaxWallet(taxData.wallet);
        }
    }
}