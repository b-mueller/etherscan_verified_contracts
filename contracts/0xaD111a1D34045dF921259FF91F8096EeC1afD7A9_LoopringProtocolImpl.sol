/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity 0.4.18;
/// @title Utility Functions for uint
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="debabfb0b7bbb29eb2b1b1aeacb7b0b9f0b1acb9">[email&#160;protected]</a>&gt;
library MathUint {
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b &lt;= a);
        return a - b;
    }
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c &gt;= a);
    }
    function tolerantSub(uint a, uint b) internal pure returns (uint c) {
        return (a &gt;= b) ? a - b : 0;
    }
    /// @dev calculate the square of Coefficient of Variation (CV)
    /// https://en.wikipedia.org/wiki/Coefficient_of_variation
    function cvsquare(
        uint[] arr,
        uint scale
        )
        internal
        pure
        returns (uint)
    {
        uint len = arr.length;
        require(len &gt; 1);
        require(scale &gt; 0);
        uint avg = 0;
        for (uint i = 0; i &lt; len; i++) {
            avg += arr[i];
        }
        avg = avg / len;
        if (avg == 0) {
            return 0;
        }
        uint cvs = 0;
        uint s;
        uint item;
        for (i = 0; i &lt; len; i++) {
            item = arr[i];
            s = item &gt; avg ? item - avg : avg - item;
            cvs += mul(s, s);
        }
        return ((mul(mul(cvs, scale), scale) / avg) / avg) / (len - 1);
    }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title ERC20 Token Interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ec888d82858980ac8083839c9e85828bc2839e8b">[email&#160;protected]</a>&gt;
