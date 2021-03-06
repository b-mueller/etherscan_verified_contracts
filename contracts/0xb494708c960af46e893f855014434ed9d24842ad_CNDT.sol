pragma solidity ^0.4.13;

contract SafeMath {
    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z &gt;= x) &amp;&amp; (z &gt;= y));
      return z;
    }

    function safeSubtrCNDT(uint256 x, uint256 y) internal returns(uint256) {
      assert(x &gt;= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address =&gt; uint256) balances;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;
}

contract CNDT is StandardToken, SafeMath {

    string public constant name = &quot;CNDT&quot;;
    string public constant symbol = &quot;CNDT&quot;;
    uint256 public constant decimals = 18;
    string public version = &quot;1.0&quot;;

    address public CNDTTokenDeposit;

    uint256 public constant factorial = 6;
    uint256 public constant CNDTPrivate = 200 * (10**factorial) * 10**decimals; 
    
	address public owner;
	uint256 public totalissue = 2000 * (10**factorial) * 10**decimals;
	uint256 public issueamount = 200 * (10**factorial) * 10**decimals;
    
  
    // constructor
    function CNDT()
    {
      CNDTTokenDeposit = 0x6adABE44107afDa369D73C671A32b9aFEe810121;

      balances[CNDTTokenDeposit] = CNDTPrivate;
      totalSupply = CNDTPrivate; 
	  owner = msg.sender;
	  
    }
	
	function issue(address _to) {
	 if (msg.sender != owner )
		revert();
	 if (totalSupply + issueamount &gt; totalissue)
		revert();
	 balances[_to] += issueamount;
	 totalSupply += issueamount;
	}
}