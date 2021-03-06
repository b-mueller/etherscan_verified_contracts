pragma solidity ^0.4.11;

// import &quot;./ERC223BasicToken.sol&quot;;

// import &quot;./SafeMath.sol&quot;;
/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c &gt;= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a &gt;= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a &lt; b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a &gt;= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a &lt; b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
// end import

// import &quot;./ERC223Basic.sol&quot;;
contract ERC223Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  function transfer(address to, uint value, bytes data);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
// end import

// import &quot;./ERC223ReceivingContract.sol&quot;;
 /*
 * Contract that is working with ERC223 tokens
 */
contract ERC223ReceivingContract {
  function tokenFallback(address _from, uint _value, bytes _data);
}
// end import 


contract ERC223BasicToken is ERC223Basic {
  using SafeMath for uint;

  mapping(address =&gt; uint) balances;

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address to, uint value, bytes data) {
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    uint codeLength;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(to)
    }

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);
    if (codeLength &gt; 0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
      receiver.tokenFallback(msg.sender, value, data);
    }
    Transfer(msg.sender, to, value, data);
  }

  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
  function transfer(address to, uint value) {
    uint codeLength;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(to)
    }

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);
    if (codeLength &gt; 0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
      bytes memory empty;
      receiver.tokenFallback(msg.sender, value, empty);
    }
    Transfer(msg.sender, to, value, empty);
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
}
// end import

contract PreTgeExperty is ERC223BasicToken {

  // token constants
  string public constant name = &quot;Pre-TGE Experty Token&quot;;
  string public constant symbol = &quot;PEXY&quot;;
  uint8 public constant decimals = 18;

  // pre-tge variables
  uint8 public basicRate = 100;
  uint8 public preTgeBonus = 45;
  address public preTgeManager;
  address public multisigWallet;
  bool public isClosed = false;

  // keep track of burned tokens here
  mapping(address =&gt; uint) public burnedTokens;
  
  // preICO constructor
  function PreTgeExperty() {
    multisigWallet = 0x6fb25777000c069bf4c253b9f5f886a5144a0021;
    preTgeManager = 0x009A55A3c16953A359484afD299ebdC444200EdB;
  }

  // contribute function
  function() payable {
    // throw if pre-tge is closed
    if (isClosed) throw;

    uint ethers = msg.value;

    // calculate tokens amount and pre-tge bonus
    uint tokens = ethers * basicRate;
    uint bonus = ethers * preTgeBonus;

    // generate new tokens
    uint sum = tokens + bonus;
    balances[msg.sender] += sum;
    totalSupply += sum;

    // send ethers to secure wallet
    multisigWallet.transfer(ethers);
  }

  // allow to burn pre-tge tokens in order to teleport them to new contract
  function burnTokens(uint amount) {
    if (amount &gt; balances[msg.sender]) throw;

    balances[msg.sender] = balances[msg.sender].sub(amount);
    burnedTokens[msg.sender] = burnedTokens[msg.sender].add(amount);
  }

  // allow contract manager to decrease bonus over time
  function changeBonus(uint8 _preTgeBonus) {
    if (msg.sender != preTgeManager) throw;

    // we can only decrease bonus
    if (_preTgeBonus &gt; preTgeBonus) throw;

    preTgeBonus = _preTgeBonus;
  }

  // allow contract manager to close pre-tge
  function close() {
    if (msg.sender != preTgeManager) throw;

    isClosed = true;
  }

}