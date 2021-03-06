pragma solidity ^0.4.18;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c &gt;= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of &quot;user permissions&quot;.
 */
contract Ownable {
    mapping(address =&gt; bool)  internal owners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public{
        owners[msg.sender] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address newAllowed) onlyOwner public {
        owners[newAllowed] = true;
    }

    function removeOwner(address toRemove) onlyOwner public {
        owners[toRemove] = false;
    }

    function isOwner() public view returns(bool){
        return owners[msg.sender] == true;
    }

}


contract FoxicoPool is Ownable {
  using SafeMath for uint256;

  mapping (address =&gt; uint256) public deposited;
  mapping (address =&gt; uint256) public claimed;


  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  bool public refundEnabled;

  event Refunded(address indexed beneficiary, uint256 weiAmount);
  event AddDeposit(address indexed beneficiary, uint256 value);

  function setStartTime(uint256 _startTime) public onlyOwner{
    startTime = _startTime;
  }

  function setEndTime(uint256 _endTime) public onlyOwner{
    endTime = _endTime;
  }

  function setWallet(address _wallet) public onlyOwner{
    wallet = _wallet;
  }

  function setRefundEnabled(bool _refundEnabled) public onlyOwner{
    refundEnabled = _refundEnabled;
  }

  function FoxicoPool(uint256 _startTime, uint256 _endTime, address _wallet) public {
    require(_startTime &gt;= now);
    require(_endTime &gt;= _startTime);
    require(_wallet != address(0));

    startTime = _startTime;
    endTime = _endTime;
    wallet = _wallet;
    refundEnabled = false;
  }

  function () external payable {
    deposit(msg.sender);
  }

  function addFunds() public payable onlyOwner {}

  
  function deposit(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    deposited[beneficiary] = deposited[beneficiary].add(msg.value);

    uint256 weiAmount = msg.value;
    emit AddDeposit(beneficiary, weiAmount);
  }

  
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now &gt;= startTime &amp;&amp; now &lt;= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod &amp;&amp; nonZeroPurchase;
  }


  // send ether to the fund collection wallet
  function forwardFunds() onlyOwner public {
    require(now &gt;= endTime);
    wallet.transfer(address(this).balance);
  }


  function refundWallet(address _wallet) onlyOwner public {
    refundFunds(_wallet);
  }

  function claimRefund() public {
    refundFunds(msg.sender);
  }

  function refundFunds(address _wallet) internal {
    require(_wallet != address(0));
    require(deposited[_wallet] &gt; 0);
    require(now &lt; endTime);

    uint256 depositedValue = deposited[_wallet];
    deposited[_wallet] = 0;
    
    _wallet.transfer(depositedValue);
    
    emit Refunded(_wallet, depositedValue);

  }

}