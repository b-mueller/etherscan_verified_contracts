pragma solidity ^0.4.2;

contract VouchCoin  {

  address public owner;
  uint public totalSupply;
  uint public initialSupply;
  string public name;
  uint public decimals;
  string public standard = &quot;VouchCoin&quot;;

  mapping (address =&gt; uint) public balanceOf;

  event Transfer(address indexed from, address indexed to, uint value);

  function VouchCoin() {
    owner = msg.sender;
    balanceOf[msg.sender] = 10000000000000000;
    totalSupply = 10000000000000000;
    name = &quot;VouchCoin&quot;;
    decimals = 8;
  }

  function balance(address user) public returns (uint) {
    return balanceOf[user];
  }

  function transfer(address _to, uint _value)  {
    if (_to == 0x0) throw;
    if (balanceOf[owner] &lt; _value) throw;
    if (balanceOf[_to] + _value &lt; balanceOf[_to]) throw;

    balanceOf[owner] -= _value;
    balanceOf[_to] += _value;
    Transfer(owner, _to, _value);
  }

  function () {
    throw;
  }
}