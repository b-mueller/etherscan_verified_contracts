pragma solidity ^0.4.19;

/*
This is MAUCOIN the Official Cryptocurrency of MU Crypto.
Made during a very boring evening by @Hoytico

(\(\
( – -)
((‘) (’)

Join us on Telegram https://t.me/joinchat/Hg3PmBMGZ7Wrt6jJD77D5Q
*/

contract MAUToken {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);
    
    string public constant symbol = &quot;MAU&quot;;
    string public constant name = &quot;Maucoin&quot;;
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 88888888000000000000000000;
    uint256 _totalBurned = 0;
     
    address public owner;
  
    mapping(address =&gt; uint256) balances;
  
    mapping(address =&gt; mapping (address =&gt; uint256)) allowed;
  
    modifier onlyOwner() 
     {
         if (msg.sender != owner) 
         {
             throw;
         }
         _;
     }
  
     function MAUToken() 
     {
        owner = msg.sender;
        balances[owner] = _totalSupply;
     }
  
     function totalSupply() constant returns (uint256 l_totalSupply) 
     {
        l_totalSupply = _totalSupply;
     }

     function totalBurned() constant returns (uint256 l_totalBurned)
     {
        l_totalBurned = _totalBurned;
     }
  
     function balanceOf(address _owner) constant returns (uint256 balance) 
     {
        return balances[_owner];
     }
  
     function transfer(address _to, uint256 _amount) returns (bool success) 
     {
        if (_to == 0x0) throw;

        if (balances[msg.sender] &gt;= _amount &amp;&amp; _amount &gt; 0 &amp;&amp; balances[_to] + _amount &gt; balances[_to]) 
        {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
         } 
         else 
         {
            return false;
         }
     }

     function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) 
     {
        if (_to == 0x0) throw;

        if (balances[_from] &gt;= _amount &amp;&amp; allowed[_from][msg.sender] &gt;= _amount &amp;&amp; _amount &gt; 0 &amp;&amp; balances[_to] + _amount &gt; balances[_to]) 
        {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
         } 
         else 
         {
            return false;
         }
     }
  
     function approve(address _spender, uint256 _amount) returns (bool success) 
     {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) 
     {
        return allowed[_owner][_spender];
     }

    function burn(uint256 _value) returns (bool success) 
    {
        if (balances[msg.sender] &lt; _value) throw;
        balances[msg.sender] -= _value;
        _totalSupply -= _value;          
        _totalBurned += _value;                             
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) returns (bool success) 
    {
        if (balances[_from] &lt; _value) throw;
        if (_value &gt; allowed[_from][msg.sender]) throw;
        balances[_from] -= _value;
        _totalSupply -= _value;                           
        _totalBurned += _value;
        Burn(_from, _value);
        return true;
    }
 }