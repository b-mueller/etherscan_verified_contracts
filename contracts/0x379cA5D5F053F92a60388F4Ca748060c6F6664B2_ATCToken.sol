pragma solidity ^0.4.8;

contract ERC20Interface {    
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ATCToken is ERC20Interface{
    string public standard = &#39;Token 1.0&#39;;
    string public constant name=&quot;ATC&quot;;
    string public constant symbol=&quot;ATC&quot;;
    uint8 public constant decimals=10;
    uint256 public constant _totalSupply=3000000000000000000;
    mapping(address =&gt; mapping (address =&gt; uint256)) allowed;
    mapping(address =&gt; uint256) balances;
    address public owner;
    
    function ATCToken() {
        owner = msg.sender;
        balances[owner] = _totalSupply; 
    }
    
    function totalSupply() constant returns (uint256 totalSupply) {
          totalSupply = _totalSupply;
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance){
        return balances[_owner]; 
    }

    function transfer(address _to, uint256 _amount) returns (bool success)  {
       if (balances[msg.sender] &gt;= _amount 
              &amp;&amp; _amount &gt; 0
              &amp;&amp; balances[_to] + _amount &gt; balances[_to]) {
              balances[msg.sender] -= _amount;
              balances[_to] += _amount;
              Transfer(msg.sender, _to, _amount);
              return true;
          } else {
              return false;
          }
    }

    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success){
        if (balances[_from] &gt;= _amount
             &amp;&amp; _amount &gt; 0
             &amp;&amp; balances[_to] + _amount &gt; balances[_to]  &amp;&amp; _amount &lt;= allowed[_from][msg.sender]) {
             balances[_from] -= _amount;
             balances[_to] += _amount;
             allowed[_from][msg.sender] -= _amount;
             Transfer(_from, _to, _amount);
             return true;
         } else {
             return false;
         }
    }

    function approve(address _spender, uint256 _value) returns (bool success){
         allowed[msg.sender][_spender] = _value;
         Approval(msg.sender, _spender, _value);
         return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }
}