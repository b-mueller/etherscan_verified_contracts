contract Token {
    string internal _symbol;
    string internal _name;
    uint8 internal _decimals;
    uint internal _totalSupply = 1000;
    mapping (address =&gt; uint) internal _balanceOf;
    mapping (address =&gt; mapping (address =&gt; uint)) internal _allowances;
    
    function Token(string symbol, string name, uint8 decimals, uint totalSupply) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
    }
    
    function name() public constant returns (string) {
        return _name;
    }
    
    function symbol() public constant returns (string) {
        return _symbol;
    }
    
    function decimals() public constant returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }
    
    function balanceOf(address _addr) public constant returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint _value);
}

interface ERC20 {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function approve(address _spender, uint _value) public returns (bool);
    function allowance(address _owner, address _spender) public constant returns (uint);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface ERC223 {
    function transfer(address _to, uint _value, bytes _data) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract FandBToken is Token(&quot;FAB&quot;, &quot;F&amp;BCoin&quot;, 0, 10000), ERC20, ERC223 {

    function FandBToken() public {
        _balanceOf[msg.sender] = _totalSupply;
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }
    
    function balanceOf(address _addr) public constant returns (uint) {
        return _balanceOf[_addr];
    }

    function transfer(address _to, uint _value) public returns (bool) {
        if (_value &gt; 0 &amp;&amp; 
            _value &lt;= _balanceOf[msg.sender] &amp;&amp;
            !isContract(_to)) {
            _balanceOf[msg.sender] -= _value;
            _balanceOf[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        if (_value &gt; 0 &amp;&amp; 
            _value &lt;= _balanceOf[msg.sender] &amp;&amp;
            isContract(_to)) {
            _balanceOf[msg.sender] -= _value;
            _balanceOf[_to] += _value;
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
                _contract.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        return false;
    }

    function isContract(address _addr) returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize &gt; 0;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_allowances[_from][msg.sender] &gt; 0 &amp;&amp;
            _value &gt; 0 &amp;&amp;
            _allowances[_from][msg.sender] &gt;= _value &amp;&amp;
            _balanceOf[_from] &gt;= _value) {
            _balanceOf[_from] -= _value;
            _balanceOf[_to] += _value;
            _allowances[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }
    
    function approve(address _spender, uint _value) public returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint) {
        return _allowances[_owner][_spender];
    }
}