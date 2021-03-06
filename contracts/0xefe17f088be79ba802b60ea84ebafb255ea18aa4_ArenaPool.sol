/* ==================================================================== */
/* Copyright (c) 2018 The ether.online Project.  All rights reserved.
/* 
/* https://ether.online  The first RPG game of blockchain 
/*  
/* authors <span class="__cf_email__" data-cfemail="02706b61696a776c7667702c716a676c42656f636b6e2c616d6f">[email&#160;protected]</span>   
/*         <span class="__cf_email__" data-cfemail="d3a0b6a0a6bdb7babdb493b4beb2babffdb0bcbe">[email&#160;protected]</span>            
/* ==================================================================== */

pragma solidity ^0.4.20;

contract AccessAdmin {
    bool public isPaused = false;
    address public addrAdmin;  

    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);

    function AccessAdmin() public {
        addrAdmin = msg.sender;
    }  


    modifier onlyAdmin() {
        require(msg.sender == addrAdmin);
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused);
        _;
    }

    modifier whenPaused {
        require(isPaused);
        _;
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0));
        AdminTransferred(addrAdmin, _newAdmin);
        addrAdmin = _newAdmin;
    }

    function doPause() external onlyAdmin whenNotPaused {
        isPaused = true;
    }

    function doUnpause() external onlyAdmin whenPaused {
        isPaused = false;
    }
}

contract AccessService is AccessAdmin {
    address public addrService;
    address public addrFinance;

    modifier onlyService() {
        require(msg.sender == addrService);
        _;
    }

    modifier onlyFinance() {
        require(msg.sender == addrFinance);
        _;
    }

    function setService(address _newService) external {
        require(msg.sender == addrService || msg.sender == addrAdmin);
        require(_newService != address(0));
        addrService = _newService;
    }

    function setFinance(address _newFinance) external {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_newFinance != address(0));
        addrFinance = _newFinance;
    }

    function withdraw(address _target, uint256 _amount) 
        external 
    {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_amount &gt; 0);
        address receiver = _target == address(0) ? addrFinance : _target;
        uint256 balance = this.balance;
        if (_amount &lt; balance) {
            receiver.transfer(_amount);
        } else {
            receiver.transfer(this.balance);
        }      
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

contract ArenaPool is AccessService {
    using SafeMath for uint256;

    event SendArenaSuccesss(uint64 flag, uint256 oldBalance, uint256 sendVal);
    event ArenaTimeClear(uint256 newVal);
    uint64 public nextArenaTime;
    uint256 maxArenaOneDay = 30;

    function ArenaPool() public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;
    }

    function() external payable {

    }

    function getBalance() external view returns(uint256) {
        return this.balance;
    }

    function clearNextArenaTime() external onlyService {
        nextArenaTime = 0;
        ArenaTimeClear(0);
    }

    function setMaxArenaOneDay(uint256 val) external onlyAdmin {
        require(val &gt; 0 &amp;&amp; val &lt; 100);
        require(val != maxArenaOneDay);
        maxArenaOneDay = val;
    }

    function sendArena(address[] winners, uint256[] amounts, uint64 _flag) 
        external 
        onlyService 
        whenNotPaused
    {
        uint64 tmNow = uint64(block.timestamp);
        uint256 length = winners.length;
        require(length == amounts.length);
        require(length &lt;= 100);

        uint256 sum = 0;
        for (uint32 i = 0; i &lt; length; ++i) {
            sum = sum.add(amounts[i]);
        }
        uint256 balance = this.balance;
        require((sum.mul(100).div(balance)) &lt;= maxArenaOneDay);

        address addrZero = address(0);
        for (uint32 j = 0; j &lt; length; ++j) {
            if (winners[j] != addrZero) {
                winners[j].transfer(amounts[j]);
            }
        }
        nextArenaTime = tmNow + 21600;
        SendArenaSuccesss(_flag, balance, sum);
    }
}