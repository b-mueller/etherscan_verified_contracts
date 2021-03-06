pragma solidity ^0.4.10;

contract ERC20Interface {
    uint public totalSupply;
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Administrable {
    address admin;
    bool public isPayable;
    
    function Administrable() {
        admin = msg.sender;
        isPayable = true;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
    
    modifier checkPayable() {
        require(isPayable);
        _;
    }
    
    function setPayable(bool isPayable_) onlyAdmin {
        isPayable = isPayable_;
    }
    
    function kill() onlyAdmin {
        selfdestruct(admin);
    }
}

contract NicoToken is ERC20Interface, Administrable {
    mapping (address =&gt; uint256) balances;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;

    string public constant name = &quot;Nico Token&quot;;
    string public constant symbol = &quot;NICO&quot;;
    uint8 public constant decimals = 18;
    uint public tokensPerETH = 1000;
    
    function balanceOf(address _owner) constant returns (uint256) { 
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        // mitigates the ERC20 short address attack
        if(msg.data.length &lt; (2 * 32) + 4) { 
            throw;
        }

        if (_value == 0) { 
            return false;
        }

        uint256 fromBalance = balances[msg.sender];

        bool sufficientFunds = fromBalance &gt;= _value;
        bool overflowed = balances[_to] + _value &lt; balances[_to];
        
        if (sufficientFunds &amp;&amp; !overflowed) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false; 
            
        }
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        // mitigates the ERC20 short address attack
        if(msg.data.length &lt; (3 * 32) + 4) { 
            throw;
        }

        if (_value == 0) {
            return false;
        }
        
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
        } else { 
            return false;
        }
    }
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 &amp;&amp; allowed[msg.sender][_spender] != 0) {
            return false;
        }
        
        allowed[msg.sender][_spender] = _value;
        
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function withdraw(uint amount) onlyAdmin {
        admin.transfer(amount);
    }

    function mint(uint amount) onlyAdmin {
        totalSupply += amount;
        balances[msg.sender] += amount;
        Transfer(address(this), msg.sender, amount);
    }
    
    function setPrice(uint tokensPerETH_) onlyAdmin {
        tokensPerETH = tokensPerETH_;
    }

    function() payable checkPayable {
        if (msg.value == 0) {
            return;
        }
        uint tokens = msg.value * tokensPerETH;
        totalSupply += tokens;
        balances[msg.sender] += tokens;
        Transfer(address(this), msg.sender, tokens);
    }
}