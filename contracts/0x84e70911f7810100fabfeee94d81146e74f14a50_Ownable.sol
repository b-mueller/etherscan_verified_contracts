pragma solidity ^0.4.13;
 
contract Ownable {
    
    address owner;
    
    function Ownable() {
        owner = msg.sender;
    }
 
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
 
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
    
}
 
contract T_CAB_001 is Ownable {
    
    string public constant name = &quot;CAB Equity T001&quot;;
    
    string public constant symbol = &quot;CABT001&quot;;
    
    uint32 public constant decimals = 8;
    
    uint public totalSupply = 0;
    
    mapping (address =&gt; uint) balances;
    
    mapping (address =&gt; mapping(address =&gt; uint)) allowed;
    
    function mint(address _to, uint _value) onlyOwner {
        assert(totalSupply + _value &gt;= totalSupply &amp;&amp; balances[_to] + _value &gt;= balances[_to]);
        balances[_to] += _value;
        totalSupply += _value;
    }
    
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint _value) returns (bool success) {
        if(balances[msg.sender] &gt;= _value &amp;&amp; balances[_to] + _value &gt;= balances[_to]) {
            balances[msg.sender] -= _value; 
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } 
        return false;
    }
    
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        if( allowed[_from][msg.sender] &gt;= _value &amp;&amp;
            balances[_from] &gt;= _value 
            &amp;&amp; balances[_to] + _value &gt;= balances[_to]) {
            allowed[_from][msg.sender] -= _value;
            balances[_from] -= _value; 
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            return true;
        } 
        return false;
    }
    
    function approve(address _spender, uint _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
}

/*
0x84e70911F7810100FAbfeee94D81146E74F14A50
*/