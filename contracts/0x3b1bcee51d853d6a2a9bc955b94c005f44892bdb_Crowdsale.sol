pragma solidity ^0.4.21;


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
        uint256 c = a / b;
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


interface ERC20 {
    function transfer (address _beneficiary, uint256 _tokenAmount) external returns (bool);
    function mint (address _to, uint256 _amount) external returns (bool);
}


contract Ownable {
    address public owner;
    function Ownable() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}


contract Crowdsale is Ownable {
    using SafeMath for uint256;

    modifier onlyWhileOpen {
        require(
            (now &gt;= preICOStartDate &amp;&amp; now &lt; preICOEndDate) ||
            (now &gt;= ICOStartDate &amp;&amp; now &lt; ICOEndDate)
        );
        _;
    }

    modifier onlyWhileICOOpen {
        require(now &gt;= ICOStartDate &amp;&amp; now &lt; ICOEndDate);
        _;
    }

    // The token being sold
    ERC20 public token;

    // Address where funds are collected
    address public wallet;

    // Адрес оператора бекЭнда для управления вайтлистом
    address public backendOperator = 0xd2420C5fDdA15B26AC3E13522e5cCD62CEB50e5F;

    // Сколько токенов покупатель получает за 1 эфир
    uint256 public rate = 100;

    // Сколько эфиров привлечено в ходе PreICO, wei
    uint256 public preICOWeiRaised = 1850570000000000000000;

    // Сколько эфиров привлечено в ходе ICO, wei
    uint256 public ICOWeiRaised;

    // Цена ETH в центах
    uint256 public ETHUSD;

    // Дата начала PreICO
    uint256 public preICOStartDate;

    // Дата окончания PreICO
    uint256 public preICOEndDate;

    // Дата начала ICO
    uint256 public ICOStartDate;

    // Дата окончания ICO
    uint256 public ICOEndDate;

    // Минимальный объем привлечения средств в ходе ICO в центах
    uint256 public softcap = 300000000;

    // Потолок привлечения средств в ходе ICO в центах
    uint256 public hardcap = 2500000000;

    // Бонус реферала, %
    uint8 public referalBonus = 3;

    // Бонус приглашенного рефералом, %
    uint8 public invitedByReferalBonus = 2;

    // Whitelist
    mapping(address =&gt; bool) public whitelist;

    // Инвесторы, которые купили токен
    mapping (address =&gt; uint256) public investors;

    event TokenPurchase(address indexed buyer, uint256 value, uint256 amount);

    function Crowdsale(
        address _wallet,
        uint256 _preICOStartDate,
        uint256 _preICOEndDate,
        uint256 _ICOStartDate,
        uint256 _ICOEndDate,
        uint256 _ETHUSD
    ) public {
        require(_preICOEndDate &gt; _preICOStartDate);
        require(_ICOStartDate &gt; _preICOEndDate);
        require(_ICOEndDate &gt; _ICOStartDate);

        wallet = _wallet;
        preICOStartDate = _preICOStartDate;
        preICOEndDate = _preICOEndDate;
        ICOStartDate = _ICOStartDate;
        ICOEndDate = _ICOEndDate;
        ETHUSD = _ETHUSD;
    }

    modifier backEnd() {
        require(msg.sender == backendOperator || msg.sender == owner);
        _;
    }

    /* Публичные методы */

    // Установить стоимость токена
    function setRate (uint16 _rate) public onlyOwner {
        require(_rate &gt; 0);
        rate = _rate;
    }

    // Установить адрес кошелька для сбора средств
    function setWallet (address _wallet) public onlyOwner {
        require (_wallet != 0x0);
        wallet = _wallet;
    }

    // Установить торгуемый токен
    function setToken (ERC20 _token) public onlyOwner {
        token = _token;
    }

    // Установить дату начала PreICO
    function setPreICOStartDate (uint256 _preICOStartDate) public onlyOwner {
        require(_preICOStartDate &lt; preICOEndDate);
        preICOStartDate = _preICOStartDate;
    }

    // Установить дату окончания PreICO
    function setPreICOEndDate (uint256 _preICOEndDate) public onlyOwner {
        require(_preICOEndDate &gt; preICOStartDate);
        preICOEndDate = _preICOEndDate;
    }

    // Установить дату начала ICO
    function setICOStartDate (uint256 _ICOStartDate) public onlyOwner {
        require(_ICOStartDate &lt; ICOEndDate);
        ICOStartDate = _ICOStartDate;
    }

    // Установить дату окончания PreICO
    function setICOEndDate (uint256 _ICOEndDate) public onlyOwner {
        require(_ICOEndDate &gt; ICOStartDate);
        ICOEndDate = _ICOEndDate;
    }

    // Установить стоимость эфира в центах
    function setETHUSD (uint256 _ETHUSD) public onlyOwner {
        ETHUSD = _ETHUSD;
    }

    // Установить оператора БекЭнда для управления вайтлистом
    function setBackendOperator(address newOperator) public onlyOwner {
        backendOperator = newOperator;
    }

    function () external payable {
        address beneficiary = msg.sender;
        uint256 weiAmount = msg.value;
        uint256 tokens;

        if(_isPreICO()){

            _preValidatePreICOPurchase(beneficiary, weiAmount);
            tokens = weiAmount.mul(rate.add(rate.mul(30).div(100)));
            preICOWeiRaised = preICOWeiRaised.add(weiAmount);
            wallet.transfer(weiAmount);
            investors[beneficiary] = weiAmount;
            _deliverTokens(beneficiary, tokens);
            emit TokenPurchase(beneficiary, weiAmount, tokens);

        } else if(_isICO()){

            _preValidateICOPurchase(beneficiary, weiAmount);
            tokens = _getTokenAmountWithBonus(weiAmount);
            ICOWeiRaised = ICOWeiRaised.add(weiAmount);
            investors[beneficiary] = weiAmount;
            _deliverTokens(beneficiary, tokens);
            emit TokenPurchase(beneficiary, weiAmount, tokens);

        }
    }

    // Покупка токенов с реферальным бонусом
    function buyTokensWithReferal(address _referal) public onlyWhileICOOpen payable {
        address beneficiary = msg.sender;
        uint256 weiAmount = msg.value;

        _preValidateICOPurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmountWithBonus(weiAmount).add(_getTokenAmountWithReferal(weiAmount, 2));
        uint256 referalTokens = _getTokenAmountWithReferal(weiAmount, 3);

        ICOWeiRaised = ICOWeiRaised.add(weiAmount);
        investors[beneficiary] = weiAmount;

        _deliverTokens(beneficiary, tokens);
        _deliverTokens(_referal, referalTokens);

        emit TokenPurchase(beneficiary, weiAmount, tokens);
    }

    // Добавить адрес в whitelist
    function addToWhitelist(address _beneficiary) public backEnd {
        whitelist[_beneficiary] = true;
    }

    // Добавить несколько адресов в whitelist
    function addManyToWhitelist(address[] _beneficiaries) public backEnd {
        for (uint256 i = 0; i &lt; _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    // Исключить адрес из whitelist
    function removeFromWhitelist(address _beneficiary) public backEnd {
        whitelist[_beneficiary] = false;
    }

    // Узнать истек ли срок проведения PreICO
    function hasPreICOClosed() public view returns (bool) {
        return now &gt; preICOEndDate;
    }

    // Узнать истек ли срок проведения ICO
    function hasICOClosed() public view returns (bool) {
        return now &gt; ICOEndDate;
    }

    // Перевести собранные средства на кошелек для сбора
    function forwardFunds () public onlyOwner {
        require(now &gt; ICOEndDate);
        require((preICOWeiRaised.add(ICOWeiRaised)).mul(ETHUSD).div(10**18) &gt;= softcap);

        wallet.transfer(ICOWeiRaised);
    }

    // Вернуть проинвестированные средства, если не был достигнут softcap
    function refund() public {
        require(now &gt; ICOEndDate);
        require(preICOWeiRaised.add(ICOWeiRaised).mul(ETHUSD).div(10**18) &lt; softcap);
        require(investors[msg.sender] &gt; 0);

        address investor = msg.sender;
        investor.transfer(investors[investor]);
    }


    /* Внутренние методы */

    // Проверка актуальности PreICO
    function _isPreICO() internal view returns(bool) {
        return now &gt;= preICOStartDate &amp;&amp; now &lt; preICOEndDate;
    }

    // Проверка актуальности ICO
    function _isICO() internal view returns(bool) {
        return now &gt;= ICOStartDate &amp;&amp; now &lt; ICOEndDate;
    }

    // Валидация перед покупкой токенов

    function _preValidatePreICOPurchase(address _beneficiary, uint256 _weiAmount) internal view {
        require(_weiAmount != 0);
        require(whitelist[_beneficiary]);
        require(now &gt;= preICOStartDate &amp;&amp; now &lt;= preICOEndDate);
    }

    function _preValidateICOPurchase(address _beneficiary, uint256 _weiAmount) internal view {
        require(_weiAmount != 0);
        require(whitelist[_beneficiary]);
        require((preICOWeiRaised + ICOWeiRaised + _weiAmount).mul(ETHUSD).div(10**18) &lt;= hardcap);
        require(now &gt;= ICOStartDate &amp;&amp; now &lt;= ICOEndDate);
    }

    // Подсчет бонусов с учетом бонусов за этап ICO и объем инвестиций
    function _getTokenAmountWithBonus(uint256 _weiAmount) internal view returns(uint256) {
        uint256 baseTokenAmount = _weiAmount.mul(rate);
        uint256 tokenAmount = baseTokenAmount;
        uint256 usdAmount = _weiAmount.mul(ETHUSD).div(10**18);

        // Считаем бонусы за объем инвестиций
        if(usdAmount &gt;= 10000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(7).div(100));
        } else if(usdAmount &gt;= 5000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(5).div(100));
        } else if(usdAmount &gt;= 1000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(3).div(100));
        }

        // Считаем бонусы за этап ICO
        if(now &lt; ICOStartDate + 30 days) {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(20).div(100));
        } else if(now &lt; ICOStartDate + 60 days) {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(15).div(100));
        } else if(now &lt; ICOStartDate + 90 days) {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(10).div(100));
        } else {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(5).div(100));
        }

        return tokenAmount;
    }

    // Подсчет бонусов с учетом бонусов реферальной системы
    function _getTokenAmountWithReferal(uint256 _weiAmount, uint8 _percent) internal view returns(uint256) {
        return _weiAmount.mul(rate).mul(_percent).div(100);
    }

    // Перевод токенов
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.mint(_beneficiary, _tokenAmount);
    }
}