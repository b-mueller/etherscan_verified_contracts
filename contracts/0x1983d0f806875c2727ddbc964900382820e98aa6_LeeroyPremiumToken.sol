pragma solidity ^0.4.8;

contract SafeMath {

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        assert((z &gt;= x) &amp;&amp; (z &gt;= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
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


/*  ERC 20 token */
contract LeeroyPremiumToken is StandardToken, SafeMath {
    address public owner;

    string public constant name = &quot;Leeroy Premium Token&quot;;
    string public constant symbol = &quot;LPT&quot;;
    uint256 public constant decimals = 18;
    string public version = &quot;1.0&quot;;

    bool public isFinalized;
    uint256 public fundingStartBlock = 3965525;
    uint256 public fundingEndBlock = 4115525;
    uint256 public constant reservedLPT = 375 * (10**6) * 10**decimals;
    uint256 public constant tokenExchangeRate = 32000;
    uint256 public constant tokenCreationCap =  2000 * (10**6) * 10**decimals;
    uint256 public constant tokenCreationMin =  775 * (10**6) * 10**decimals;

    // events
    event LogRefund(address indexed _to, uint256 _value);
    event CreateLPT(address indexed _to, uint256 _value);

    function LeeroyPremiumToken() {
        owner = msg.sender;
        totalSupply = reservedLPT;
        balances[owner] = reservedLPT;
        CreateLPT(owner, reservedLPT);
    }

    function () payable {
        createTokens();
    }

    function createTokens() payable {
      if (isFinalized) throw;
      if (block.number &lt; fundingStartBlock) throw;
      if (block.number &gt; fundingEndBlock) throw;
      if (msg.value == 0) throw;

      uint256 tokens = safeMult(msg.value, tokenExchangeRate);
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      if (tokenCreationCap &lt; checkedSupply) throw;

      totalSupply = checkedSupply;
      balances[msg.sender] += tokens;
      CreateLPT(msg.sender, tokens);
    }

    function finalize() external {
      if (isFinalized) throw;
      if(totalSupply &lt; tokenCreationMin) throw;
      if(block.number &lt;= fundingEndBlock &amp;&amp; totalSupply != tokenCreationCap) throw;
      isFinalized = true;
      if(!owner.send(this.balance)) throw;
    }

    function refund() external {
      if(isFinalized) throw;
      if (block.number &lt;= fundingEndBlock) throw;
      if(totalSupply &gt;= tokenCreationMin) throw;
      uint256 LPTVal = balances[msg.sender];
      if (LPTVal == 0) throw;
      balances[msg.sender] = 0;
      totalSupply = safeSubtract(totalSupply, LPTVal);
      uint256 ethVal = LPTVal / tokenExchangeRate;
      LogRefund(msg.sender, ethVal);
      if (!msg.sender.send(ethVal)) throw;
    }
}