pragma solidity ^0.4.18;


/**
 * @title Global Mobile Industry Service Ecosystem Chain 
 * @dev Developed By Jack 5/14 2018 
 * @dev contact:<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d9b3b8bab2f7b2b6bc99beb4b8b0b5f7bab6b4">[email&#160;protected]</a>
 */

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b &lt;= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c &gt;= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function isOwner() internal view returns(bool success) {
        if (msg.sender == owner) return true;
        return false;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @title ERC20Basic
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address =&gt; uint256) balances;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[_from]);
        require(_value &lt;= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue &gt; oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract MSCE is Ownable, StandardToken {
    using SafeMath for uint256;

    uint8 public constant TOKEN_DECIMALS = 18;

    string public name = &quot;Mobile Ecosystem&quot;; 
    string public symbol = &quot;MSCE&quot;;
    uint8 public decimals = TOKEN_DECIMALS;


    uint256 public totalSupply = 500000000 *(10**uint256(TOKEN_DECIMALS)); 
    uint256 public soldSupply = 0; 
    uint256 public sellSupply = 0; 
    uint256 public buySupply = 0; 
    bool public stopSell = true;
    bool public stopBuy = true;

    uint256 public crowdsaleStartTime = block.timestamp;
    uint256 public crowdsaleEndTime = block.timestamp;

    uint256 public crowdsaleTotal = 0;


    uint256 public buyExchangeRate = 10000;   
    uint256 public sellExchangeRate = 60000;  
    address public ethFundDeposit;  


    bool public allowTransfers = true; 


    mapping (address =&gt; bool) public frozenAccount;

    bool public enableInternalLock = true; 
    mapping (address =&gt; bool) public internalLockAccount;

    mapping (address =&gt; uint256) public releaseLockAccount;


    event FrozenFunds(address target, bool frozen);
    event IncreaseSoldSaleSupply(uint256 _value);
    event DecreaseSoldSaleSupply(uint256 _value);

    function MSCE() public {


        balances[msg.sender] = totalSupply;             

        ethFundDeposit = msg.sender;                      
        allowTransfers = false;
    }

    function _isUserInternalLock() internal view returns (bool) {

        return getAccountLockState(msg.sender);

    }

    function increaseSoldSaleSupply (uint256 _value) onlyOwner public {
        require (_value + soldSupply &lt; totalSupply);
        soldSupply = soldSupply.add(_value);
        IncreaseSoldSaleSupply(_value);
    }

    function decreaseSoldSaleSupply (uint256 _value) onlyOwner public {
        require (soldSupply - _value &gt; 0);
        soldSupply = soldSupply.sub(_value);
        DecreaseSoldSaleSupply(_value);
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = balances[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    function destroyToken(address target, uint256 amount) onlyOwner public {
        balances[target] = balances[target].sub(amount);
        totalSupply = totalSupply.sub(amount);
        Transfer(target, this, amount);
        Transfer(this, 0, amount);
    }


    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }


    function setEthFundDeposit(address _ethFundDeposit) onlyOwner public {
        require(_ethFundDeposit != address(0));
        ethFundDeposit = _ethFundDeposit;
    }

    function transferETH() onlyOwner public {
        require(ethFundDeposit != address(0));
        require(this.balance != 0);
        require(ethFundDeposit.send(this.balance));
    }


    function setExchangeRate(uint256 _sellExchangeRate, uint256 _buyExchangeRate) onlyOwner public {
        sellExchangeRate = _sellExchangeRate;
        buyExchangeRate = _buyExchangeRate;
    }

    function setName(string _name) onlyOwner public {
        name = _name;
    }

    function setSymbol(string _symbol) onlyOwner public {
        symbol = _symbol;
    }

    function setAllowTransfers(bool _allowTransfers) onlyOwner public {
        allowTransfers = _allowTransfers;
    }

    function transferFromAdmin(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function setEnableInternalLock(bool _isEnable) onlyOwner public {
        enableInternalLock = _isEnable;
    }

    function lockInternalAccount(address _target, bool _lock, uint256 _releaseTime) onlyOwner public {
        require(_target != address(0));

        internalLockAccount[_target] = _lock;
        releaseLockAccount[_target] = _releaseTime;

    }

    function getAccountUnlockTime(address _target) public view returns(uint256) {

        return releaseLockAccount[_target];

    }
    function getAccountLockState(address _target) public view returns(bool) {
        if(enableInternalLock &amp;&amp; internalLockAccount[_target]){
            if((releaseLockAccount[_target] &gt; 0)&amp;&amp;(releaseLockAccount[_target]&lt;block.timestamp)){       
                return false;
            }          
            return true;
        }
        return false;

    }

    function internalSellTokenFromAdmin(address _to, uint256 _value, bool _lock, uint256 _releaseTime) onlyOwner public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[owner]);

        balances[owner] = balances[owner].sub(_value);
        balances[_to] = balances[_to].add(_value);
        soldSupply = soldSupply.add(_value);
        sellSupply = sellSupply.add(_value);

        Transfer(owner, _to, _value);
        
        lockInternalAccount(_to, _lock, _releaseTime);

        return true;
    }

    /***************************************************/
    /*              BASE Functions                     */
    /***************************************************/

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (!isOwner()) {
            require (allowTransfers);
            require(!frozenAccount[_from]);                                         
            require(!frozenAccount[_to]);                                        
            require(!_isUserInternalLock());                                       
        }
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        if (!isOwner()) {
            require (allowTransfers);
            require(!frozenAccount[msg.sender]);                                       
            require(!frozenAccount[_to]);                                             
            require(!_isUserInternalLock());                                           
        }
        return super.transfer(_to, _value);
    }

    function () internal payable{

        uint256 currentTime = block.timestamp;
        require((currentTime&gt;crowdsaleStartTime)&amp;&amp;(currentTime&lt;crowdsaleEndTime));
        require(crowdsaleTotal&gt;0);

        require(buy());

        crowdsaleTotal = crowdsaleTotal.sub(msg.value.mul(buyExchangeRate));

    }

    function buy() payable public returns (bool){


        uint256 amount = msg.value.mul(buyExchangeRate);

        require(!stopBuy);
        require(amount &lt;= balances[owner]);

        balances[owner] = balances[owner].sub(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);

        soldSupply = soldSupply.add(amount);
        buySupply = buySupply.add(amount);

        Transfer(owner, msg.sender, amount);
        return true;
    }

    function sell(uint256 amount) public {
        uint256 ethAmount = amount.div(sellExchangeRate);
        require(!stopSell);
        require(this.balance &gt;= ethAmount);      
        require(ethAmount &gt;= 1);      

        require(balances[msg.sender] &gt;= amount);                 
        require(balances[owner] + amount &gt; balances[owner]);       
        require(!frozenAccount[msg.sender]);                       
        require(!_isUserInternalLock());                                          

        balances[owner] = balances[owner].add(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);

        soldSupply = soldSupply.sub(amount);
        sellSupply = sellSupply.add(amount);

        Transfer(msg.sender, owner, amount);

        msg.sender.transfer(ethAmount); 
    }

    function setCrowdsaleStartTime(uint256 _crowdsaleStartTime) onlyOwner public {
        crowdsaleStartTime = _crowdsaleStartTime;
    }

    function setCrowdsaleEndTime(uint256 _crowdsaleEndTime) onlyOwner public {
        crowdsaleEndTime = _crowdsaleEndTime;
    }
   

    function setCrowdsaleTotal(uint256 _crowdsaleTotal) onlyOwner public {
        crowdsaleTotal = _crowdsaleTotal;
    }
}