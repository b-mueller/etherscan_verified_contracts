pragma solidity ^0.4.18;
// &#39;Metadollar&#39; CORE token contract
//
// Symbol      : DOL
// Name        : METADOLLAR
// Total supply: 1000,000,000,000
// Decimals    : 18
 // ERC Token Standard #20 Interface
 // https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
   
   contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c &gt;= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b &lt;= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b &gt; 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
    
 contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Owned{
	address public owner;
	address constant supervisor  = 0x318B0f768f5c6c567227AA50B51B5b3078902f8C;
	
	function owned(){
		owner = msg.sender;
	}

	/// @notice Functions with this modifier can only be executed by the owner
	modifier isOwner {
		assert(msg.sender == owner || msg.sender == supervisor);
		_;
	}
	
	/// @notice Transfer the ownership of this contract
	function transferOwnership(address newOwner);
	
	event ownerChanged(address whoTransferredOwnership, address formerOwner, address newOwner);
 }
 

contract METADOLLAR is ERC20Interface, Owned, SafeMath {
    
    

	string public constant name = &quot;METADOLLAR&quot;;
	string public constant symbol = &quot;DOL&quot;;
	uint public constant decimals = 18;
	uint256 public _totalSupply = 1000000000000000000000000000000;
	uint256 public icoMin = 1000000000000000;					
	uint256 public icoLimit = 1000000000000000000000000000000;			
	uint256 public countHolders = 0;				// count how many unique holders have tokens
	uint256 public amountOfInvestments = 0;	// amount of collected wei
	
	
	uint256 public icoPrice;	
	uint256 public dolRate = 1000;
	uint256 public ethRate = 1;
	uint256 public sellRate = 900;
	uint256 public commissionRate = 1000;
	uint256 public sellPrice;
	uint256 public currentTokenPrice;				
	uint256 public commission;	
	
	
	bool public icoIsRunning;
	bool public minimalGoalReached;
	bool public icoIsClosed;

	//Balances for each account
	mapping (address =&gt; uint256) public tokenBalanceOf;

	// Owner of account approves the transfer of an amount to another account
	mapping(address =&gt; mapping (address =&gt; uint256)) allowed;
	
	//list with information about frozen accounts
	mapping(address =&gt; bool) frozenAccount;
	
	//this generate a public event on a blockchain that will notify clients
	event FrozenFunds(address initiator, address account, string status);
	
	//this generate a public event on a blockchain that will notify clients
	event BonusChanged(uint8 bonusOld, uint8 bonusNew);
	
	//this generate a public event on a blockchain that will notify clients
	event minGoalReached(uint256 minIcoAmount, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event preIcoEnded(uint256 preIcoAmount, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event priceUpdated(uint256 oldPrice, uint256 newPrice, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event withdrawed(address _to, uint256 summe, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event deposited(address _from, uint256 summe, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event orderToTransfer(address initiator, address _from, address _to, uint256 summe, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event tokenCreated(address _creator, uint256 summe, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event tokenDestroyed(address _destroyer, uint256 summe, string notice);
	
	//this generate a public event on a blockchain that will notify clients
	event icoStatusUpdated(address _initiator, string status);

	/// @notice Constructor of the contract
	function STARTMETADOLLAR() {
		icoIsRunning = true;
		minimalGoalReached = false;
		icoIsClosed = false;
		tokenBalanceOf[this] += _totalSupply;
		allowed[this][owner] = _totalSupply;
		allowed[this][supervisor] = _totalSupply;
		currentTokenPrice = 1 * 1;	// initial price of 1 Token
		icoPrice = ethRate * dolRate;		
		sellPrice = sellRate * ethRate;
		updatePrices();
	}

	function () payable {
		require(!frozenAccount[msg.sender]);
		if(msg.value &gt; 0 &amp;&amp; !frozenAccount[msg.sender]) {
			buyToken();
		}
	}

	/// @notice Returns a whole amount of tokens
	function totalSupply() constant returns (uint256 totalAmount) {
		totalAmount = _totalSupply;
	}

	/// @notice What is the balance of a particular account?
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return tokenBalanceOf[_owner];
	}

	/// @notice Shows how much tokens _spender can spend from _owner address
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
	
	/// @notice Calculates amount of weis needed to buy more than one token
	/// @param howManyTokenToBuy - Amount of tokens to calculate
	function calculateTheEndPrice(uint256 howManyTokenToBuy) constant returns (uint256 summarizedPriceInWeis) {
		if(howManyTokenToBuy &gt; 0) {
			summarizedPriceInWeis = howManyTokenToBuy * currentTokenPrice;
		}else {
			summarizedPriceInWeis = 0;
		}
	}
	
	/// @notice Shows if account is frozen
	/// @param account - Accountaddress to check
	function checkFrozenAccounts(address account) constant returns (bool accountIsFrozen) {
		accountIsFrozen = frozenAccount[account];
	}

	/// @notice Buy tokens from contract by sending ether
	function buy() payable public {
		require(!frozenAccount[msg.sender]);
		require(msg.value &gt; 0);
		commission = msg.value/commissionRate; // % of wei tx
        require(address(this).send(commission));
		buyToken();
	}
	

	/// @notice Sell tokens and receive ether from contract
	function sell(uint256 amount) {
		require(!frozenAccount[msg.sender]);
		require(tokenBalanceOf[msg.sender] &gt;= amount);         	// checks if the sender has enough to sell
		require(amount &gt; 0);
		require(sellPrice &gt; 0);
		_transfer(msg.sender, this, amount);
		uint256 revenue = amount * sellPrice;
		require(this.balance &gt;= revenue);
		commission = msg.value/commissionRate; // % of wei tx
        require(address(this).send(commission));
		msg.sender.transfer(revenue);                		// sends ether to the seller: it&#39;s important to do this last to prevent recursion attacks
	}
	
   

    function sell2(address _tokenAddress) public payable{
        METADOLLAR token = METADOLLAR(_tokenAddress);
        uint tokens = msg.value * sellPrice;
        require(token.balanceOf(this) &gt;= tokens);
        commission = msg.value/commissionRate; // % of wei tx
       require(address(this).send(commission));
        token.transfer(msg.sender, tokens);
    }

	

	/// @notice Transfer amount of tokens from own wallet to someone else
	function transfer(address _to, uint256 _value) returns (bool success) {
		assert(msg.sender != address(0));
		assert(_to != address(0));
		require(!frozenAccount[msg.sender]);
		require(!frozenAccount[_to]);
		require(tokenBalanceOf[msg.sender] &gt;= _value);
		require(tokenBalanceOf[msg.sender] - _value &lt; tokenBalanceOf[msg.sender]);
		require(tokenBalanceOf[_to] + _value &gt; tokenBalanceOf[_to]);
		require(_value &gt; 0);
		_transfer(msg.sender, _to, _value);
		return true;
	}

	/// @notice  Send _value amount of tokens from address _from to address _to
	/// @notice  The transferFrom method is used for a withdraw workflow, allowing contracts to send
	/// @notice  tokens on your behalf, for example to &quot;deposit&quot; to a contract address and/or to charge
	/// @notice  fees in sub-currencies; the command should fail unless the _from account has
	/// @notice  deliberately authorized the sender of the message via some mechanism;
	function transferFrom(address _from,	address _to,	uint256 _value) returns (bool success) {
		assert(msg.sender != address(0));
		assert(_from != address(0));
		assert(_to != address(0));
		require(!frozenAccount[msg.sender]);
		require(!frozenAccount[_from]);
		require(!frozenAccount[_to]);
		require(tokenBalanceOf[_from] &gt;= _value);
		require(allowed[_from][msg.sender] &gt;= _value);
		require(tokenBalanceOf[_from] - _value &lt; tokenBalanceOf[_from]);
		require(tokenBalanceOf[_to] + _value &gt; tokenBalanceOf[_to]);
		require(_value &gt; 0);
		orderToTransfer(msg.sender, _from, _to, _value, &quot;Order to transfer tokens from allowed account&quot;);
		_transfer(_from, _to, _value);
		allowed[_from][msg.sender] -= _value;
		return true;
	}

	/// @notice Allow _spender to withdraw from your account, multiple times, up to the _value amount.
	/// @notice If this function is called again it overwrites the current allowance with _value.
	function approve(address _spender, uint256 _value) returns (bool success) {
		require(!frozenAccount[msg.sender]);
		assert(_spender != address(0));
		require(_value &gt;= 0);
		allowed[msg.sender][_spender] = _value;
		return true;
	}

	/// @notice Check if minimal goal of ICO is reached
	function checkMinimalGoal() internal {
		if(tokenBalanceOf[this] &lt;= _totalSupply - icoMin) {
			minimalGoalReached = true;
			minGoalReached(icoMin, &quot;Minimal goal of ICO is reached!&quot;);
		}
	}

	/// @notice Check if ICO is ended
	function checkIcoStatus() internal {
		if(tokenBalanceOf[this] &lt;= _totalSupply - icoLimit) {
			icoIsRunning = false;
		}
	}

	/// @notice Processing each buying
	function buyToken() internal {
		uint256 value = msg.value;
		address sender = msg.sender;
		require(!icoIsClosed);
		require(!frozenAccount[sender]);
		require(value &gt; 0);
		require(currentTokenPrice &gt; 0);
		uint256 amount = value / currentTokenPrice;			// calculates amount of tokens
		uint256 moneyBack = value - (amount * sellPrice);
		require(tokenBalanceOf[this] &gt;= amount);              		// checks if contract has enough to sell
		amountOfInvestments = amountOfInvestments + (value - moneyBack);
		updatePrices();
		_transfer(this, sender, amount);
		if(moneyBack &gt; 0) {
			sender.transfer(moneyBack);
		}
	}

	/// @notice Internal transfer, can only be called by this contract
	function _transfer(address _from, address _to, uint256 _value) internal {
		assert(_from != address(0));
		assert(_to != address(0));
		require(_value &gt; 0);
		require(tokenBalanceOf[_from] &gt;= _value);
		require(tokenBalanceOf[_to] + _value &gt; tokenBalanceOf[_to]);
		require(!frozenAccount[_from]);
		require(!frozenAccount[_to]);
		if(tokenBalanceOf[_to] == 0){
			countHolders += 1;
		}
		tokenBalanceOf[_from] -= _value;
		if(tokenBalanceOf[_from] == 0){
			countHolders -= 1;
		}
		tokenBalanceOf[_to] += _value;
		allowed[this][owner] = tokenBalanceOf[this];
		allowed[this][supervisor] = tokenBalanceOf[this];
		Transfer(_from, _to, _value);
	}

	/// @notice Set current ICO prices in wei for one token
	function updatePrices() internal {
		uint256 oldPrice = currentTokenPrice;
		if(icoIsRunning) {
			checkIcoStatus();
		}
		if(icoIsRunning) {
			currentTokenPrice = icoPrice;
		}else{
			currentTokenPrice = icoPrice;
		}
		
		if(oldPrice != currentTokenPrice) {
			priceUpdated(oldPrice, currentTokenPrice, &quot;Token price updated!&quot;);
		}
	}

	/// @notice Set current ICO price in wei for one token
	/// @param priceForIcoInWei - is the amount in wei for one token
	function setICOPrice(uint256 priceForIcoInWei) isOwner {
		require(priceForIcoInWei &gt; 0);
		require(icoPrice != priceForIcoInWei);
		icoPrice = priceForIcoInWei;
		updatePrices();
	}

	

	/// @notice Set the current sell price in wei for one token
	/// @param priceInWei - is the amount in wei for one token
	function setSellRate(uint256 priceInWei) isOwner {
		require(priceInWei &gt;= 0);
		sellRate = priceInWei;
	}
	
	/// @notice Set the current commission rate
	/// @param commissionRateInWei - commission rate
	function setCommissionRate(uint256 commissionRateInWei) isOwner {
		require(commissionRateInWei &gt;= 0);
		commissionRate = commissionRateInWei;
	}
	
	/// @notice Set the current DOL rate in wei for one eth
	/// @param dolInWei - is the amount in wei for one ETH
	function setDolRate(uint256 dolInWei) isOwner {
		require(dolInWei &gt;= 0);
		dolRate = dolInWei;
	}
	
	/// @notice Set the current ETH rate in wei for one DOL
	/// @param ethInWei - is the amount in wei for one DOL
	function setEthRate(uint256 ethInWei) isOwner {
		require(ethInWei &gt;= 0);
		ethRate = ethInWei;
	}



	/// @notice &#39;freeze? Prevent | Allow&#39; &#39;account&#39; from sending and receiving tokens
	/// @param account - address to be frozen
	/// @param freeze - select is the account frozen or not
	function freezeAccount(address account, bool freeze) isOwner {
		require(account != owner);
		require(account != supervisor);
		frozenAccount[account] = freeze;
		if(freeze) {
			FrozenFunds(msg.sender, account, &quot;Account set frozen!&quot;);
		}else {
			FrozenFunds(msg.sender, account, &quot;Account set free for use!&quot;);
		}
	}

	/// @notice Create an amount of token
	/// @param amount - token to create
	function mintToken(uint256 amount) isOwner {
		require(amount &gt; 0);
		require(tokenBalanceOf[this] &lt;= icoMin);	// owner can create token only if the initial amount is strongly not enough to supply and demand ICO
		require(_totalSupply + amount &gt; _totalSupply);
		require(tokenBalanceOf[this] + amount &gt; tokenBalanceOf[this]);
		_totalSupply += amount;
		tokenBalanceOf[this] += amount;
		allowed[this][owner] = tokenBalanceOf[this];
		allowed[this][supervisor] = tokenBalanceOf[this];
		tokenCreated(msg.sender, amount, &quot;Additional tokens created!&quot;);
	}

	/// @notice Destroy an amount of token
	/// @param amount - token to destroy
	function destroyToken(uint256 amount) isOwner {
		require(amount &gt; 0);
		require(tokenBalanceOf[this] &gt;= amount);
		require(_totalSupply &gt;= amount);
		require(tokenBalanceOf[this] - amount &gt;= 0);
		require(_totalSupply - amount &gt;= 0);
		tokenBalanceOf[this] -= amount;
		_totalSupply -= amount;
		allowed[this][owner] = tokenBalanceOf[this];
		allowed[this][supervisor] = tokenBalanceOf[this];
		tokenDestroyed(msg.sender, amount, &quot;An amount of tokens destroyed!&quot;);
	}

	/// @notice Transfer the ownership to another account
	/// @param newOwner - address who get the ownership
	function transferOwnership(address newOwner) isOwner {
		assert(newOwner != address(0));
		address oldOwner = owner;
		owner = newOwner;
		ownerChanged(msg.sender, oldOwner, newOwner);
		allowed[this][oldOwner] = 0;
		allowed[this][newOwner] = tokenBalanceOf[this];
	}

	/// @notice Transfer all ether from smartcontract to owner
	function collect() isOwner {
        require(this.balance &gt; 0);
		withdraw(this.balance);
    }

	/// @notice Withdraw an amount of ether
	/// @param summeInWei - amout to withdraw
	function withdraw(uint256 summeInWei) isOwner {
		uint256 contractbalance = this.balance;
		address sender = msg.sender;
		require(contractbalance &gt;= summeInWei);
		withdrawed(sender, summeInWei, &quot;wei withdrawed&quot;);
        sender.transfer(summeInWei);
	}

	/// @notice Deposit an amount of ether
	function deposit() payable isOwner {
		require(msg.value &gt; 0);
		require(msg.sender.balance &gt;= msg.value);
		deposited(msg.sender, msg.value, &quot;wei deposited&quot;);
	}


	/// @notice Stop running ICO
	/// @param icoIsStopped - status if this ICO is stopped
	function stopThisIco(bool icoIsStopped) isOwner {
		require(icoIsClosed != icoIsStopped);
		icoIsClosed = icoIsStopped;
		if(icoIsStopped) {
			icoStatusUpdated(msg.sender, &quot;Coin offering was stopped!&quot;);
		}else {
			icoStatusUpdated(msg.sender, &quot;Coin offering is running!&quot;);
		}
	}

}