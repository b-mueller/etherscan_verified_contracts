pragma solidity ^0.4.16;
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}    

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract x32323 is owned{

//設定初始值//

    mapping (address =&gt; uint256) public balanceOf;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;
    mapping (address =&gt; bool) public frozenAccount;
    mapping (address =&gt; bool) initialized;

    event FrozenFunds(address target, bool frozen);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 2;
    uint256 public totalSupply;
    uint256 public maxSupply = 2300000000;
    uint256 totalairdrop = 600000000;
    uint256 airdrop1 = 1700008000; //1900000000;
    uint256 airdrop2 = 1700011000; //2100000000;
    uint256 airdrop3 = 1700012500; //2300000000;
    
//初始化//

    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
	initialSupply = maxSupply - totalairdrop;
    balanceOf[msg.sender] = initialSupply;
    totalSupply = initialSupply;
        name = &quot;測試16&quot;;
        symbol = &quot;測試16&quot;;         
    }

//空頭//
    function initialize(address _address) internal returns (bool success) {

        if (!initialized[_address]) {
            initialized[_address] = true ;
            if(totalSupply &lt; airdrop1){
                balanceOf[_address] += 2000;
                totalSupply += 2000;
            }
            if(airdrop1 &lt;= totalSupply &amp;&amp; totalSupply &lt; airdrop2){
                balanceOf[_address] += 800;
                totalSupply += 800;
            }
            if(airdrop2 &lt;= totalSupply &amp;&amp; totalSupply &lt;= airdrop3-3){
                balanceOf[_address] += 300;
                totalSupply += 300;    
            }
	    
        }
        return true;
    }
    
    function reward(address _address) internal returns (bool success) {
	    if (totalSupply &lt; maxSupply) {
	        initialized[_address] = true ;
            if(totalSupply &lt; airdrop1){
                balanceOf[_address] += 1000;
                totalSupply += 1000;
            }
            if(airdrop1 &lt;= totalSupply &amp;&amp; totalSupply &lt; airdrop2){
                balanceOf[_address] += 300;
                totalSupply += 300;
            }
            if(airdrop2 &lt;= totalSupply &amp;&amp; totalSupply &lt; airdrop3){
                balanceOf[_address] += 100;
                totalSupply += 100;    
            }
		
	    }
	    return true;
    }
//交易//

    function _transfer(address _from, address _to, uint _value) internal {
    	require(!frozenAccount[_from]);
        require(_to != 0x0);

        require(balanceOf[_from] &gt;= _value);
        require(balanceOf[_to] + _value &gt;= balanceOf[_to]);

        //uint previousBalances = balanceOf[_from] + balanceOf[_to];
	   
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        Transfer(_from, _to, _value);

        //assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

	initialize(_from);
	reward(_from);
	initialize(_to);
        
        
    }

    function transfer(address _to, uint256 _value) public {
        
	if(msg.sender.balance &lt; minBalanceForAccounts)
            sell((minBalanceForAccounts - msg.sender.balance) / sellPrice);
        _transfer(msg.sender, _to, _value);
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value &lt;= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

//販售//

    uint256 public sellPrice;
    uint256 public buyPrice;

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() payable returns (uint amount){
        amount = msg.value / buyPrice;                    // calculates the amount
        require(balanceOf[this] &gt;= amount);               // checks if it has enough to sell
        balanceOf[msg.sender] += amount;                  // adds the amount to buyer&#39;s balance
        balanceOf[this] -= amount;                        // subtracts amount from seller&#39;s balance
        Transfer(this, msg.sender, amount);               // execute an event reflecting the change
        return amount;                                    // ends function and returns
    }

    function sell(uint amount) returns (uint revenue){
        require(balanceOf[msg.sender] &gt;= amount);         // checks if the sender has enough to sell
        balanceOf[this] += amount;                        // adds the amount to owner&#39;s balance
        balanceOf[msg.sender] -= amount;                  // subtracts the amount from seller&#39;s balance
        revenue = amount * sellPrice;
        msg.sender.transfer(revenue);                     // sends ether to the seller: it&#39;s important to do this last to prevent recursion attacks
        Transfer(msg.sender, this, amount);               // executes an event reflecting on the change
        return revenue;                                   // ends function and returns
    }


    uint minBalanceForAccounts;
    
    function setMinBalance(uint minimumBalanceInFinney) onlyOwner {
         minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }

}