pragma solidity ^0.4.17;

/// @author developers //NB!
/// @notice <span class="__cf_email__" data-cfemail="483b3d3838273a3c082c2d3e2d2427382d3a3b">[email&#160;protected]</span> //NB!
/// @title  Contract presale //NB!

contract AvPresale {

    string public constant RELEASE = &quot;0.2.1_AviaTest&quot;;

    //config// 
    uint public constant PRESALE_START  = 5298043; /* 22.03.2018 03:07:00 +3GMT */ //NB!
    uint public constant PRESALE_END    = 5303803; /* 23.03.2018 03:07:00 +3GMT */ //NB!
    uint public constant WITHDRAWAL_END = 5309563; /* 24.03.2018 03:07:00 +3GMT */ //NB!

    address public constant OWNER = 0x32Bac79f4B6395DEa37f0c2B68b6e26ce24a59EA; //NB!

    uint public constant MIN_TOTAL_AMOUNT_GET_ETH = 1; //NB!
    uint public constant MAX_TOTAL_AMOUNT_GET_ETH = 2; //NB!
	//min send value 0.001 ETH (1 finney)
    uint public constant MIN_GET_AMOUNT_FINNEY = 10; //NB!

    string[5] private standingNames = [&quot;BEFORE_START&quot;,  &quot;PRESALE_RUNNING&quot;, &quot;WITHDRAWAL_RUNNING&quot;, &quot;MONEY_BACK_RUNNING&quot;, &quot;CLOSED&quot; ];
    enum State { BEFORE_START,  PRESALE_RUNNING, WITHDRAWAL_RUNNING, MONEY_BACK_RUNNING, CLOSED }

    uint public total_amount = 0;
    uint public total_money_back = 0;
    mapping (address =&gt; uint) public balances;

    uint private constant MIN_TOTAL_AMOUNT_GET = MIN_TOTAL_AMOUNT_GET_ETH * 1 ether;
    uint private constant MAX_TOTAL_AMOUNT_GET = MAX_TOTAL_AMOUNT_GET_ETH * 1 ether;
    uint private constant MIN_GET_AMOUNT = MIN_GET_AMOUNT_FINNEY * 1 finney;
    bool public isTerminated = false;
    bool public isStopped = false;


    function AvPresale () public checkSettings() { }


    //methods//
	
	//The transfer of money to the owner
    function sendMoneyOwner() external
	inStanding(State.WITHDRAWAL_RUNNING)
    onlyOwner
    noReentrancy
    {
        OWNER.transfer(this.balance);
    }
	
	//Money back to users
    function moneyBack() external
    inStanding(State.MONEY_BACK_RUNNING)
    noReentrancy
    {
        sendMoneyBack();
    }
	
    //payments
    function ()
    payable
    noReentrancy
    public
    {
        State state = currentStanding();
        if (state == State.PRESALE_RUNNING) {
            getMoney();
        } else if (state == State.MONEY_BACK_RUNNING) {
            sendMoneyBack();
        } else {
            revert();
        }
    }

    //Forced termination
    function termination() external
    inStandingBefore(State.MONEY_BACK_RUNNING)
    onlyOwner
    {
        isTerminated = true;
    }

    //Forced stop with the possibility of withdrawal
    function stop() external
    inStanding(State.PRESALE_RUNNING)
    onlyOwner
    {
        isStopped = true;
    }


    //Current status of the contract
    function standing() external constant
    returns (string)
    {
        return standingNames[ uint(currentStanding()) ];
    }

    //Method adding money to the user
    function getMoney() private notTooSmallAmountOnly {
      if (total_amount + msg.value &gt; MAX_TOTAL_AMOUNT_GET) {
          var change_to_return = total_amount + msg.value - MAX_TOTAL_AMOUNT_GET;
          var acceptable_remainder = MAX_TOTAL_AMOUNT_GET - total_amount;
          balances[msg.sender] += acceptable_remainder;
          total_amount += acceptable_remainder;
          msg.sender.transfer(change_to_return);
      } else {
          balances[msg.sender] += msg.value;
          total_amount += msg.value;
      }
    }
	
	//Method of repayment users 
    function sendMoneyBack() private tokenHoldersOnly {
        uint amount_to_money_back = min(balances[msg.sender], this.balance - msg.value) ;
        balances[msg.sender] -= amount_to_money_back;
        total_money_back += amount_to_money_back;
        msg.sender.transfer(amount_to_money_back + msg.value);
    }

    //Determining the current status of the contract
    function currentStanding() private constant returns (State) {
        if (isTerminated) {
            return this.balance &gt; 0
                   ? State.MONEY_BACK_RUNNING
                   : State.CLOSED;
        } else if (block.number &lt; PRESALE_START) {
            return State.BEFORE_START;
        } else if (block.number &lt;= PRESALE_END &amp;&amp; total_amount &lt; MAX_TOTAL_AMOUNT_GET &amp;&amp; !isStopped) {
            return State.PRESALE_RUNNING;
        } else if (this.balance == 0) {
            return State.CLOSED;
        } else if (block.number &lt;= WITHDRAWAL_END &amp;&amp; total_amount &gt;= MIN_TOTAL_AMOUNT_GET) {
            return State.WITHDRAWAL_RUNNING;
        } else {
            return State.MONEY_BACK_RUNNING;
        }
    }

    function min(uint a, uint b) pure private returns (uint) {
        return a &lt; b ? a : b;
    }

    //Prohibition if the condition does not match
    modifier inStanding(State state) {
        require(state == currentStanding());
        _;
    }

    //Prohibition if the current state was not before
    modifier inStandingBefore(State state) {
        require(currentStanding() &lt; state);
        _;
    }

    //Works on users&#39;s command
    modifier tokenHoldersOnly(){
        require(balances[msg.sender] &gt; 0);
        _;
    }

    //Do not accept transactions with a sum less than the configuration limit
    modifier notTooSmallAmountOnly(){
        require(msg.value &gt;= MIN_GET_AMOUNT);
        _;
    }

    //Prohibition of repeated treatment
    bool private lock = false;
    modifier noReentrancy() {
        require(!lock);
        lock = true;
        _;
        lock = false;
    }
	
	 //Prohibition if it does not match the settings
    modifier checkSettings() {
        if ( OWNER == 0x0
            || PRESALE_START == 0
            || PRESALE_END == 0
            || WITHDRAWAL_END ==0
            || PRESALE_START &lt;= block.number
            || PRESALE_START &gt;= PRESALE_END
            || PRESALE_END   &gt;= WITHDRAWAL_END
            || MIN_TOTAL_AMOUNT_GET &gt; MAX_TOTAL_AMOUNT_GET )
                revert();
        _;
    }
	
	//Works on owner&#39;s command
    modifier onlyOwner(){
        require(msg.sender == OWNER);
        _;
    }
}