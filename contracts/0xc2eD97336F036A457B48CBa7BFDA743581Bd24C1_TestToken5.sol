pragma solidity ^0.4.11;

contract TestToken5 {

    string public name = &quot;TestToken5&quot;;      //  token name
    string public symbol = &quot;TT5&quot;;           //  token symbol
    uint public decimals = 6;               //  token digit

    mapping (address =&gt; uint256) public balanceOf;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;

    uint256 constant valueICO       = 40000000000000000;
    uint256 constant valueFounder   = 35000000000000000;
    uint256 constant valueVIP       = 15000000000000000;
    uint256 constant valuePeiwo     = 10000000000000000;

    uint public totalSupply = valueICO + valueFounder + valueVIP + valuePeiwo;

    function TestToken5(address _addressICO, address _addressFounder, address _addressVIP, address _addressPeiwo) {
        balanceOf[_addressICO] = valueICO;
        balanceOf[_addressFounder] = valueFounder;
        balanceOf[_addressVIP] = valueVIP;
        balanceOf[_addressPeiwo] = valuePeiwo;
        Transfer(0x0, _addressICO, valueICO);
        Transfer(0x0, _addressFounder, valueFounder);
        Transfer(0x0, _addressVIP, valueVIP);
        Transfer(0x0, _addressPeiwo, valuePeiwo);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        require(balanceOf[msg.sender] &gt;= _value);
        require(balanceOf[_to] + _value &gt;= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(balanceOf[_from] &gt;= _value);
        require(balanceOf[_to] + _value &gt;= balanceOf[_to]);
        require(allowance[_from][msg.sender] &gt;= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}