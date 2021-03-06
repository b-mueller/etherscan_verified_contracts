pragma solidity ^0.4.11;

contract ERC20Standard {
 uint public totalSupply;
 
 string public name;
 uint8 public decimals;
 string public symbol;
 string public version;
 
 mapping (address =&gt; uint256) balances;
 mapping (address =&gt; mapping (address =&gt; uint)) allowed;

 //Fix for short address attack against ERC20
 modifier onlyPayloadSize(uint size) {
  assert(msg.data.length == size + 4);
  _;
 } 

 function balanceOf(address _owner) constant returns (uint balance) {
  return balances[_owner];
 }

 function transfer(address _recipient, uint _value) onlyPayloadSize(2*32) {
  require(balances[msg.sender] &gt;= _value &amp;&amp; _value &gt; 0);
     balances[msg.sender] -= _value;
     balances[_recipient] += _value;
     Transfer(msg.sender, _recipient, _value);        
    }

 function transferFrom(address _from, address _to, uint _value) {
  require(balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value &amp;&amp; _value &gt; 0);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }

 function approve(address _spender, uint _value) {
  allowed[msg.sender][_spender] = _value;
  Approval(msg.sender, _spender, _value);
 }

 function allowance(address _spender, address _owner) constant returns (uint balance) {
  return allowed[_owner][_spender];
 }

 //Event which is triggered to log all transfers to this contract&#39;s event log
 event Transfer(
  address indexed _from,
  address indexed _to,
  uint _value
  );
  
 //Event which is triggered whenever an owner approves a new allowance for a spender.
 event Approval(
  address indexed _owner,
  address indexed _spender,
  uint _value
  );

}
contract NewToken is ERC20Standard {
 function NewToken() {
  totalSupply = 10000000000000000000000000000;
  name = &quot;Fext Coin&quot;;
  decimals = 18;
  symbol = &quot;FEXT&quot;;
  version = &quot;1.0&quot;;
  balances[msg.sender] = totalSupply;
 }
}