contract ERC20 {
    uint public totalSupply;
	
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address who) view public returns (uint256);
    function allowance(address owner, address spender) view public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title Loopring Token Exchange Protocol Contract Interface
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="680c0906010d0428040707181a01060f46071a0f">[email&#160;protected]</a>&gt;
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7f1410111813161e11183f1310100f0d16111851100d18">[email&#160;protected]</a>&gt;
contract LoopringProtocol {
    ////////////////////////////////////////////////////////////////////////////
    /// Constants                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    uint8   public constant FEE_SELECT_LRC               = 0;
    uint8   public constant FEE_SELECT_MARGIN_SPLIT      = 1;
    uint8   public constant FEE_SELECT_MAX_VALUE         = 1;
    uint8   public constant MARGIN_SPLIT_PERCENTAGE_BASE = 100;
    ////////////////////////////////////////////////////////////////////////////
    /// Events                                                               ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Event to emit if a ring is successfully mined.
    /// _amountsList is an array of:
    /// [_amountSList, _amountBList, _lrcRewardList, _lrcFeeList].
    event RingMined(
        uint                _ringIndex,
        bytes32     indexed _ringhash,
        address             _miner,
        address             _feeRecipient,
        bool                _isRinghashReserved,
        bytes32[]           _orderHashList,
        uint[4][]           _amountsList
    );
    event OrderCancelled(
        bytes32     indexed _orderHash,
        uint                _amountCancelled
    );
    event CutoffTimestampChanged(
        address     indexed _address,
        uint                _cutoff
    );
    ////////////////////////////////////////////////////////////////////////////
    /// Functions                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Submit a order-ring for validation and settlement.
    /// @param addressList  List of each order&#39;s owner and tokenS. Note that next
    ///                     order&#39;s `tokenS` equals this order&#39;s `tokenB`.
    /// @param uintArgsList List of uint-type arguments in this order:
    ///                     amountS, amountB, timestamp, ttl, salt, lrcFee,
    ///                     rateAmountS.
    /// @param uint8ArgsList -
    ///                     List of unit8-type arguments, in this order:
    ///                     marginSplitPercentageList, feeSelectionList.
    /// @param buyNoMoreThanAmountBList -
    ///                     This indicates when a order should be considered
    ///                     as &#39;completely filled&#39;.
    /// @param vList        List of v for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     v value of the ring signature.
    /// @param rList        List of r for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     r value of the ring signature.
    /// @param sList        List of s for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     s value of the ring signature.
    /// @param ringminer    The address that signed this tx.
    /// @param feeRecepient The recepient address for fee collection. If this is
    ///                     &#39;0x0&#39;, all fees will be paid to the address who had
    ///                     signed this transaction, not `msg.sender`. Noted if
    ///                     LRC need to be paid back to order owner as the result
    ///                     of fee selection model, LRC will also be sent from
    ///                     this address.
    function submitRing(
        address[2][]    addressList,
        uint[7][]       uintArgsList,
        uint8[2][]      uint8ArgsList,
        bool[]          buyNoMoreThanAmountBList,
        uint8[]         vList,
        bytes32[]       rList,
        bytes32[]       sList,
        address         ringminer,
        address         feeRecepient
        ) public;
    /// @dev Cancel a order. cancel amount(amountS or amountB) can be specified
    ///      in orderValues.
    /// @param addresses          owner, tokenS, tokenB
    /// @param orderValues        amountS, amountB, timestamp, ttl, salt, lrcFee,
    ///                           cancelAmountS, and cancelAmountB.
    /// @param buyNoMoreThanAmountB -
    ///                           This indicates when a order should be considered
    ///                           as &#39;completely filled&#39;.
    /// @param marginSplitPercentage -
    ///                           Percentage of margin split to share with miner.
    /// @param v                  Order ECDSA signature parameter v.
    /// @param r                  Order ECDSA signature parameters r.
    /// @param s                  Order ECDSA signature parameters s.
    function cancelOrder(
        address[3] addresses,
        uint[7]    orderValues,
        bool       buyNoMoreThanAmountB,
        uint8      marginSplitPercentage,
        uint8      v,
        bytes32    r,
        bytes32    s
        ) external;
    /// @dev   Set a cutoff timestamp to invalidate all orders whose timestamp
    ///        is smaller than or equal to the new value of the address&#39;s cutoff
    ///        timestamp.
    /// @param cutoff The cutoff timestamp, will default to `block.timestamp`
    ///        if it is 0.
    function setCutoff(uint cutoff) external;
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title Utility Functions for byte32
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="92f9fdfcf5fefbf3fcf5d2fefdfde2e0fbfcf5bcfde0f5">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="eb8f8a85828e87ab8784849b9982858cc584998c">[email&#160;protected]</a>&gt;.
library MathBytes32 {
    function xorReduce(
        bytes32[]   arr,
        uint        len
        )
        internal
        pure
        returns (bytes32 res)
    {
        res = arr[0];
        for (uint i = 1; i &lt; len; i++) {
            res ^= arr[i];
        }
    }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title Utility Functions for uint8
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c5aeaaaba2a9aca4aba285a9aaaab5b7acaba2ebaab7a2">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5c383d323539301c3033332c2e35323b72332e3b">[email&#160;protected]</a>&gt;.
library MathUint8 {
    function xorReduce(
        uint8[] arr,
        uint    len
        )
        internal
        pure
        returns (uint8 res)
    {
        res = arr[0];
        for (uint i = 1; i &lt; len; i++) {
            res ^= arr[i];
        }
    }
}
/// @title Ring Hash Registry Contract
/// @dev This contracts help reserve ringhashes for miners.
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="274c4849404b4e464940674b484857554e494009485540">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2c484d424549406c4043435c5e45424b02435e4b">[email&#160;protected]</a>&gt;.
contract RinghashRegistry {
    using MathBytes32   for bytes32[];
    using MathUint8     for uint8[];
    uint public blocksToLive;
    struct Submission {
        address ringminer;
        uint block;
    }
    mapping (bytes32 =&gt; Submission) submissions;
    ////////////////////////////////////////////////////////////////////////////
    /// Events                                                               ///
    ////////////////////////////////////////////////////////////////////////////
    event RinghashSubmitted(
        address indexed _ringminer,
        bytes32 indexed _ringhash
    );
    ////////////////////////////////////////////////////////////////////////////
    /// Constructor                                                          ///
    ////////////////////////////////////////////////////////////////////////////
    function RinghashRegistry(uint _blocksToLive)
        public
    {
        require(_blocksToLive &gt; 0);
        blocksToLive = _blocksToLive;
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Public Functions                                                     ///
    ////////////////////////////////////////////////////////////////////////////
    function submitRinghash(
        address     ringminer,
        bytes32     ringhash
        )
        public
    {
        require(canSubmit(ringhash, ringminer)); //, &quot;Ringhash submitted&quot;);
        submissions[ringhash] = Submission(ringminer, block.number);
        RinghashSubmitted(ringminer, ringhash);
    }
    function batchSubmitRinghash(
        address[]     ringminerList,
        bytes32[]     ringhashList
        )
        external
    {
        uint size = ringminerList.length;
        require(size &gt; 0);
        require(size == ringhashList.length);
        for (uint i = 0; i &lt; size; i++) {
            submitRinghash(ringminerList[i], ringhashList[i]);
        }
    }
    /// @dev Calculate the hash of a ring.
    function calculateRinghash(
        uint        ringSize,
        uint8[]     vList,
        bytes32[]   rList,
        bytes32[]   sList
        )
        private
        pure
        returns (bytes32)
    {
        require(
            ringSize == vList.length - 1 &amp;&amp; (
            ringSize == rList.length - 1 &amp;&amp; (
            ringSize == sList.length - 1))
        ); //, &quot;invalid ring data&quot;);
        return keccak256(
            vList.xorReduce(ringSize),
            rList.xorReduce(ringSize),
            sList.xorReduce(ringSize)
        );
    }
     /// return value attributes[2] contains the following values in this order:
     /// canSubmit, isReserved.
    function computeAndGetRinghashInfo(
        uint        ringSize,
        address     ringminer,
        uint8[]     vList,
        bytes32[]   rList,
        bytes32[]   sList
        )
        external
        view
        returns (bytes32 ringhash, bool[2] attributes)
    {
        ringhash = calculateRinghash(
            ringSize,
            vList,
            rList,
            sList
        );
        attributes[0] = canSubmit(ringhash, ringminer);
        attributes[1] = isReserved(ringhash, ringminer);
    }
    /// @return true if a ring&#39;s hash can be submitted;
    /// false otherwise.
    function canSubmit(
        bytes32 ringhash,
        address ringminer)
        public
        view
        returns (bool)
    {
        require(ringminer != 0x0);
        var submission = submissions[ringhash];
        address miner = submission.ringminer;
        return (
            miner == 0x0 || (
            submission.block + blocksToLive &lt; block.number) || (
            miner == ringminer)
        );
    }
    /// @return true if a ring&#39;s hash was submitted and still valid;
    /// false otherwise.
    function isReserved(
        bytes32 ringhash,
        address ringminer)
        public
        view
        returns (bool)
    {
        var submission = submissions[ringhash];
        return (
            submission.block + blocksToLive &gt;= block.number &amp;&amp; (
            submission.ringminer == ringminer)
        );
    }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      &quot;user permissions&quot;.
contract Ownable {
    address public owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /// @dev The Ownable constructor sets the original `owner` of the contract
    ///      to the sender.
    function Ownable() public {
        owner = msg.sender;
    }
    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /// @dev Allows the current owner to transfer control of the contract to a
    ///      newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != 0x0);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
/// @title Claimable
/// @dev Extension for the Ownable contract, where the ownership needs
///      to be claimed. This allows the new owner to accept the transfer.
contract Claimable is Ownable {
    address public pendingOwner;
    /// @dev Modifier throws if called by any account other than the pendingOwner.
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }
    /// @dev Allows the current owner to set the pendingOwner address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != 0x0 &amp;&amp; newOwner != owner);
        pendingOwner = newOwner;
    }
    /// @dev Allows the pendingOwner address to finalize the transfer.
    function claimOwnership() onlyPendingOwner public {
        OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = 0x0;
    }
}
/// @title Token Register Contract
/// @dev This contract maintains a list of tokens the Protocol supports.
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0f6460616863666e61684f6360607f7d66616821607d68">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5337323d3a363f133f3c3c23213a3d347d3c2134">[email&#160;protected]</a>&gt;.
contract TokenRegistry is Claimable {
    address[] public tokens;
    mapping (address =&gt; bool) tokenMap;
    mapping (string =&gt; address) tokenSymbolMap;
    function registerToken(address _token, string _symbol)
        external
        onlyOwner
    {
        require(_token != 0x0);
        require(!isTokenRegisteredBySymbol(_symbol));
        require(!isTokenRegistered(_token));
        tokens.push(_token);
        tokenMap[_token] = true;
        tokenSymbolMap[_symbol] = _token;
    }
    function unregisterToken(address _token, string _symbol)
        external
        onlyOwner
    {
        require(_token != 0x0);
        require(tokenSymbolMap[_symbol] == _token);
        delete tokenSymbolMap[_symbol];
        delete tokenMap[_token];
        for (uint i = 0; i &lt; tokens.length; i++) {
            if (tokens[i] == _token) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.length --;
                break;
            }
        }
    }
    function isTokenRegisteredBySymbol(string symbol)
        public
        view
        returns (bool)
    {
        return tokenSymbolMap[symbol] != 0x0;
    }
    function isTokenRegistered(address _token)
        public
        view
        returns (bool)
    {
        return tokenMap[_token];
    }
    function areAllTokensRegistered(address[] tokenList)
        external
        view
        returns (bool)
    {
        for (uint i = 0; i &lt; tokenList.length; i++) {
            if (!tokenMap[tokenList[i]]) {
                return false;
            }
        }
        return true;
    }
    function getAddressBySymbol(string symbol)
        external
        view
        returns (address)
    {
        return tokenSymbolMap[symbol];
    }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title TokenTransferDelegate
/// @dev Acts as a middle man to transfer ERC20 tokens on behalf of different
/// versions of Loopring protocol to avoid ERC20 re-authorization.
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="badedbd4d3dfd6fad6d5d5cac8d3d4dd94d5c8dd">[email&#160;protected]</a>&gt;.
contract TokenTransferDelegate is Claimable {
    using MathUint for uint;
    ////////////////////////////////////////////////////////////////////////////
    /// Variables                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    mapping(address =&gt; AddressInfo) private addressInfos;
    address public latestAddress;
    ////////////////////////////////////////////////////////////////////////////
    /// Structs                                                              ///
    ////////////////////////////////////////////////////////////////////////////
    struct AddressInfo {
        address previous;
        uint32  index;
        bool    authorized;
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Modifiers                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    modifier onlyAuthorized() {
        require(addressInfos[msg.sender].authorized);
        _;
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Events                                                               ///
    ////////////////////////////////////////////////////////////////////////////
    event AddressAuthorized(address indexed addr, uint32 number);
    event AddressDeauthorized(address indexed addr, uint32 number);
    ////////////////////////////////////////////////////////////////////////////
    /// Public Functions                                                     ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Add a Loopring protocol address.
    /// @param addr A loopring protocol address.
    function authorizeAddress(address addr)
        onlyOwner
        external
    {
        var addrInfo = addressInfos[addr];
        if (addrInfo.index != 0) { // existing
            if (addrInfo.authorized == false) { // re-authorize
                addrInfo.authorized = true;
                AddressAuthorized(addr, addrInfo.index);
            }
        } else {
            address prev = latestAddress;
            if (prev == 0x0) {
                addrInfo.index = 1;
                addrInfo.authorized = true;
            } else {
                addrInfo.previous = prev;
                addrInfo.index = addressInfos[prev].index + 1;
            }
            addrInfo.authorized = true;
            latestAddress = addr;
            AddressAuthorized(addr, addrInfo.index);
        }
    }
    /// @dev Remove a Loopring protocol address.
    /// @param addr A loopring protocol address.
    function deauthorizeAddress(address addr)
        onlyOwner
        external
    {
        uint32 index = addressInfos[addr].index;
        if (index != 0) {
            addressInfos[addr].authorized = false;
            AddressDeauthorized(addr, index);
        }
    }
    function isAddressAuthorized(address addr)
        public
        view
        returns (bool)
    {
        return addressInfos[addr].authorized;
    }
    function getLatestAuthorizedAddresses(uint max)
        external
        view
        returns (address[] addresses)
    {
        addresses = new address[](max);
        address addr = latestAddress;
        AddressInfo memory addrInfo;
        uint count = 0;
        while (addr != 0x0 &amp;&amp; count &lt; max) {
            addrInfo = addressInfos[addr];
            if (addrInfo.index == 0) {
                break;
            }
            addresses[count++] = addr;
            addr = addrInfo.previous;
        }
    }
    /// @dev Invoke ERC20 transferFrom method.
    /// @param token Address of token to transfer.
    /// @param from Address to transfer token from.
    /// @param to Address to transfer token to.
    /// @param value Amount of token to transfer.
    function transferToken(
        address token,
        address from,
        address to,
        uint    value)
        onlyAuthorized
        external
    {
        if (value &gt; 0 &amp;&amp; from != to) {
            require(
                ERC20(token).transferFrom(from, to, value)
            );
        }
    }
    function batchTransferToken(
        address lrcTokenAddress,
        address feeRecipient,
        bytes32[] batch)
        onlyAuthorized
        external
    {
        uint len = batch.length;
        require(len % 6 == 0);
        var lrc = ERC20(lrcTokenAddress);
        for (uint i = 0; i &lt; len; i += 6) {
            address owner = address(batch[i]);
            address prevOwner = address(batch[(i + len - 6) % len]);
            
            // Pay token to previous order, or to miner as previous order&#39;s
            // margin split or/and this order&#39;s margin split.
            var token = ERC20(address(batch[i + 1]));
            // Here batch[i+2] has been checked not to be 0.
            if (owner != prevOwner) {
                require(
                    token.transferFrom(owner, prevOwner, uint(batch[i + 2]))
                );
            }
            if (owner != feeRecipient) {
                bytes32 item = batch[i + 3];
                if (item != 0) {
                    require(
                        token.transferFrom(owner, feeRecipient, uint(item))
                    );
                } 
                item = batch[i + 4];
                if (item != 0) {
                    require(
                        lrc.transferFrom(feeRecipient, owner, uint(item))
                    );
                }
                item = batch[i + 5];
                if (item != 0) {
                    require(
                        lrc.transferFrom(owner, feeRecipient, uint(item))
                    );
                }
            }
        }
    }
}
/// @title Loopring Token Exchange Protocol Implementation Contract v1
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="294d4847404c4569454646595b40474e07465b4e">[email&#160;protected]</a>&gt;,
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="85eeeaebe2e9ece4ebe2c5e9eaeaf5f7ecebe2abeaf7e2">[email&#160;protected]</a>&gt;
///
/// Recognized contributing developers from the community:
///     https://github.com/Brechtpd
///     https://github.com/rainydio
///     https://github.com/BenjaminPrice
///     https://github.com/jonasshen
contract LoopringProtocolImpl is LoopringProtocol {
    using MathUint for uint;
    ////////////////////////////////////////////////////////////////////////////
    /// Variables                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    address public  lrcTokenAddress             = 0x0;
    address public  tokenRegistryAddress        = 0x0;
    address public  ringhashRegistryAddress     = 0x0;
    address public  delegateAddress             = 0x0;
    uint    public  maxRingSize                 = 0;
    uint64  public  ringIndex                   = 0;
    // Exchange rate (rate) is the amount to sell or sold divided by the amount
    // to buy or bought.
    //
    // Rate ratio is the ratio between executed rate and an order&#39;s original
    // rate.
    //
    // To require all orders&#39; rate ratios to have coefficient ofvariation (CV)
    // smaller than 2.5%, for an example , rateRatioCVSThreshold should be:
    //     `(0.025 * RATE_RATIO_SCALE)^2` or 62500.
    uint    public  rateRatioCVSThreshold       = 0;
    uint    public constant RATE_RATIO_SCALE    = 10000;
    uint64  public constant ENTERED_MASK        = 1 &lt;&lt; 63;
    // The following map is used to keep trace of order fill and cancellation
    // history.
    mapping (bytes32 =&gt; uint) public cancelledOrFilled;
    // A map from address to its cutoff timestamp.
    mapping (address =&gt; uint) public cutoffs;
    ////////////////////////////////////////////////////////////////////////////
    /// Structs                                                              ///
    ////////////////////////////////////////////////////////////////////////////
    struct Rate {
        uint amountS;
        uint amountB;
    }
    /// @param tokenS       Token to sell.
    /// @param tokenB       Token to buy.
    /// @param amountS      Maximum amount of tokenS to sell.
    /// @param amountB      Minimum amount of tokenB to buy if all amountS sold.
    /// @param timestamp    Indicating when this order is created/signed.
    /// @param ttl          Indicating after how many seconds from `timestamp`
    ///                     this order will expire.
    /// @param salt         A random number to make this order&#39;s hash unique.
    /// @param lrcFee       Max amount of LRC to pay for miner. The real amount
    ///                     to pay is proportional to fill amount.
    /// @param buyNoMoreThanAmountB -
    ///                     If true, this order does not accept buying more
    ///                     than `amountB`.
    /// @param marginSplitPercentage -
    ///                     The percentage of margin paid to miner.
    /// @param v            ECDSA signature parameter v.
    /// @param r            ECDSA signature parameters r.
    /// @param s            ECDSA signature parameters s.
    struct Order {
        address owner;
        address tokenS;
        address tokenB;
        uint    amountS;
        uint    amountB;
        uint    lrcFee;
        bool    buyNoMoreThanAmountB;
        uint8   marginSplitPercentage;
    }
    /// @param order        The original order
    /// @param orderHash    The order&#39;s hash
    /// @param feeSelection -
    ///                     A miner-supplied value indicating if LRC (value = 0)
    ///                     or margin split is choosen by the miner (value = 1).
    ///                     We may support more fee model in the future.
    /// @param rate         Exchange rate provided by miner.
    /// @param fillAmountS  Amount of tokenS to sell, calculated by protocol.
    /// @param lrcReward    The amount of LRC paid by miner to order owner in
    ///                     exchange for margin split.
    /// @param lrcFee       The amount of LR paid by order owner to miner.
    /// @param splitS      TokenS paid to miner.
    /// @param splitB      TokenB paid to miner.
    struct OrderState {
        Order   order;
        bytes32 orderHash;
        uint8   feeSelection;
        Rate    rate;
        uint    fillAmountS;
        uint    lrcReward;
        uint    lrcFee;
        uint    splitS;
        uint    splitB;
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Constructor                                                          ///
    ////////////////////////////////////////////////////////////////////////////
    function LoopringProtocolImpl(
        address _lrcTokenAddress,
        address _tokenRegistryAddress,
        address _ringhashRegistryAddress,
        address _delegateAddress,
        uint    _maxRingSize,
        uint    _rateRatioCVSThreshold
        )
        public
    {
        require(0x0 != _lrcTokenAddress);
        require(0x0 != _tokenRegistryAddress);
        require(0x0 != _ringhashRegistryAddress);
        require(0x0 != _delegateAddress);
        require(_maxRingSize &gt; 1);
        require(_rateRatioCVSThreshold &gt; 0);
        lrcTokenAddress = _lrcTokenAddress;
        tokenRegistryAddress = _tokenRegistryAddress;
        ringhashRegistryAddress = _ringhashRegistryAddress;
        delegateAddress = _delegateAddress;
        maxRingSize = _maxRingSize;
        rateRatioCVSThreshold = _rateRatioCVSThreshold;
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Public Functions                                                     ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Disable default function.
    function ()
        payable
        public
    {
        revert();
    }
    /// @dev Submit a order-ring for validation and settlement.
    /// @param addressList  List of each order&#39;s tokenS. Note that next order&#39;s
    ///                     `tokenS` equals this order&#39;s `tokenB`.
    /// @param uintArgsList List of uint-type arguments in this order:
    ///                     amountS, amountB, timestamp, ttl, salt, lrcFee,
    ///                     rateAmountS.
    /// @param uint8ArgsList -
    ///                     List of unit8-type arguments, in this order:
    ///                     marginSplitPercentageList,feeSelectionList.
    /// @param buyNoMoreThanAmountBList -
    ///                     This indicates when a order should be considered
    ///                     as &#39;completely filled&#39;.
    /// @param vList        List of v for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     v value of the ring signature.
    /// @param rList        List of r for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     r value of the ring signature.
    /// @param sList        List of s for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     s value of the ring signature.
    /// @param ringminer    The address that signed this tx.
    /// @param feeRecipient The Recipient address for fee collection. If this is
    ///                     &#39;0x0&#39;, all fees will be paid to the address who had
    ///                     signed this transaction, not `msg.sender`. Noted if
    ///                     LRC need to be paid back to order owner as the result
    ///                     of fee selection model, LRC will also be sent from
    ///                     this address.
    function submitRing(
        address[2][]  addressList,
        uint[7][]     uintArgsList,
        uint8[2][]    uint8ArgsList,
        bool[]        buyNoMoreThanAmountBList,
        uint8[]       vList,
        bytes32[]     rList,
        bytes32[]     sList,
        address       ringminer,
        address       feeRecipient
        )
        public
    {
        // Check if the highest bit of ringIndex is &#39;1&#39;.
        require(ringIndex &amp; ENTERED_MASK != ENTERED_MASK); // &quot;attempted to re-ent submitRing function&quot;);
        // Set the highest bit of ringIndex to &#39;1&#39;.
        ringIndex |= ENTERED_MASK;
        //Check ring size
        uint ringSize = addressList.length;
        require(ringSize &gt; 1 &amp;&amp; ringSize &lt;= maxRingSize); // &quot;invalid ring size&quot;);
        verifyInputDataIntegrity(
            ringSize,
            addressList,
            uintArgsList,
            uint8ArgsList,
            buyNoMoreThanAmountBList,
            vList,
            rList,
            sList
        );
        verifyTokensRegistered(ringSize, addressList);
        var (ringhash, ringhashAttributes) = RinghashRegistry(
            ringhashRegistryAddress
        ).computeAndGetRinghashInfo(
            ringSize,
            ringminer,
            vList,
            rList,
            sList
        );
        //Check if we can submit this ringhash.
        require(ringhashAttributes[0]); // &quot;Ring claimed by others&quot;);
        verifySignature(
            ringminer,
            ringhash,
            vList[ringSize],
            rList[ringSize],
            sList[ringSize]
        );
        //Assemble input data into structs so we can pass them to other functions.
        var orders = assembleOrders(
            addressList,
            uintArgsList,
            uint8ArgsList,
            buyNoMoreThanAmountBList,
            vList,
            rList,
            sList
        );
        if (feeRecipient == 0x0) {
            feeRecipient = ringminer;
        }
        handleRing(
            ringSize,
            ringhash,
            orders,
            ringminer,
            feeRecipient,
            ringhashAttributes[1]
        );
        ringIndex = (ringIndex ^ ENTERED_MASK) + 1;
    }
    /// @dev Cancel a order. cancel amount(amountS or amountB) can be specified
    ///      in orderValues.
    /// @param addresses          owner, tokenS, tokenB
    /// @param orderValues        amountS, amountB, timestamp, ttl, salt, lrcFee,
    ///                           cancelAmountS, and cancelAmountB.
    /// @param buyNoMoreThanAmountB -
    ///                           This indicates when a order should be considered
    ///                           as &#39;completely filled&#39;.
    /// @param marginSplitPercentage -
    ///                           Percentage of margin split to share with miner.
    /// @param v                  Order ECDSA signature parameter v.
    /// @param r                  Order ECDSA signature parameters r.
    /// @param s                  Order ECDSA signature parameters s.
    function cancelOrder(
        address[3] addresses,
        uint[7]    orderValues,
        bool       buyNoMoreThanAmountB,
        uint8      marginSplitPercentage,
        uint8      v,
        bytes32    r,
        bytes32    s
        )
        external
    {
        uint cancelAmount = orderValues[6];
        require(cancelAmount &gt; 0); // &quot;amount to cancel is zero&quot;);
        var order = Order(
            addresses[0],
            addresses[1],
            addresses[2],
            orderValues[0],
            orderValues[1],
            orderValues[5],
            buyNoMoreThanAmountB,
            marginSplitPercentage
        );
        require(msg.sender == order.owner); // &quot;cancelOrder not submitted by order owner&quot;);
        bytes32 orderHash = calculateOrderHash(
            order,
            orderValues[2], // timestamp
            orderValues[3], // ttl
            orderValues[4]  // salt
        );
        verifySignature(
            order.owner,
            orderHash,
            v,
            r,
            s
        );
        cancelledOrFilled[orderHash] = cancelledOrFilled[orderHash].add(cancelAmount);
        OrderCancelled(orderHash, cancelAmount);
    }
    /// @dev   Set a cutoff timestamp to invalidate all orders whose timestamp
    ///        is smaller than or equal to the new value of the address&#39;s cutoff
    ///        timestamp.
    /// @param cutoff The cutoff timestamp, will default to `block.timestamp`
    ///        if it is 0.
    function setCutoff(uint cutoff)
        external
    {
        uint t = (cutoff == 0 || cutoff &gt;= block.timestamp) ? block.timestamp : cutoff;
        require(cutoffs[msg.sender] &lt; t); // &quot;attempted to set cutoff to a smaller value&quot;
        cutoffs[msg.sender] = t;
        CutoffTimestampChanged(msg.sender, t);
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Internal &amp; Private Functions                                         ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Validate a ring.
    function verifyRingHasNoSubRing(
        uint          ringSize,
        OrderState[]  orders
        )
        private
        pure
    {
        // Check the ring has no sub-ring.
        for (uint i = 0; i &lt; ringSize - 1; i++) {
            address tokenS = orders[i].order.tokenS;
            for (uint j = i + 1; j &lt; ringSize; j++) {
                require(tokenS != orders[j].order.tokenS); // &quot;found sub-ring&quot;);
            }
        }
    }
    function verifyTokensRegistered(
        uint          ringSize,
        address[2][]  addressList
        )
        private
        view
    {
        // Extract the token addresses
        var tokens = new address[](ringSize);
        for (uint i = 0; i &lt; ringSize; i++) {
            tokens[i] = addressList[i][1];
        }
        // Test all token addresses at once
        require(
            TokenRegistry(tokenRegistryAddress).areAllTokensRegistered(tokens)
        ); // &quot;token not registered&quot;);
    }
    function handleRing(
        uint          ringSize,
        bytes32       ringhash,
        OrderState[]  orders,
        address       miner,
        address       feeRecipient,
        bool          isRinghashReserved
        )
        private
    {
        uint64 _ringIndex = ringIndex ^ ENTERED_MASK;
        address _lrcTokenAddress = lrcTokenAddress;
        var delegate = TokenTransferDelegate(delegateAddress);
                
        // Do the hard work.
        verifyRingHasNoSubRing(ringSize, orders);
        // Exchange rates calculation are performed by ring-miners as solidity
        // cannot get power-of-1/n operation, therefore we have to verify
        // these rates are correct.
        verifyMinerSuppliedFillRates(ringSize, orders);
        // Scale down each order independently by substracting amount-filled and
        // amount-cancelled. Order owner&#39;s current balance and allowance are
        // not taken into consideration in these operations.
        scaleRingBasedOnHistoricalRecords(delegate, ringSize, orders);
        // Based on the already verified exchange rate provided by ring-miners,
        // we can furthur scale down orders based on token balance and allowance,
        // then find the smallest order of the ring, then calculate each order&#39;s
        // `fillAmountS`.
        calculateRingFillAmount(ringSize, orders);
        // Calculate each order&#39;s `lrcFee` and `lrcRewrard` and splict how much
        // of `fillAmountS` shall be paid to matching order or miner as margin
        // split.
        calculateRingFees(
            delegate,
            ringSize,
            orders,
            feeRecipient,
            _lrcTokenAddress
        );
        /// Make transfers.
        var (orderHashList, amountsList) = settleRing(
            delegate,
            ringSize,
            orders,
            feeRecipient,
            _lrcTokenAddress
        );
        RingMined(
            _ringIndex,
            ringhash,
            miner,
            feeRecipient,
            isRinghashReserved,
            orderHashList,
            amountsList
        );
    }
    function settleRing(
        TokenTransferDelegate delegate,
        uint          ringSize,
        OrderState[]  orders,
        address       feeRecipient,
        address       _lrcTokenAddress
        )
        private
        returns(
        bytes32[] memory orderHashList,
        uint[4][] memory amountsList)
    {
        bytes32[] memory batch = new bytes32[](ringSize * 6); // ringSize * (owner + tokenS + 4 amounts)
        orderHashList = new bytes32[](ringSize);
        amountsList = new uint[4][](ringSize);
        uint p = 0;
        for (uint i = 0; i &lt; ringSize; i++) {
            var state = orders[i];
            var order = state.order;
            uint prevSplitB = orders[(i + ringSize - 1) % ringSize].splitB;
            uint nextFillAmountS = orders[(i + 1) % ringSize].fillAmountS;
            // Store owner and tokenS of every order
            batch[p] = bytes32(order.owner);
            batch[p+1] = bytes32(order.tokenS);
            // Store all amounts
            batch[p+2] = bytes32(state.fillAmountS - prevSplitB);
            batch[p+3] = bytes32(prevSplitB + state.splitS);
            batch[p+4] = bytes32(state.lrcReward);
            batch[p+5] = bytes32(state.lrcFee);
            p += 6;
            // Update fill records
            if (order.buyNoMoreThanAmountB) {
                cancelledOrFilled[state.orderHash] += nextFillAmountS;
            } else {
                cancelledOrFilled[state.orderHash] += state.fillAmountS;
            }
            orderHashList[i] = state.orderHash;
            amountsList[i][0] = state.fillAmountS + state.splitS;
            amountsList[i][1] = nextFillAmountS - state.splitB;
            amountsList[i][2] = state.lrcReward;
            amountsList[i][3] = state.lrcFee;
        }
        // Do all transactions
        delegate.batchTransferToken(_lrcTokenAddress, feeRecipient, batch);
    }
    /// @dev Verify miner has calculte the rates correctly.
    function verifyMinerSuppliedFillRates(
        uint          ringSize,
        OrderState[]  orders
        )
        private
        view
    {
        var rateRatios = new uint[](ringSize);
        uint _rateRatioScale = RATE_RATIO_SCALE;
        for (uint i = 0; i &lt; ringSize; i++) {
            uint s1b0 = orders[i].rate.amountS.mul(orders[i].order.amountB);
            uint s0b1 = orders[i].order.amountS.mul(orders[i].rate.amountB);
            require(s1b0 &lt;= s0b1); // &quot;miner supplied exchange rate provides invalid discount&quot;);
            rateRatios[i] = _rateRatioScale.mul(s1b0) / s0b1;
        }
        uint cvs = MathUint.cvsquare(rateRatios, _rateRatioScale);
        require(cvs &lt;= rateRatioCVSThreshold); // &quot;miner supplied exchange rate is not evenly discounted&quot;);
    }
    /// @dev Calculate each order&#39;s fee or LRC reward.
    function calculateRingFees(
        TokenTransferDelegate delegate,
        uint            ringSize,
        OrderState[]    orders,
        address         feeRecipient,
        address         _lrcTokenAddress
        )
        private
        view
    {
        bool checkedMinerLrcSpendable = false;
        uint minerLrcSpendable = 0;
        uint8 _marginSplitPercentageBase = MARGIN_SPLIT_PERCENTAGE_BASE;
        uint nextFillAmountS;
        for (uint i = 0; i &lt; ringSize; i++) {
            var state = orders[i];
            uint lrcReceiable = 0;
            if (state.lrcFee == 0) {
                // When an order&#39;s LRC fee is 0 or smaller than the specified fee,
                // we help miner automatically select margin-split.
                state.feeSelection = FEE_SELECT_MARGIN_SPLIT;
                state.order.marginSplitPercentage = _marginSplitPercentageBase;
            } else {
                uint lrcSpendable = getSpendable(
                    delegate,
                    _lrcTokenAddress,
                    state.order.owner
                );
                // If the order is selling LRC, we need to calculate how much LRC
                // is left that can be used as fee.
                if (state.order.tokenS == _lrcTokenAddress) {
                    lrcSpendable -= state.fillAmountS;
                }
                // If the order is buyign LRC, it will has more to pay as fee.
                if (state.order.tokenB == _lrcTokenAddress) {
                    nextFillAmountS = orders[(i + 1) % ringSize].fillAmountS;
                    lrcReceiable = nextFillAmountS;
                }
                uint lrcTotal = lrcSpendable + lrcReceiable;
                // If order doesn&#39;t have enough LRC, set margin split to 100%.
                if (lrcTotal &lt; state.lrcFee) {
                    state.lrcFee = lrcTotal;
                    state.order.marginSplitPercentage = _marginSplitPercentageBase;
                }
                if (state.lrcFee == 0) {
                    state.feeSelection = FEE_SELECT_MARGIN_SPLIT;
                }
            }
            if (state.feeSelection == FEE_SELECT_LRC) {
                if (lrcReceiable &gt; 0) {
                    if (lrcReceiable &gt;= state.lrcFee) {
                        state.splitB = state.lrcFee;
                        state.lrcFee = 0;
                    } else {
                        state.splitB = lrcReceiable;
                        state.lrcFee -= lrcReceiable;
                    }
                }
            } else if (state.feeSelection == FEE_SELECT_MARGIN_SPLIT) {
                // Only check the available miner balance when absolutely needed
                if (!checkedMinerLrcSpendable &amp;&amp; minerLrcSpendable &lt; state.lrcFee) {
                    checkedMinerLrcSpendable = true;
                    minerLrcSpendable = getSpendable(delegate, _lrcTokenAddress, feeRecipient);
                }
                // Only calculate split when miner has enough LRC;
                // otherwise all splits are 0.
                if (minerLrcSpendable &gt;= state.lrcFee) {
                    nextFillAmountS = orders[(i + 1) % ringSize].fillAmountS;
                    uint split;
                    if (state.order.buyNoMoreThanAmountB) {
                        split = (nextFillAmountS.mul(
                            state.order.amountS
                        ) / state.order.amountB).sub(
                            state.fillAmountS
                        );
                    } else {
                        split = nextFillAmountS.sub(
                            state.fillAmountS.mul(
                                state.order.amountB
                            ) / state.order.amountS
                        );
                    }
                    if (state.order.marginSplitPercentage != _marginSplitPercentageBase) {
                        split = split.mul(
                            state.order.marginSplitPercentage
                        ) / _marginSplitPercentageBase;
                    }
                    if (state.order.buyNoMoreThanAmountB) {
                        state.splitS = split;
                    } else {
                        state.splitB = split;
                    }
                    // This implicits order with smaller index in the ring will
                    // be paid LRC reward first, so the orders in the ring does
                    // mater.
                    if (split &gt; 0) {
                        minerLrcSpendable -= state.lrcFee;
                        state.lrcReward = state.lrcFee;
                    }
                }
                state.lrcFee = 0;
            } else {
                revert(); // &quot;unsupported fee selection value&quot;);
            }
        }
    }
    /// @dev Calculate each order&#39;s fill amount.
    function calculateRingFillAmount(
        uint          ringSize,
        OrderState[]  orders
        )
        private
        pure
    {
        uint smallestIdx = 0;
        uint i;
        uint j;
        for (i = 0; i &lt; ringSize; i++) {
            j = (i + 1) % ringSize;
            smallestIdx = calculateOrderFillAmount(
                orders[i],
                orders[j],
                i,
                j,
                smallestIdx
            );
        }
        for (i = 0; i &lt; smallestIdx; i++) {
            calculateOrderFillAmount(
                orders[i],
                orders[(i + 1) % ringSize],
                0,               // Not needed
                0,               // Not needed
                0                // Not needed
            );
        }
    }
    /// @return The smallest order&#39;s index.
    function calculateOrderFillAmount(
        OrderState        state,
        OrderState        next,
        uint              i,
        uint              j,
        uint              smallestIdx
        )
        private
        pure
        returns (uint newSmallestIdx)
    {
        // Default to the same smallest index
        newSmallestIdx = smallestIdx;
        uint fillAmountB = state.fillAmountS.mul(
            state.rate.amountB
        ) / state.rate.amountS;
        if (state.order.buyNoMoreThanAmountB) {
            if (fillAmountB &gt; state.order.amountB) {
                fillAmountB = state.order.amountB;
                state.fillAmountS = fillAmountB.mul(
                    state.rate.amountS
                ) / state.rate.amountB;
                newSmallestIdx = i;
            }
            state.lrcFee = state.order.lrcFee.mul(
                fillAmountB
            ) / state.order.amountB;
        } else {
            state.lrcFee = state.order.lrcFee.mul(
                state.fillAmountS
            ) / state.order.amountS;
        }
        if (fillAmountB &lt;= next.fillAmountS) {
            next.fillAmountS = fillAmountB;
        } else {
            newSmallestIdx = j;
        }
    }
    /// @dev Scale down all orders based on historical fill or cancellation
    ///      stats but key the order&#39;s original exchange rate.
    function scaleRingBasedOnHistoricalRecords(
        TokenTransferDelegate delegate,
        uint ringSize,
        OrderState[] orders
        )
        private
        view
    {
        for (uint i = 0; i &lt; ringSize; i++) {
            var state = orders[i];
            var order = state.order;
            uint amount;
            if (order.buyNoMoreThanAmountB) {
                amount = order.amountB.tolerantSub(
                    cancelledOrFilled[state.orderHash]
                );
                order.amountS = amount.mul(order.amountS) / order.amountB;
                order.lrcFee = amount.mul(order.lrcFee) / order.amountB;
                order.amountB = amount;
            } else {
                amount = order.amountS.tolerantSub(
                    cancelledOrFilled[state.orderHash]
                );
                order.amountB = amount.mul(order.amountB) / order.amountS;
                order.lrcFee = amount.mul(order.lrcFee) / order.amountS;
                order.amountS = amount;
            }
            require(order.amountS &gt; 0); // &quot;amountS is zero&quot;);
            require(order.amountB &gt; 0); // &quot;amountB is zero&quot;);
            
            uint availableAmountS = getSpendable(delegate, order.tokenS, order.owner);
            require(availableAmountS &gt; 0); // &quot;order spendable amountS is zero&quot;);
            state.fillAmountS = (
                order.amountS &lt; availableAmountS ?
                order.amountS : availableAmountS
            );
        }
    }
    /// @return Amount of ERC20 token that can be spent by this contract.
    function getSpendable(
        TokenTransferDelegate delegate,
        address tokenAddress,
        address tokenOwner
        )
        private
        view
        returns (uint)
    {
        var token = ERC20(tokenAddress);
        uint allowance = token.allowance(
            tokenOwner,
            address(delegate)
        );
        uint balance = token.balanceOf(tokenOwner);
        return (allowance &lt; balance ? allowance : balance);
    }
    /// @dev verify input data&#39;s basic integrity.
    function verifyInputDataIntegrity(
        uint          ringSize,
        address[2][]  addressList,
        uint[7][]     uintArgsList,
        uint8[2][]    uint8ArgsList,
        bool[]        buyNoMoreThanAmountBList,
        uint8[]       vList,
        bytes32[]     rList,
        bytes32[]     sList
        )
        private
        pure
    {
        require(ringSize == addressList.length); // &quot;ring data is inconsistent - addressList&quot;);
        require(ringSize == uintArgsList.length); // &quot;ring data is inconsistent - uintArgsList&quot;);
        require(ringSize == uint8ArgsList.length); // &quot;ring data is inconsistent - uint8ArgsList&quot;);
        require(ringSize == buyNoMoreThanAmountBList.length); // &quot;ring data is inconsistent - buyNoMoreThanAmountBList&quot;);
        require(ringSize + 1 == vList.length); // &quot;ring data is inconsistent - vList&quot;);
        require(ringSize + 1 == rList.length); // &quot;ring data is inconsistent - rList&quot;);
        require(ringSize + 1 == sList.length); // &quot;ring data is inconsistent - sList&quot;);
        // Validate ring-mining related arguments.
        for (uint i = 0; i &lt; ringSize; i++) {
            require(uintArgsList[i][6] &gt; 0); // &quot;order rateAmountS is zero&quot;);
            require(uint8ArgsList[i][1] &lt;= FEE_SELECT_MAX_VALUE); // &quot;invalid order fee selection&quot;);
        }
    }
    /// @dev        assmble order parameters into Order struct.
    /// @return     A list of orders.
    function assembleOrders(
        address[2][]    addressList,
        uint[7][]       uintArgsList,
        uint8[2][]      uint8ArgsList,
        bool[]          buyNoMoreThanAmountBList,
        uint8[]         vList,
        bytes32[]       rList,
        bytes32[]       sList
        )
        private
        view
        returns (OrderState[] orders)
    {
        uint ringSize = addressList.length;
        orders = new OrderState[](ringSize);
        for (uint i = 0; i &lt; ringSize; i++) {
            var uintArgs = uintArgsList[i];
        
            var order = Order(
                addressList[i][0],
                addressList[i][1],
                addressList[(i + 1) % ringSize][1],
                uintArgs[0],
                uintArgs[1],
                uintArgs[5],
                buyNoMoreThanAmountBList[i],
                uint8ArgsList[i][0]
            );
            bytes32 orderHash = calculateOrderHash(
                order,
                uintArgs[2], // timestamp
                uintArgs[3], // ttl
                uintArgs[4]  // salt
            );
            verifySignature(
                order.owner,
                orderHash,
                vList[i],
                rList[i],
                sList[i]
            );
            validateOrder(
                order,
                uintArgs[2], // timestamp
                uintArgs[3], // ttl
                uintArgs[4]  // salt
            );
            orders[i] = OrderState(
                order,
                orderHash,
                uint8ArgsList[i][1],  // feeSelection
                Rate(uintArgs[6], order.amountB),
                0,   // fillAmountS
                0,   // lrcReward
                0,   // lrcFee
                0,   // splitS
                0    // splitB
            );
        }
    }
    /// @dev validate order&#39;s parameters are OK.
    function validateOrder(
        Order        order,
        uint         timestamp,
        uint         ttl,
        uint         salt
        )
        private
        view
    {
        require(order.owner != 0x0); // &quot;invalid order owner&quot;);
        require(order.tokenS != 0x0); // &quot;invalid order tokenS&quot;);
        require(order.tokenB != 0x0); // &quot;invalid order tokenB&quot;);
        require(order.amountS != 0); // &quot;invalid order amountS&quot;);
        require(order.amountB != 0); // &quot;invalid order amountB&quot;);
        require(timestamp &lt;= block.timestamp); // &quot;order is too early to match&quot;);
        require(timestamp &gt; cutoffs[order.owner]); // &quot;order is cut off&quot;);
        require(ttl != 0); // &quot;order ttl is 0&quot;);
        require(timestamp + ttl &gt; block.timestamp); // &quot;order is expired&quot;);
        require(salt != 0); // &quot;invalid order salt&quot;);
        require(order.marginSplitPercentage &lt;= MARGIN_SPLIT_PERCENTAGE_BASE); // &quot;invalid order marginSplitPercentage&quot;);
    }
    /// @dev Get the Keccak-256 hash of order with specified parameters.
    function calculateOrderHash(
        Order        order,
        uint         timestamp,
        uint         ttl,
        uint         salt
        )
        private
        view
        returns (bytes32)
    {
        return keccak256(
            address(this),
            order.owner,
            order.tokenS,
            order.tokenB,
            order.amountS,
            order.amountB,
            timestamp,
            ttl,
            salt,
            order.lrcFee,
            order.buyNoMoreThanAmountB,
            order.marginSplitPercentage
        );
    }
    /// @dev Verify signer&#39;s signature.
    function verifySignature(
        address signer,
        bytes32 hash,
        uint8   v,
        bytes32 r,
        bytes32 s
        )
        private
        pure
    {
        require(
            signer == ecrecover(
                keccak256(&quot;\x19Ethereum Signed Message:\n32&quot;, hash),
                v,
                r,
                s
            )
        ); // &quot;invalid signature&quot;);
    }
}