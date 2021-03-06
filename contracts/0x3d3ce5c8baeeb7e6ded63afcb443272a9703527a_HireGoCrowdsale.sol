contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c &gt;= a);
    return c;
  }
}


contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address =&gt; uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}



contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}



contract StandardToken is ERC20, BasicToken {

    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[_from]);
        require(_value &lt;= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue &gt; oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}



contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value &gt; 0);
        require(_value &lt;= balances[msg.sender]);
        // no need to require value &lt;= totalSupply, since that would imply the
        // sender&#39;s balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}



contract HireGoToken is MintableToken, BurnableToken {

    string public constant name = &quot;HireGo&quot;;
    string public constant symbol = &quot;HGO&quot;;
    uint32 public constant decimals = 18;

    function HireGoToken() public {
        totalSupply = 100000000E18;
        balances[owner] = totalSupply; // Add all tokens to issuer balance (crowdsale in this case)
    }

}



contract HireGoCrowdsale is Ownable {

    using SafeMath for uint;

    HireGoToken public token = new HireGoToken();
    uint totalSupply = token.totalSupply();

    bool public isRefundAllowed;
    bool public newBonus_and_newPeriod;
    bool public new_bonus_for_next_period;

    uint public icoStartTime;
    uint public icoEndTime;
    uint public totalWeiRaised;
    uint public weiRaised;
    uint public hardCap; // amount of ETH collected, which marks end of crowd sale
    uint public tokensDistributed; // amount of bought tokens
    uint public bonus_for_add_stage;

    /*         Bonus variables          */
    uint internal baseBonus1 = 160;
    uint internal baseBonus2 = 140;
    uint internal baseBonus3 = 130;
    uint internal baseBonus4 = 120;
    uint internal baseBonus5 = 110;
	  uint internal baseBonus6 = 100;
    uint public manualBonus;
    /* * * * * * * * * * * * * * * * * * */

    uint public rate; // how many token units a buyer gets per wei
    uint private icoMinPurchase; // In ETH
    uint private icoEndDateIncCount;

    address[] public investors_number;
    address private wallet; // address where funds are collected

    mapping (address =&gt; uint) public orderedTokens;
    mapping (address =&gt; uint) contributors;

    event FundsWithdrawn(address _who, uint256 _amount);

    modifier hardCapNotReached() {
        require(totalWeiRaised &lt; hardCap);
        _;
    }

    modifier crowdsaleEnded() {
        require(now &gt; icoEndTime);
        _;
    }

    modifier crowdsaleInProgress() {
        bool withinPeriod = (now &gt;= icoStartTime &amp;&amp; now &lt;= icoEndTime);
        require(withinPeriod);
        _;
    }

    function HireGoCrowdsale(uint _icoStartTime, uint _icoEndTime, address _wallet) public {
        require (
          _icoStartTime &gt; now &amp;&amp;
          _icoEndTime &gt; _icoStartTime
        );

        icoStartTime = _icoStartTime;
        icoEndTime = _icoEndTime;
        wallet = _wallet;

        rate = 250 szabo; // wei per 1 token (0.00025ETH)

        hardCap = 11575 ether;
        icoEndDateIncCount = 0;
        icoMinPurchase = 50 finney; // 0.05 ETH
        isRefundAllowed = false;
    }

    // fallback function can be used to buy tokens
    function() public payable {
        buyTokens();
    }

    // low level token purchase function
    function buyTokens() public payable crowdsaleInProgress hardCapNotReached {
        require(msg.value &gt; 0);

        // check if the buyer exceeded the funding goal
        calculatePurchaseAndBonuses(msg.sender, msg.value);
    }

    // Returns number of investors
    function getInvestorCount() public view returns (uint) {
        return investors_number.length;
    }

    // Owner can allow or disallow refunds even if soft cap is reached. Should be used in case KYC is not passed.
    // WARNING: owner should transfer collected ETH back to contract before allowing to refund, if he already withdrawn ETH.
    function toggleRefunds() public onlyOwner {
        isRefundAllowed = true;
    }

    // Moves ICO ending date by one month. End date can be moved only 1 times.
    // Returns true if ICO end date was successfully shifted
    function moveIcoEndDateByOneMonth(uint bonus_percentage) public onlyOwner crowdsaleInProgress returns (bool) {
        if (icoEndDateIncCount &lt; 1) {
            icoEndTime = icoEndTime.add(30 days);
            icoEndDateIncCount++;
            newBonus_and_newPeriod = true;
            bonus_for_add_stage = bonus_percentage;
            return true;
        }
        else {
            return false;
        }
    }

    // Owner can send back collected ETH if soft cap is not reached or KYC is not passed
    // WARNING: crowdsale contract should have all received funds to return them.
    // If you have already withdrawn them, send them back to crowdsale contract
    function refundInvestors() public onlyOwner {
        require(now &gt;= icoEndTime);
        require(isRefundAllowed);
        require(msg.sender.balance &gt; 0);

        address investor;
        uint contributedWei;
        uint tokens;
        for(uint i = 0; i &lt; investors_number.length; i++) {
            investor = investors_number[i];
            contributedWei = contributors[investor];
            tokens = orderedTokens[investor];
            if(contributedWei &gt; 0) {
                totalWeiRaised = totalWeiRaised.sub(contributedWei);
                weiRaised = weiRaised.sub(contributedWei);
                if(weiRaised&lt;0){
                  weiRaised = 0;
                }
                contributors[investor] = 0;
                orderedTokens[investor] = 0;
                tokensDistributed = tokensDistributed.sub(tokens);
                investor.transfer(contributedWei); // return funds back to contributor
            }
        }
    }

    // Owner of contract can withdraw collected ETH, if soft cap is reached, by calling this function
    function withdraw() public onlyOwner {
        uint to_send = weiRaised;
        weiRaised = 0;
        FundsWithdrawn(msg.sender, to_send);
        wallet.transfer(to_send);
    }

    // This function should be used to manually reserve some tokens for &quot;big sharks&quot; or bug-bounty program participants
    function manualReserve(address _beneficiary, uint _amount) public onlyOwner crowdsaleInProgress {
        require(_beneficiary != address(0));
        require(_amount &gt; 0);
        checkAndMint(_amount);
        tokensDistributed = tokensDistributed.add(_amount);
        token.transfer(_beneficiary, _amount);
    }

    function burnUnsold() public onlyOwner crowdsaleEnded {
        uint tokensLeft = totalSupply.sub(tokensDistributed);
        token.burn(tokensLeft);
    }

    function finishIco() public onlyOwner {
        icoEndTime = now;
    }

    function distribute_for_founders() public onlyOwner {
        uint to_send = 40000000000000000000000000; //40m
        checkAndMint(to_send);
        token.transfer(wallet, to_send);
    }

    function transferOwnershipToken(address _to) public onlyOwner {
        token.transferOwnership(_to);
    }

    /***************************
    **  Internal functions    **
    ***************************/

    // Calculates purchase conditions and token bonuses
    function calculatePurchaseAndBonuses(address _beneficiary, uint _weiAmount) internal {
        if (now &gt;= icoStartTime &amp;&amp; now &lt; icoEndTime) require(_weiAmount &gt;= icoMinPurchase);

        uint cleanWei; // amount of wei to use for purchase excluding change and hardcap overflows
        uint change;
        uint _tokens;

        //check for hardcap overflow
        if (_weiAmount.add(totalWeiRaised) &gt; hardCap) {
            cleanWei = hardCap.sub(totalWeiRaised);
            change = _weiAmount.sub(cleanWei);
        }
        else cleanWei = _weiAmount;

        assert(cleanWei &gt; 4); // 4 wei is a price of minimal fracture of token

        _tokens = cleanWei.div(rate).mul(1 ether);

        if (contributors[_beneficiary] == 0) investors_number.push(_beneficiary);

        _tokens = calculateBonus(_tokens);
        checkAndMint(_tokens);

        contributors[_beneficiary] = contributors[_beneficiary].add(cleanWei);
        weiRaised = weiRaised.add(cleanWei);
        totalWeiRaised = totalWeiRaised.add(cleanWei);
        tokensDistributed = tokensDistributed.add(_tokens);
        orderedTokens[_beneficiary] = orderedTokens[_beneficiary].add(_tokens);

        if (change &gt; 0) _beneficiary.transfer(change);

        token.transfer(_beneficiary,_tokens);
    }

    // Calculates bonuses based on current stage
    function calculateBonus(uint _baseAmount) internal returns (uint) {
        require(_baseAmount &gt; 0);

        if (now &gt;= icoStartTime &amp;&amp; now &lt; icoEndTime) {
            return calculateBonusIco(_baseAmount);
        }
        else return _baseAmount;
    }

    // Calculates bonuses, specific for the ICO
    // Contains date and volume based bonuses
    function calculateBonusIco(uint _baseAmount) internal returns(uint) {
        if(now &gt;= icoStartTime &amp;&amp; now &lt; 1520726399) {//3:55-4
            // 4-10 Mar - 60% bonus
            return _baseAmount.mul(baseBonus1).div(100);
        }
        else if(now &gt;= 1520726400 &amp;&amp; now &lt; 1521331199) {
            // 11-17 Mar - 40% bonus
            return _baseAmount.mul(baseBonus2).div(100);
        }
        else if(now &gt;= 1521331200 &amp;&amp; now &lt; 1521935999) {
            // 18-24 Mar - 30% bonus
            return _baseAmount.mul(baseBonus3).div(100);
        }
        else if(now &gt;= 1521936000 &amp;&amp; now &lt; 1524959999) {
            // 25 Mar-28 Apr - 20% bonus
            return _baseAmount.mul(baseBonus4).div(100);
        }
        else if(now &gt;= 1524960000 &amp;&amp; now &lt; 1526169599) {
            //29 Apr - 12 May - 10% bonus
            return _baseAmount.mul(baseBonus5).div(100);
        }
        else {
            //13 May - 26 May - no bonus
            return _baseAmount;
        }
    }

    // Checks if more tokens should be minted based on amount of sold tokens, required additional tokens and total supply.
    // If there are not enough tokens, mint missing tokens
    function checkAndMint(uint _amount) internal {
        uint required = tokensDistributed.add(_amount);
        if(required &gt; totalSupply) token.mint(this, required.sub(totalSupply));
    }
}