pragma solidity ^0.4.23;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c &gt;= a);
    return c;
  }
}

contract KitFutureToken {
    address public owner;
    mapping(address =&gt; uint256) balances;
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    string public constant name = &quot;Karma Future Token&quot;;
    string public constant symbol = &quot;KIT-FUTURE&quot;;
    uint8 public constant decimals = 18;
    
    function KitFutureToken() public {
        owner = msg.sender;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function issueTokens(address[] _recipients, uint256[] _amounts) public onlyOwner {
        require(_recipients.length != 0 &amp;&amp; _recipients.length == _amounts.length);
        
        for (uint i = 0; i &lt; _recipients.length; i++) {
            balances[_recipients[i]] = balances[_recipients[i]].add(_amounts[i]);
            emit Transfer(address(0), _recipients[i], _amounts[i]);
        }
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}