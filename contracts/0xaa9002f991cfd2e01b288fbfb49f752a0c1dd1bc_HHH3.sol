pragma solidity ^0.4.17;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract Stopped is owned {

    bool public stopped = true;

    modifier noStopped {
        assert(!stopped);
        _;
    }

    function start() onlyOwner public {
      stopped = false;
    }

    function stop() onlyOwner public {
      stopped = true;
    }

}

contract MathHHH3 {

    function add(uint256 x, uint256 y) constant internal returns(uint256 z) {
      assert((z = x + y) &gt;= x);
    }

    function sub(uint256 x, uint256 y) constant internal returns(uint256 z) {
      assert((z = x - y) &lt;= x);
    }
}

contract TokenERC20 {

    function totalSupply() constant public returns (uint256 supply);
    function balanceOf(address who) constant public returns (uint256 value);
    function allowance(address owner, address spender) constant public returns (uint256 _allowance);
    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);

}

contract HHH3 is owned, Stopped, MathHHH3, TokenERC20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping (address =&gt; uint256) public balanceOf;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;
    mapping (address =&gt; bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
    event Burn(address from, uint256 value);

    function HHH3(string _name, string _symbol) public {
        totalSupply = 100000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = _name;
        symbol = _symbol;
    }

    function totalSupply() constant public returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address who) constant public returns (uint) {
        return balanceOf[who];
    }

    function allowance(address owner, address spender) constant public returns (uint256) {
        return allowance[owner][spender];
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (balanceOf[_from] &gt;= _value);
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
        balanceOf[_from] = sub(balanceOf[_from], _value);
        balanceOf[_to] = add(balanceOf[_to], _value);
        Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) noStopped public returns(bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) noStopped public returns (bool success) {
        require(_value &lt;= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = sub(allowance[_from][msg.sender], _value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) noStopped public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_spender]);
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function mintToken(address target, uint256 mintedAmount) noStopped onlyOwner public {
        balanceOf[target] = add(balanceOf[target], mintedAmount);
        totalSupply = add(totalSupply, mintedAmount);
        Transfer(0, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) noStopped onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function burn(uint256 _value) noStopped public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(balanceOf[msg.sender] &gt;= _value);
        balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);
        totalSupply = sub(totalSupply, _value);
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) noStopped public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_from]);
        require(balanceOf[_from] &gt;= _value);
        require(_value &lt;= allowance[_from][msg.sender]);
        balanceOf[_from] = sub(balanceOf[_from], _value);
        allowance[_from][msg.sender] = sub(allowance[_from][msg.sender], _value);
        totalSupply = sub(totalSupply, _value);
        Burn(_from, _value);
        return true;
    }

}