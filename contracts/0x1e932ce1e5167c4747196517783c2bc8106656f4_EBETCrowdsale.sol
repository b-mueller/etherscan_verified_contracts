// **-----------------------------------------------
// EthBet.io Token sale contract
// Final revision 16a
// Refunds integrated, full test suite passed
// **-----------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
// -------------------------------------------------
// Price configuration:
// First Day Bonus    +50% = 1,500 EBET  = 1 ETH       [blocks: start   -&gt; s+3600]
// First Week Bonus   +40% = 1,400 EBET  = 1 ETH       [blocks: s+3601  -&gt; s+25200]
// Second Week Bonus  +30% = 1,300 EBET  = 1 ETH       [blocks: s+25201 -&gt; s+50400]
// Third Week Bonus   +25% = 1,250 EBET  = 1 ETH       [blocks: s+50401 -&gt; s+75600]
// Final Week Bonus   +15% = 1,150 EBET  = 1 ETH       [blocks: s+75601 -&gt; end]
// -------------------------------------------------
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract safeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    safeAssert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
    safeAssert(b &gt; 0);
    uint256 c = a / b;
    safeAssert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
    safeAssert(b &lt;= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    safeAssert(c&gt;=a &amp;&amp; c&gt;=b);
    return c;
  }

  function safeAssert(bool assertion) internal {
    if (!assertion) revert();
  }
}

