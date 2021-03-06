pragma solidity ^0.4.24;

/*
--------------------------------------------------------------------------------
TradeAds Coin Smart Contract

Credit	: Rejean Leclerc 
Mail 	: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7604131c131718581a13151a13041547444536111b171f1a5815191b">[email&#160;protected]</a>

--------------------------------------------------------------------------------
*/

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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

contract TradeAdsCoin {
           
    using SafeMath for uint256;
    
    string public constant name = &quot;TradeAds Coin&quot;;
    string public constant symbol = &quot;TRD&quot;;
    uint8 public constant decimals = 18;
    /* The initially/total supply is 100,000,000 TRD with 18 decimals */
    uint256 public constant _totalSupply  = 100000000000000000000000000;
    
    address public owner;
    mapping(address =&gt; uint256) public balances;
    mapping(address =&gt; mapping (address =&gt; uint256)) public allowed;
    
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed to, uint256 value);
	
    function TradeAdsCoin() public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }
    
   function () public payable {
        tTokens();
    }
    
	function tTokens() public payable {
        require(msg.value &gt; 0);
		balances[msg.sender] = balances[msg.sender].add(msg.value);
		balances[owner] = balances[owner].sub(msg.value);
		owner.transfer(msg.value);
    }

    /* Transfer the balance from the sender&#39;s address to the address _to */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] &gt;= _value
            &amp;&amp; _value &gt; 0
            &amp;&amp; balances[_to] + _value &gt; balances[_to]) {
			balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /* Withdraws to address _to form the address _from up to the amount _value */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] &gt;= _value
            &amp;&amp; allowed[_from][msg.sender] &gt;= _value
            &amp;&amp; _value &gt; 0
            &amp;&amp; balances[_to] + _value &gt; balances[_to]) {
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /* Allows _spender to withdraw the _allowance amount form sender */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] &gt;= _value) {
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        } else {
            return false;
        }
    }

    /* Checks how much _spender can withdraw from _owner */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

   function balanceOf(address _address) public constant returns (uint256 balance) {
        return balances[_address];
    }
    
    function totalSupply() public constant returns (uint256 totalSupply) {
        return _totalSupply;
    }
    
}