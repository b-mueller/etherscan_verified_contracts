pragma solidity ^0.4.23;

// * dice2.win - fair games that pay Ether.
//
// * Ethereum smart contract, deployed at 0xD1CEeeefA68a6aF0A5f6046132D986066c7f9426.
//
// * Uses hybrid commit-reveal + block hash random number generation that is immune
//   to tampering by players, house and miners. Apart from being fully transparent,
//   this also allows arbitrarily high bets.
//
// * Refer to https://dice2.win/whitepaper.pdf for detailed description and proofs.

contract Dice2Win {
    /// *** Constants section

    // Each bet is deducted 1% in favour of the house, but no less than some minimum.
    // The lower bound is dictated by gas costs of the settleBet transaction, providing
    // headroom for up to 10 Gwei prices.
    uint constant HOUSE_EDGE_PERCENT = 1;
    uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;

    // Bets lower than this amount do not participate in jackpot rolls (and are
    // not deducted JACKPOT_FEE).
    uint constant MIN_JACKPOT_BET = 0.1 ether;

    // Chance to win jackpot (currently 0.1%) and fee deducted into jackpot fund.
    uint constant JACKPOT_MODULO = 1000;
    uint constant JACKPOT_FEE = 0.001 ether;

    // There is minimum and maximum bets.
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_AMOUNT = 300000 ether;

    // Modulo is a number of equiprobable outcomes in a game:
    //  - 2 for coin flip
    //  - 6 for dice
    //  - 6*6 = 36 for double dice
    //  - 100 for etheroll
    //  - 37 for roulette
    //  etc.
    // It&#39;s called so because 256-bit entropy is treated like a huge integer and
    // the remainder of its division by modulo is considered bet outcome.
    uint constant MAX_MODULO = 100;

    // For modulos below this threshold rolls are checked against a bit mask,
    // thus allowing betting on any combination of outcomes. For example, given
    // modulo 6 for dice, 101000 mask (base-2, big endian) means betting on
    // 4 and 6; for games with modulos higher than threshold (Etheroll), a simple
    // limit is used, allowing betting on any outcome in [0, N) range.
    //
    // The specific value is dictated by the fact that 256-bit intermediate
    // multiplication result allows implementing population count efficiently
    // for numbers that are up to 42 bits, and 40 is the highest multiple of
    // eight below 42.
    uint constant MAX_MASK_MODULO = 40;

    // This is a check on bet mask overflow.
    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;

    // EVM BLOCKHASH opcode can query no further than 256 blocks into the
    // past. Given that settleBet uses block hash of placeBet as one of
    // complementary entropy sources, we cannot process bets older than this
    // threshold. On rare occasions dice2.win croupier may fail to invoke
    // settleBet in this timespan due to technical issues or extreme Ethereum
    // congestion; such bets can be refunded via invoking refundBet.
    uint constant BET_EXPIRATION_BLOCKS = 250;

    // Some deliberately invalid address to initialize the secret signer with.
    // Forces maintainers to invoke setSecretSigner before processing any bets.
    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Standard contract ownership transfer.
    address public owner;
    address private nextOwner;

    // Adjustable max bet profit. Used to cap bets against dynamic odds.
    uint public maxProfit;

    // The address corresponding to a private key used to sign placeBet commits.
    address public secretSigner;

    // Accumulated jackpot fund.
    uint128 public jackpotSize;

    // Funds that are locked in potentially winning bets. Prevents contract from
    // committing to bets it cannot pay out.
    uint128 public lockedInBets;

    // A structure representing a single bet.
    struct Bet {
        // Wager amount in wei.
        uint amount;
        // Modulo of a game.
        uint8 modulo;
        // Number of winning outcomes, used to compute winning payment (* modulo/rollUnder),
        // and used instead of mask for games with modulo &gt; MAX_MASK_MODULO.
        uint8 rollUnder;
        // Block number of placeBet tx.
        uint40 placeBlockNumber;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        uint40 mask;
        // Address of a gambler, used to pay out winning bets.
        address gambler;
    }

    // Mapping from commits to all currently active &amp; processed bets.
    mapping (uint =&gt; Bet) bets;

    // Events that are issued to make statistic recovery easier.
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    event JackpotPayment(address indexed beneficiary, uint amount);

    // Constructor. Deliberately does not take any parameters.
    constructor () public {
        owner = msg.sender;
        secretSigner = DUMMY_ADDRESS;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require (msg.sender == owner, &quot;OnlyOwner methods called by non-owner.&quot;);
        _;
    }

    // Standard contract ownership transfer implementation,
    function approveNextOwner(address _nextOwner) external onlyOwner {
        require (_nextOwner != owner, &quot;Cannot approve current owner.&quot;);
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require (msg.sender == nextOwner, &quot;Can only accept preapproved new owner.&quot;);
        owner = nextOwner;
    }

    // Fallback function deliberately left empty. It&#39;s primary use case
    // is to top up the bank roll.
    function () public payable {
    }

    // See comment for &quot;secretSigner&quot; variable.
    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    // Change max bet reward. Setting this to zero effectively disables betting.
    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require (_maxProfit &lt; MAX_AMOUNT, &quot;maxProfit should be a sane number.&quot;);
        maxProfit = _maxProfit;
    }

    // This function is used to bump up the jackpot fund. Cannot be used to lower it.
    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require (increaseAmount &lt;= address(this).balance, &quot;Increase amount larger than balance.&quot;);
        require (jackpotSize + lockedInBets + increaseAmount &lt;= address(this).balance, &quot;Not enough funds.&quot;);
        jackpotSize += uint128(increaseAmount);
    }

    // Funds withdrawal to cover costs of dice2.win operation.
    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount &lt;= address(this).balance, &quot;Increase amount larger than balance.&quot;);
        require (jackpotSize + lockedInBets + withdrawAmount &lt;= address(this).balance, &quot;Not enough funds.&quot;);
        sendFunds(beneficiary, withdrawAmount, withdrawAmount);
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function kill() external onlyOwner {
        require (lockedInBets == 0, &quot;All bets should be processed (settled or refunded) before self-destruct.&quot;);
        selfdestruct(owner);
    }

    /// *** Betting logic

    // Bet states:
    //  amount == 0 &amp;&amp; gambler == 0 - &#39;clean&#39; (can place a bet)
    //  amount != 0 &amp;&amp; gambler != 0 - &#39;active&#39; (can be settled or refunded)
    //  amount == 0 &amp;&amp; gambler != 0 - &#39;processed&#39; (can clean storage)

    // Bet placing transaction - issued by the player.
    //  betMask         - bet outcomes bit mask for modulo &lt;= MAX_MASK_MODULO,
    //                    [0, betMask) for larger modulos.
    //  modulo          - game modulo.
    //  commitLastBlock - number of the maximum block where &quot;commit&quot; is still considered valid.
    //  commit          - Keccak256 hash of some secret &quot;reveal&quot; random number, to be supplied
    //                    by the dice2.win croupier bot in the settleBet transaction. Supplying
    //                    &quot;commit&quot; ensures that &quot;reveal&quot; cannot be changed behind the scenes
    //                    after placeBet have been mined.
    //  r, s            - components of ECDSA signature of (commitLastBlock, commit). v is
    //                    guaranteed to always equal 27.
    //
    // Commit, being essentially random 256-bit number, is used as a unique bet identifier in
    // the &#39;bets&#39; mapping.
    //
    // Commits are signed with a block limit to ensure that they are used at most once - otherwise
    // it would be possible for a miner to place a bet with a known commit/reveal pair and tamper
    // with the blockhash. Croupier guarantees that commitLastBlock will always be not greater than
    // placeBet block number plus BET_EXPIRATION_BLOCKS. See whitepaper for details.
    function placeBet(uint betMask, uint modulo, uint commitLastBlock, uint commit, bytes32 r, bytes32 s) external payable {
        // Check that the bet is in &#39;clean&#39; state.
        Bet storage bet = bets[commit];
        require (bet.gambler == address(0), &quot;Bet should be in a &#39;clean&#39; state.&quot;);

        // Validate input data ranges.
        uint amount = msg.value;
        require (modulo &gt; 1 &amp;&amp; modulo &lt;= MAX_MODULO, &quot;Modulo should be within range.&quot;);
        require (amount &gt;= MIN_BET &amp;&amp; amount &lt;= MAX_AMOUNT, &quot;Amount should be within range.&quot;);
        require (betMask &gt; 0 &amp;&amp; betMask &lt; MAX_BET_MASK, &quot;Mask should be within range.&quot;);

        // Check that commit is valid - it has not expired and its signature is valid.
        require (block.number &lt;= commitLastBlock, &quot;Commit has expired.&quot;);
        bytes32 signatureHash = keccak256(abi.encodePacked(uint40(commitLastBlock), commit));
        require (secretSigner == ecrecover(signatureHash, 27, r, s), &quot;ECDSA signature is not valid.&quot;);

        uint rollUnder;
        uint mask;

        if (modulo &lt;= MAX_MASK_MODULO) {
            // Small modulo games specify bet outcomes via bit mask.
            // rollUnder is a number of 1 bits in this mask (population count).
            // This magic looking formula is an efficient way to compute population
            // count on EVM for numbers below 2**40. For detailed proof consult
            // the dice2.win whitepaper.
            rollUnder = ((betMask * POPCNT_MULT) &amp; POPCNT_MASK) % POPCNT_MODULO;
            mask = betMask;
        } else {
            // Larger modulos specify the right edge of half-open interval of
            // winning bet outcomes.
            require (betMask &gt; 0 &amp;&amp; betMask &lt;= modulo, &quot;High modulo range, betMask larger than modulo.&quot;);
            rollUnder = betMask;
        }

        // Winning amount and jackpot increase.
        uint possibleWinAmount;
        uint jackpotFee;

        (possibleWinAmount, jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

        // Enforce max profit limit.
        require (possibleWinAmount &lt;= amount + maxProfit, &quot;maxProfit limit violation.&quot;);

        // Lock funds.
        lockedInBets += uint128(possibleWinAmount);
        jackpotSize += uint128(jackpotFee);

        // Check whether contract has enough funds to process this bet.
        require (jackpotSize + lockedInBets &lt;= address(this).balance, &quot;Cannot afford to lose this bet.&quot;);

        // Store bet parameters on blockchain.
        bet.amount = amount;
        bet.modulo = uint8(modulo);
        bet.rollUnder = uint8(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint40(mask);
        bet.gambler = msg.sender;
    }

    // Settlement transaction - can in theory be issued by anyone, but is designed to be
    // handled by the dice2.win croupier bot. To settle a bet with a specific &quot;commit&quot;,
    // settleBet should supply a &quot;reveal&quot; number that would Keccak256-hash to
    // &quot;commit&quot;. clean_commit is some previously &#39;processed&#39; bet, that will be moved into
    // &#39;clean&#39; state to prevent blockchain bloat and refund some gas.
    function settleBet(uint reveal, uint cleanCommit) external {
        // &quot;commit&quot; for bet settlement can only be obtained by hashing a &quot;reveal&quot;.
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        // Fetch bet parameters into local variables (to save gas).
        Bet storage bet = bets[commit];
        uint amount = bet.amount;
        uint modulo = bet.modulo;
        uint rollUnder = bet.rollUnder;
        uint placeBlockNumber = bet.placeBlockNumber;
        address gambler = bet.gambler;

        // Check that bet is in &#39;active&#39; state.
        require (amount != 0, &quot;Bet should be in an &#39;active&#39; state&quot;);

        // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).
        require (block.number &gt; placeBlockNumber, &quot;settleBet in the same block as placeBet, or before.&quot;);
        require (block.number &lt;= placeBlockNumber + BET_EXPIRATION_BLOCKS, &quot;Blockhash can&#39;t be queried by EVM.&quot;);

        // Move bet into &#39;processed&#39; state already.
        bet.amount = 0;

        // The RNG - combine &quot;reveal&quot; and blockhash of placeBet using Keccak256. Miners
        // are not aware of &quot;reveal&quot; and cannot deduce it from &quot;commit&quot; (as Keccak256
        // preimage is intractable), and house is unable to alter the &quot;reveal&quot; after
        // placeBet have been mined (as Keccak256 collision finding is also intractable).
        bytes32 entropy = keccak256(abi.encodePacked(reveal, blockhash(placeBlockNumber)));

        // Do a roll by taking a modulo of entropy. Compute winning amount.
        uint dice = uint(entropy) % modulo;

        uint diceWinAmount;
        uint _jackpotFee;
        (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

        uint diceWin = 0;
        uint jackpotWin = 0;

        // Determine dice outcome.
        if (modulo &lt;= MAX_MASK_MODULO) {
            // For small modulo games, check the outcome against a bit mask.
            if ((2 ** dice) &amp; bet.mask != 0) {
                diceWin = diceWinAmount;
            }

        } else {
            // For larger modulos, check inclusion into half-open interval.
            if (dice &lt; rollUnder) {
                diceWin = diceWinAmount;
            }

        }

        // Unlock the bet amount, regardless of the outcome.
        lockedInBets -= uint128(diceWinAmount);

        // Roll for a jackpot (if eligible).
        if (amount &gt;= MIN_JACKPOT_BET) {
            // The second modulo, statistically independent from the &quot;main&quot; dice roll.
            // Effectively you are playing two games at once!
            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

            // Bingo!
            if (jackpotRng == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }

        // Log jackpot win.
        if (jackpotWin &gt; 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

        // Send the funds to gambler.
        sendFunds(gambler, diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin, diceWin);

        // Clear storage of some previous bet.
        if (cleanCommit == 0) {
            return;
        }

        clearProcessedBet(cleanCommit);
    }

    // Refund transaction - return the bet amount of a roll that was not processed in a
    // due timeframe. Processing such blocks is not possible due to EVM limitations (see
    // BET_EXPIRATION_BLOCKS comment above for details). In case you ever find yourself
    // in a situation like this, just contact the dice2.win support, however nothing
    // precludes you from invoking this method yourself.
    function refundBet(uint commit) external {
        // Check that bet is in &#39;active&#39; state.
        Bet storage bet = bets[commit];
        uint amount = bet.amount;

        require (amount != 0, &quot;Bet should be in an &#39;active&#39; state&quot;);

        // Check that bet has already expired.
        require (block.number &gt; bet.placeBlockNumber + BET_EXPIRATION_BLOCKS, &quot;Blockhash can&#39;t be queried by EVM.&quot;);

        // Move bet into &#39;processed&#39; state, release funds.
        bet.amount = 0;

        uint diceWinAmount;
        uint jackpotFee;
        (diceWinAmount, jackpotFee) = getDiceWinAmount(amount, bet.modulo, bet.rollUnder);

        lockedInBets -= uint128(diceWinAmount);
        jackpotSize -= uint128(jackpotFee);

        // Send the refund.
        sendFunds(bet.gambler, amount, amount);
    }

    // A helper routine to bulk clean the storage.
    function clearStorage(uint[] cleanCommits) external {
        uint length = cleanCommits.length;

        for (uint i = 0; i &lt; length; i++) {
            clearProcessedBet(cleanCommits[i]);
        }
    }

    // Helper routine to move &#39;processed&#39; bets into &#39;clean&#39; state.
    function clearProcessedBet(uint commit) private {
        Bet storage bet = bets[commit];

        // Do not overwrite active bets with zeros; additionally prevent cleanup of bets
        // for which commit signatures may have not expired yet (see whitepaper for details).
        if (bet.amount != 0 || block.number &lt;= bet.placeBlockNumber + BET_EXPIRATION_BLOCKS) {
            return;
        }

        // Zero out the remaining storage (amount was zeroed before, delete would consume 5k
        // more gas).
        bet.modulo = 0;
        bet.rollUnder = 0;
        bet.placeBlockNumber = 0;
        bet.mask = 0;
        bet.gambler = address(0);
    }

    // Get the expected win amount after house edge is subtracted.
    function getDiceWinAmount(uint amount, uint modulo, uint rollUnder) private pure returns (uint winAmount, uint jackpotFee) {
        require (0 &lt; rollUnder &amp;&amp; rollUnder &lt;= modulo, &quot;Win probability out of range.&quot;);

        jackpotFee = amount &gt;= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;

        uint houseEdge = amount * HOUSE_EDGE_PERCENT / 100;

        if (houseEdge &lt; HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        require (houseEdge + jackpotFee &lt;= amount, &quot;Bet doesn&#39;t even cover house edge.&quot;);
        winAmount = (amount - houseEdge - jackpotFee) * modulo / rollUnder;
    }

    // Helper routine to process the payment.
    function sendFunds(address beneficiary, uint amount, uint successLogAmount) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }

    // This are some constants making O(1) population count in placeBet possible.
    // See whitepaper for intuition and proofs behind it.
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;
}