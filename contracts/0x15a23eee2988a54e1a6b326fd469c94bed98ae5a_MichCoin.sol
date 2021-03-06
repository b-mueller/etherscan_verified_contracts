pragma solidity ^0.4.4;

contract ERC20 {
    uint public totalSupply;
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract MichCoin is ERC20 {

    string public constant name = &quot;Mich Coin&quot;;
    string public constant symbol = &quot;MCH&quot;;
    uint public constant decimals = 8;

    uint public tokenToEtherRate;

    uint public startTime;
    uint public endTime;
    uint public bonusEndTime;

    uint public minTokens;
    uint public maxTokens;
    bool public frozen;

    address owner;
    address reserve;
    address main;

    mapping(address =&gt; uint256) balances;
    mapping(address =&gt; uint256) incomes;
    mapping(address =&gt; mapping(address =&gt; uint256)) allowed;

    uint public tokenSold;

    function MichCoin(uint _tokenCount, uint _minTokenCount, uint _tokenToEtherRate,
                      uint _beginDurationInSec, uint _durationInSec, uint _bonusDurationInSec,
                      address _mainAddress, address _reserveAddress) {
        require(_minTokenCount &lt;= _tokenCount);
        require(_bonusDurationInSec &lt;= _durationInSec);
        require(_mainAddress != _reserveAddress);

        tokenToEtherRate = _tokenToEtherRate;
        totalSupply = _tokenCount*(10**decimals);
        minTokens = _minTokenCount*(10**decimals);
        maxTokens = totalSupply*85/100;

        owner = msg.sender;
        balances[this] = totalSupply;

        startTime = now + _beginDurationInSec;
        bonusEndTime = startTime + _bonusDurationInSec;
        endTime = startTime + _durationInSec;

        reserve = _reserveAddress;
        main = _mainAddress;
        frozen = false;
        tokenSold = 0;
    }

    //modifiers

    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    modifier canFreeze {
        require(frozen == false);
        _;
    }

    modifier waitForICO {
        require(now &gt;= startTime);
        _;
    }

    modifier afterICO {
        //if ico period over or all token sold
        require(now &gt; endTime || balances[this] &lt;= totalSupply - maxTokens);
        _;
    }

    //owner functions

    function freeze() ownerOnly {
        frozen = true;
    }

    function unfreeze() ownerOnly {
        frozen = false;
    }

    //erc20

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) canFreeze returns (bool success) {
        require(balances[msg.sender] &gt;= _value);
        require(balances[_to] + _value &gt; balances[_to]);

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint _value) canFreeze returns (bool success) {
        require(balances[msg.sender] &gt;= _value);
        require(allowed[_from][_to] &gt;= _value);
        require(balances[_to] + _value &gt; balances[_to]);

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][_to] -= _value;

        Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint _value) canFreeze returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    //ether operations

    function () payable canFreeze waitForICO {
        uint tokenAmount = weiToToken(msg.value);
        uint bonusAmount = 0;
        //add bonus token if bought on bonus period
        if (now &lt; bonusEndTime) {
            bonusAmount = tokenAmount / 10;
            tokenAmount += bonusAmount;
        }

        require(now &lt; endTime);
        require(balances[this] &gt;= tokenAmount);
        require(balances[this] - tokenAmount &gt;= totalSupply - maxTokens);
        require(balances[msg.sender] + tokenAmount &gt; balances[msg.sender]);

        balances[this] -= tokenAmount;
        balances[msg.sender] += tokenAmount;
        incomes[msg.sender] += msg.value;
        tokenSold += tokenAmount;
    }

    function refund(address _sender) canFreeze afterICO {
        require(balances[this] &gt;= totalSupply - minTokens);
        require(incomes[_sender] &gt; 0);

        balances[_sender] = 0;
        _sender.transfer(incomes[_sender]);
        incomes[_sender] = 0;
    }

    function withdraw() canFreeze afterICO {
        require(balances[this] &lt; totalSupply - minTokens);
        require(this.balance &gt; 0);

        balances[reserve] = (totalSupply - balances[this]) * 15 / 85;
        balances[this] = 0;
        main.transfer(this.balance);
    }

    //utility

    function tokenToWei(uint _tokens) constant returns (uint) {
        return _tokens * (10**18) / tokenToEtherRate / (10**decimals);
    }

    function weiToToken(uint _weis) constant returns (uint) {
        return tokenToEtherRate * _weis * (10**decimals) / (10**18);
    }

    function tokenAvailable() constant returns (uint) {
        uint available = balances[this] - (totalSupply - maxTokens);
        if (balances[this] &lt; (totalSupply - maxTokens)) {
            available = 0;
        }
        return available;
    }

}