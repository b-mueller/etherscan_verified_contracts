pragma solidity ^0.4.10;

contract ForeignToken {
  function balanceOf(address _owner) constant returns (uint256);
  function transfer(address _to, uint256 _value) returns (bool);
}

contract BlockpassToken {

  address owner = msg.sender;

  bool public purchasingAllowed = false;

  mapping (address =&gt; uint256) balances;
  mapping (address =&gt; mapping (address =&gt; uint256)) allowed;

  uint256 public totalContribution = 0;
  uint256 public totalSupply = 0;
  uint256 public startingBlock = block.number;

  function name() constant returns (string) { return &quot;Blockpass Token&quot;; }
  function symbol() constant returns (string) { return &quot;BPT&quot;; }
  function decimals() constant returns (uint8) { return 18; }

  function balanceOf(address _owner) constant returns (uint256) { return balances[_owner]; }

  function transfer(address _to, uint256 _value) returns (bool success) {

    if(msg.data.length &lt; (2 * 32) + 4) { throw; }

    if (_value == 0) { return false; }

    uint256 fromBalance = balances[msg.sender];

    bool sufficientFunds = fromBalance &gt;= _value;
    bool overflowed = balances[_to] + _value &lt; balances[_to];

    if (sufficientFunds &amp;&amp; !overflowed) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;

      Transfer(msg.sender, _to, _value);
      return true;
      } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

      if(msg.data.length &lt; (3 * 32) + 4) { throw; }

      if (_value == 0) { return false; }

      uint256 fromBalance = balances[_from];
      uint256 allowance = allowed[_from][msg.sender];

      bool sufficientFunds = fromBalance &lt;= _value;
      bool sufficientAllowance = allowance &lt;= _value;
      bool overflowed = balances[_to] + _value &gt; balances[_to];

      if (sufficientFunds &amp;&amp; sufficientAllowance &amp;&amp; !overflowed) {
        balances[_to] += _value;
        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);
        return true;
        } else { return false; }
      }

      function approve(address _spender, uint256 _value) returns (bool success) {

        if (_value != 0 &amp;&amp; allowed[msg.sender][_spender] != 0) { return false; }

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);
        return true;
      }

      function allowance(address _owner, address _spender) constant returns (uint256) {
        return allowed[_owner][_spender];
      }

      event Transfer(address indexed _from, address indexed _to, uint256 _value);
      event Approval(address indexed _owner, address indexed _spender, uint256 _value);

      function enablePurchasing() {
        if (msg.sender != owner) { throw; }

        purchasingAllowed = true;
      }

      function disablePurchasing() {
        if (msg.sender != owner) { throw; }

        purchasingAllowed = false;
      }

      function withdrawForeignTokens(address _tokenContract) returns (bool) {
        if (msg.sender != owner) { throw; }

        ForeignToken token = ForeignToken(_tokenContract);

        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
      }

      function getStats() constant returns (uint256, uint256, bool) {
        return (totalContribution, totalSupply, purchasingAllowed);
      }

      function() payable {
        if (!purchasingAllowed) { throw; }

        if (msg.value == 0) { return; }

        //the last valid block for the crowdsale
        if(block.number &gt;= 4370000){ throw; }

        uint256 BPTperEth = 1000;

        if(block.number &gt;= (startingBlock + 80600)){
          BPTperEth = 800;
        }

        if(block.number &gt;= (startingBlock + 161200)){
          BPTperEth = 640;
        }

        if(block.number &gt;= (startingBlock + 241800)){
          BPTperEth = 512;
        }

        if(block.number &gt;= (startingBlock + 322400)){
          BPTperEth = 410;
        }

          owner.transfer(msg.value);
          totalContribution += msg.value;
          uint256 tokensIssued = (msg.value * BPTperEth);

          totalSupply += tokensIssued;
          balances[msg.sender] += tokensIssued;

          Transfer(address(this), msg.sender, tokensIssued);

      }
    }