contract StandardToken is owned, safeMath {
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract EBETCrowdsale is owned, safeMath {
  // owner/admin &amp; token reward
  address        public admin                     = owner;   // admin address
  StandardToken  public tokenReward;                          // address of the token used as reward

  // deployment variables for static supply sale
  uint256 public initialSupply;
  uint256 public tokensRemaining;

  // multi-sig addresses and price variable
  address public beneficiaryWallet;                           // beneficiaryMultiSig (founder group) or wallet account, live is 0x00F959866E977698D14a36eB332686304a4d6AbA
  uint256 public tokensPerEthPrice;                           // set initial value floating priceVar 1,500 tokens per Eth

  // uint256 values for min,max,caps,tracking
  uint256 public amountRaisedInWei;                           //
  uint256 public fundingMinCapInWei;                          //

  // loop control, ICO startup and limiters
  string  public CurrentStatus                   = &quot;&quot;;        // current crowdsale status
  uint256 public fundingStartBlock;                           // crowdsale start block#
  uint256 public fundingEndBlock;                             // crowdsale end block#
  bool    public isCrowdSaleClosed               = false;     // crowdsale completion boolean
  bool    public areFundsReleasedToBeneficiary   = false;     // boolean for founder to receive Eth or not
  bool    public isCrowdSaleSetup                = false;     // boolean for crowdsale setup

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Buy(address indexed _sender, uint256 _eth, uint256 _EBET);
  event Refund(address indexed _refunder, uint256 _value);
  event Burn(address _from, uint256 _value);
  mapping(address =&gt; uint256) balancesArray;
  mapping(address =&gt; uint256) fundValue;

  // default function, map admin
  function EBETCrowdsale() onlyOwner {
    admin = msg.sender;
    CurrentStatus = &quot;Crowdsale deployed to chain&quot;;
  }

  // total number of tokens initially
  function initialEBETSupply() constant returns (uint256 tokenTotalSupply) {
      tokenTotalSupply = safeDiv(initialSupply,100);
  }

  // remaining number of tokens
  function remainingSupply() constant returns (uint256 tokensLeft) {
      tokensLeft = tokensRemaining;
  }

  // setup the CrowdSale parameters
  function SetupCrowdsale(uint256 _fundingStartBlock, uint256 _fundingEndBlock) onlyOwner returns (bytes32 response) {
      if ((msg.sender == admin)
      &amp;&amp; (!(isCrowdSaleSetup))
      &amp;&amp; (!(beneficiaryWallet &gt; 0))){
          // init addresses
          tokenReward                             = StandardToken(0x7D5Edcd23dAa3fB94317D32aE253eE1Af08Ba14d);  //mainnet is 0x7D5Edcd23dAa3fB94317D32aE253eE1Af08Ba14d //testnet = 0x75508c2B1e46ea29B7cCf0308d4Cb6f6af6211e0
          beneficiaryWallet                       = 0x00F959866E977698D14a36eB332686304a4d6AbA;   // mainnet is 0x00F959866E977698D14a36eB332686304a4d6AbA //testnet = 0xDe6BE2434E8eD8F74C8392A9eB6B6F7D63DDd3D7
          tokensPerEthPrice                       = 1500;                                         // set day1 initial value floating priceVar 1,500 tokens per Eth

          // funding targets
          fundingMinCapInWei                      = 300000000000000000000;                          //300000000000000000000 =  300 Eth (min cap) - crowdsale is considered success after this value  //testnet 6000000000000000000 = 6Eth

          // update values
          amountRaisedInWei                       = 0;
          initialSupply                           = 750000000;                                      //   7,500,000 + 2 decimals = 750000000 //testnet 1100000 =11,000
          tokensRemaining                         = safeDiv(initialSupply,100);

          fundingStartBlock                       = _fundingStartBlock;
          fundingEndBlock                         = _fundingEndBlock;

          // configure crowdsale
          isCrowdSaleSetup                        = true;
          isCrowdSaleClosed                       = false;
          CurrentStatus                           = &quot;Crowdsale is setup&quot;;

          //gas reduction experiment
          setPrice();
          return &quot;Crowdsale is setup&quot;;
      } else if (msg.sender != admin) {
          return &quot;not authorized&quot;;
      } else  {
          return &quot;campaign cannot be changed&quot;;
      }
    }

    function setPrice() {
      // Price configuration:
      // First Day Bonus    +50% = 1,500 EBET  = 1 ETH       [blocks: start -&gt; s+3600]
      // First Week Bonus   +40% = 1,400 EBET  = 1 ETH       [blocks: s+3601  -&gt; s+25200]
      // Second Week Bonus  +30% = 1,300 EBET  = 1 ETH       [blocks: s+25201 -&gt; s+50400]
      // Third Week Bonus   +25% = 1,250 EBET  = 1 ETH       [blocks: s+50401 -&gt; s+75600]
      // Final Week Bonus   +15% = 1,150 EBET  = 1 ETH       [blocks: s+75601 -&gt; endblock]
      if (block.number &gt;= fundingStartBlock &amp;&amp; block.number &lt;= fundingStartBlock+3600) { // First Day Bonus    +50% = 1,500 EBET  = 1 ETH  [blocks: start -&gt; s+24]
        tokensPerEthPrice=1500;
      } else if (block.number &gt;= fundingStartBlock+3601 &amp;&amp; block.number &lt;= fundingStartBlock+25200) { // First Week Bonus   +40% = 1,400 EBET  = 1 ETH  [blocks: s+25 -&gt; s+45]
        tokensPerEthPrice=1400;
      } else if (block.number &gt;= fundingStartBlock+25201 &amp;&amp; block.number &lt;= fundingStartBlock+50400) { // Second Week Bonus  +30% = 1,300 EBET  = 1 ETH  [blocks: s+46 -&gt; s+65]
        tokensPerEthPrice=1300;
      } else if (block.number &gt;= fundingStartBlock+50401 &amp;&amp; block.number &lt;= fundingStartBlock+75600) { // Third Week Bonus   +25% = 1,250 EBET  = 1 ETH  [blocks: s+66 -&gt; s+85]
        tokensPerEthPrice=1250;
      } else if (block.number &gt;= fundingStartBlock+75601 &amp;&amp; block.number &lt;= fundingEndBlock) { // Final Week Bonus   +15% = 1,150 EBET  = 1 ETH  [blocks: s+86 -&gt; endBlock]
        tokensPerEthPrice=1150;
      }
    }

    // default payable function when sending ether to this contract
    function () payable {
      require(msg.data.length == 0);
      BuyEBETtokens();
    }

    function BuyEBETtokens() payable {
      // 0. conditions (length, crowdsale setup, zero check, exceed funding contrib check, contract valid check, within funding block range check, balance overflow check etc)
      require(!(msg.value == 0)
      &amp;&amp; (isCrowdSaleSetup)
      &amp;&amp; (block.number &gt;= fundingStartBlock)
      &amp;&amp; (block.number &lt;= fundingEndBlock)
      &amp;&amp; (tokensRemaining &gt; 0));

      // 1. vars
      uint256 rewardTransferAmount    = 0;

      // 2. effects
      setPrice();
      amountRaisedInWei               = safeAdd(amountRaisedInWei,msg.value);
      rewardTransferAmount            = safeDiv(safeMul(msg.value,tokensPerEthPrice),10000000000000000);

      // 3. interaction
      tokensRemaining                 = safeSub(tokensRemaining, safeDiv(rewardTransferAmount,100));  // will cause throw if attempt to purchase over the token limit in one tx or at all once limit reached
      tokenReward.transfer(msg.sender, rewardTransferAmount);

      // 4. events
      fundValue[msg.sender]           = safeAdd(fundValue[msg.sender], msg.value);
      Transfer(this, msg.sender, msg.value);
      Buy(msg.sender, msg.value, rewardTransferAmount);
    }

    function beneficiaryMultiSigWithdraw(uint256 _amount) onlyOwner {
      require(areFundsReleasedToBeneficiary &amp;&amp; (amountRaisedInWei &gt;= fundingMinCapInWei));
      beneficiaryWallet.transfer(_amount);
    }

    function checkGoalReached() onlyOwner returns (bytes32 response) { // return crowdfund status to owner for each result case, update public constant
      // update state &amp; status variables
      require (isCrowdSaleSetup);
      if ((amountRaisedInWei &lt; fundingMinCapInWei) &amp;&amp; (block.number &lt;= fundingEndBlock &amp;&amp; block.number &gt;= fundingStartBlock)) { // ICO in progress, under softcap
        areFundsReleasedToBeneficiary = false;
        isCrowdSaleClosed = false;
        CurrentStatus = &quot;In progress (Eth &lt; Softcap)&quot;;
        return &quot;In progress (Eth &lt; Softcap)&quot;;
      } else if ((amountRaisedInWei &lt; fundingMinCapInWei) &amp;&amp; (block.number &lt; fundingStartBlock)) { // ICO has not started
        areFundsReleasedToBeneficiary = false;
        isCrowdSaleClosed = false;
        CurrentStatus = &quot;Crowdsale is setup&quot;;
        return &quot;Crowdsale is setup&quot;;
      } else if ((amountRaisedInWei &lt; fundingMinCapInWei) &amp;&amp; (block.number &gt; fundingEndBlock)) { // ICO ended, under softcap
        areFundsReleasedToBeneficiary = false;
        isCrowdSaleClosed = true;
        CurrentStatus = &quot;Unsuccessful (Eth &lt; Softcap)&quot;;
        return &quot;Unsuccessful (Eth &lt; Softcap)&quot;;
      } else if ((amountRaisedInWei &gt;= fundingMinCapInWei) &amp;&amp; (tokensRemaining == 0)) { // ICO ended, all tokens gone
          areFundsReleasedToBeneficiary = true;
          isCrowdSaleClosed = true;
          CurrentStatus = &quot;Successful (EBET &gt;= Hardcap)!&quot;;
          return &quot;Successful (EBET &gt;= Hardcap)!&quot;;
      } else if ((amountRaisedInWei &gt;= fundingMinCapInWei) &amp;&amp; (block.number &gt; fundingEndBlock) &amp;&amp; (tokensRemaining &gt; 0)) { // ICO ended, over softcap!
          areFundsReleasedToBeneficiary = true;
          isCrowdSaleClosed = true;
          CurrentStatus = &quot;Successful (Eth &gt;= Softcap)!&quot;;
          return &quot;Successful (Eth &gt;= Softcap)!&quot;;
      } else if ((amountRaisedInWei &gt;= fundingMinCapInWei) &amp;&amp; (tokensRemaining &gt; 0) &amp;&amp; (block.number &lt;= fundingEndBlock)) { // ICO in progress, over softcap!
        areFundsReleasedToBeneficiary = true;
        isCrowdSaleClosed = false;
        CurrentStatus = &quot;In progress (Eth &gt;= Softcap)!&quot;;
        return &quot;In progress (Eth &gt;= Softcap)!&quot;;
      }
      setPrice();
    }

    function refund() { // any contributor can call this to have their Eth returned. user&#39;s purchased EBET tokens are burned prior refund of Eth.
      //require minCap not reached
      require ((amountRaisedInWei &lt; fundingMinCapInWei)
      &amp;&amp; (isCrowdSaleClosed)
      &amp;&amp; (block.number &gt; fundingEndBlock)
      &amp;&amp; (fundValue[msg.sender] &gt; 0));

      //burn user&#39;s token EBET token balance, refund Eth sent
      uint256 ethRefund = fundValue[msg.sender];
      balancesArray[msg.sender] = 0;
      fundValue[msg.sender] = 0;
      Burn(msg.sender, ethRefund);

      //send Eth back, burn tokens
      msg.sender.transfer(ethRefund);
      Refund(msg.sender, ethRefund);
    }
}