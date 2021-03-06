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
pragma solidity 0.4.19;
/// @title Utility Functions for uint8
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d6bdb9b8b1babfb7b8b196bab9b9a6a4bfb8b1f8b9a4b1">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4b2f2a25222e270b2724243b3922252c6524392c">[email&#160;protected]</a>&gt;.
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
/// @title Utility Functions for uint
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0a6e6b64636f664a6665657a7863646d2465786d">[email&#160;protected]</a>&gt;
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
/// @title Utility Functions for byte32
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="42292d2c252e2b232c25022e2d2d32302b2c256c2d3025">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b2d6d3dcdbd7def2deddddc2c0dbdcd59cddc0d5">[email&#160;protected]</a>&gt;.
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
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b4d0d5daddd1d8f4d8dbdbc4c6dddad39adbc6d3">[email&#160;protected]</a>&gt;
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
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2f4b4e41464a436f4340405f5d46414801405d48">[email&#160;protected]</a>&gt;
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="cea5a1a0a9a2a7afa0a98ea2a1a1bebca7a0a9e0a1bca9">[email&#160;protected]</a>&gt;
contract LoopringProtocol {
    ////////////////////////////////////////////////////////////////////////////
    /// Constants                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    uint8   public constant MARGIN_SPLIT_PERCENTAGE_BASE = 100;
    ////////////////////////////////////////////////////////////////////////////
    /// Events                                                               ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Event to emit if a ring is successfully mined.
    /// _amountsList is an array of:
    /// [_amountS, _amountB, _lrcReward, _lrcFee, splitS, splitB].
    event RingMined(
        uint                _ringIndex,
        bytes32     indexed _ringHash,
        address             _miner,
        address             _feeRecipient,
        bytes32[]           _orderHashList,
        uint[6][]           _amountsList
    );
    event OrderCancelled(
        bytes32     indexed _orderHash,
        uint                _amountCancelled
    );
    event AllOrdersCancelled(
        address     indexed _address,
        uint                _cutoff
    );
    event OrdersCancelled(
        address     indexed _address,
        address             _token1,
        address             _token2,
        uint                _cutoff
    );
    ////////////////////////////////////////////////////////////////////////////
    /// Functions                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Cancel a order. cancel amount(amountS or amountB) can be specified
    ///      in orderValues.
    /// @param addresses          owner, tokenS, tokenB, authAddr
    /// @param orderValues        amountS, amountB, validSince (second),
    ///                           validUntil (second), lrcFee, walletId, and
    ///                           cancelAmount.
    /// @param buyNoMoreThanAmountB -
    ///                           This indicates when a order should be considered
    ///                           as &#39;completely filled&#39;.
    /// @param marginSplitPercentage -
    ///                           Percentage of margin split to share with miner.
    /// @param v                  Order ECDSA signature parameter v.
    /// @param r                  Order ECDSA signature parameters r.
    /// @param s                  Order ECDSA signature parameters s.
    function cancelOrder(
        address[4] addresses,
        uint[7]    orderValues,
        bool       buyNoMoreThanAmountB,
        uint8      marginSplitPercentage,
        uint8      v,
        bytes32    r,
        bytes32    s
        ) external;
    /// @dev   Set a cutoff timestamp to invalidate all orders whose timestamp
    ///        is smaller than or equal to the new value of the address&#39;s cutoff
    ///        timestamp, for a specific trading pair.
    /// @param cutoff The cutoff timestamp, will default to `block.timestamp`
    ///        if it is 0.
    function cancelAllOrdersByTradingPair(
        address token1,
        address token2,
        uint cutoff
        ) external;
    /// @dev   Set a cutoff timestamp to invalidate all orders whose timestamp
    ///        is smaller than or equal to the new value of the address&#39;s cutoff
    ///        timestamp.
    /// @param cutoff The cutoff timestamp, will default to `block.timestamp`
    ///        if it is 0.
    function cancelAllOrders(uint cutoff) external;
    /// @dev Submit a order-ring for validation and settlement.
    /// @param addressList  List of each order&#39;s owner, tokenS, and authAddr.
    ///                     Note that next order&#39;s `tokenS` equals this order&#39;s
    ///                     `tokenB`.
    /// @param uintArgsList List of uint-type arguments in this order:
    ///                     amountS, amountB, validSince (second),
    ///                     validUntil (second), lrcFee, rateAmountS, and walletId.
    /// @param uint8ArgsList -
    ///                     List of unit8-type arguments, in this order:
    ///                     marginSplitPercentageList.
    /// @param buyNoMoreThanAmountBList -
    ///                     This indicates when a order should be considered
    /// @param vList        List of v for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     v value of the ring signature.
    /// @param rList        List of r for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     r value of the ring signature.
    /// @param sList        List of s for each order. This list is 1-larger than
    ///                     the previous lists, with the last element being the
    ///                     s value of the ring signature.
    /// @param minerId      The address pair that miner registered in NameRegistry.
    ///                     The address pair contains a signer address and a fee
    ///                     recipient address.
    ///                     The signer address is used for sign this tx.
    ///                     The Recipient address for fee collection. If this is
    ///                     &#39;0x0&#39;, all fees will be paid to the address who had
    ///                     signed this transaction, not `msg.sender`. Noted if
    ///                     LRC need to be paid back to order owner as the result
    ///                     of fee selection model, LRC will also be sent from
    ///                     this address.
    /// @param feeSelections -
    ///                     Bits to indicate fee selections. `1` represents margin
    ///                     split and `0` represents LRC as fee.
    function submitRing(
        address[3][]    addressList,
        uint[7][]       uintArgsList,
        uint8[1][]      uint8ArgsList,
        bool[]          buyNoMoreThanAmountBList,
        uint8[]         vList,
        bytes32[]       rList,
        bytes32[]       sList,
        uint            minerId,
        uint16          feeSelections
        ) public;
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
/// @title Ethereum Address Register Contract
/// @dev This contract maintains a name service for addresses and miner.
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e68d8988818a8f878881a68a898996948f8881c8899481">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c2a6a3acaba7ae82aeadadb2b0abaca5ecadb0a5">[email&#160;protected]</a>&gt;,
contract NameRegistry {
    uint public nextId = 0;
    mapping (uint    =&gt; Participant) public participantMap;
    mapping (address =&gt; NameInfo)    public nameInfoMap;
    mapping (bytes12 =&gt; address)     public ownerMap;
    mapping (address =&gt; string)      public nameMap;
    struct NameInfo {
        bytes12  name;
        uint[]   participantIds;
    }
    struct Participant {
        address feeRecipient;
        address signer;
        bytes12 name;
        address owner;
    }
    event NameRegistered (
        string            name,
        address   indexed owner
    );
    event NameUnregistered (
        string             name,
        address    indexed owner
    );
    event OwnershipTransfered (
        bytes12            name,
        address            oldOwner,
        address            newOwner
    );
    event ParticipantRegistered (
        bytes12           name,
        address   indexed owner,
        uint      indexed participantId,
        address           singer,
        address           feeRecipient
    );
    event ParticipantUnregistered (
        uint    participantId,
        address owner
    );
    function registerName(string name)
        external
    {
        require(isNameValid(name));
        bytes12 nameBytes = stringToBytes12(name);
        require(ownerMap[nameBytes] == 0x0);
        require(stringToBytes12(nameMap[msg.sender]) == bytes12(0x0));
        nameInfoMap[msg.sender] = NameInfo(nameBytes, new uint[](0));
        ownerMap[nameBytes] = msg.sender;
        nameMap[msg.sender] = name;
        NameRegistered(name, msg.sender);
    }
    function unregisterName(string name)
        external
    {
        NameInfo storage nameInfo = nameInfoMap[msg.sender];
        uint[] storage participantIds = nameInfo.participantIds;
        bytes12 nameBytes = stringToBytes12(name);
        require(nameInfo.name == nameBytes);
        for (uint i = participantIds.length - 1; i &gt;= 0; i--) {
            delete participantMap[participantIds[i]];
        }
        delete nameInfoMap[msg.sender];
        delete nameMap[msg.sender];
        delete ownerMap[nameBytes];
        NameUnregistered(name, msg.sender);
    }
    function transferOwnership(address newOwner)
        external
    {
        require(newOwner != 0x0);
        require(nameInfoMap[newOwner].name.length == 0);
        NameInfo storage nameInfo = nameInfoMap[msg.sender];
        string storage name = nameMap[msg.sender];
        uint[] memory participantIds = nameInfo.participantIds;
        for (uint i = 0; i &lt; participantIds.length; i ++) {
            Participant storage p = participantMap[participantIds[i]];
            p.owner = newOwner;
        }
        delete nameInfoMap[msg.sender];
        delete nameMap[msg.sender];
        nameInfoMap[newOwner] = nameInfo;
        nameMap[newOwner] = name;
        OwnershipTransfered(nameInfo.name, msg.sender, newOwner);
    }
    /* function addParticipant(address feeRecipient) */
    /*     external */
    /*     returns (uint) */
    /* { */
    /*     return addParticipant(feeRecipient, feeRecipient); */
    /* } */
    function addParticipant(
        address feeRecipient,
        address singer
        )
        external
        returns (uint)
    {
        require(feeRecipient != 0x0 &amp;&amp; singer != 0x0);
        NameInfo storage nameInfo = nameInfoMap[msg.sender];
        bytes12 name = nameInfo.name;
        require(name.length &gt; 0);
        Participant memory participant = Participant(
            feeRecipient,
            singer,
            name,
            msg.sender
        );
        uint participantId = ++nextId;
        participantMap[participantId] = participant;
        nameInfo.participantIds.push(participantId);
        ParticipantRegistered(
            name,
            msg.sender,
            participantId,
            singer,
            feeRecipient
        );
        return participantId;
    }
    function removeParticipant(uint participantId)
        external
    {
        require(msg.sender == participantMap[participantId].owner);
        NameInfo storage nameInfo = nameInfoMap[msg.sender];
        uint[] storage participantIds = nameInfo.participantIds;
        delete participantMap[participantId];
        uint len = participantIds.length;
        for (uint i = 0; i &lt; len; i ++) {
            if (participantId == participantIds[i]) {
                participantIds[i] = participantIds[len - 1];
                participantIds.length -= 1;
            }
        }
        ParticipantUnregistered(participantId, msg.sender);
    }
    function getParticipantById(uint id)
        external
        view
        returns (address feeRecipient, address signer)
    {
        Participant storage addressSet = participantMap[id];
        feeRecipient = addressSet.feeRecipient;
        signer = addressSet.signer;
    }
    function getFeeRecipientById(uint id)
        external
        view
        returns (address feeRecipient)
    {
        Participant storage addressSet = participantMap[id];
        feeRecipient = addressSet.feeRecipient;
    }
    function getParticipantIds(string name, uint start, uint count)
        external
        view
        returns (uint[] idList)
    {
        bytes12 nameBytes = stringToBytes12(name);
        address owner = ownerMap[nameBytes];
        require(owner != 0x0);
        NameInfo storage nameInfo = nameInfoMap[owner];
        uint[] storage pIds = nameInfo.participantIds;
        uint len = pIds.length;
        if (start &gt;= len) {
            return;
        }
        uint end = start + count;
        if (end &gt; len) {
            end = len;
        }
        if (start == end) {
            return;
        }
        idList = new uint[](end - start);
        for (uint i = start; i &lt; end; i ++) {
            idList[i - start] = pIds[i];
        }
    }
    function getOwner(string name)
        external
        view
        returns (address)
    {
        bytes12 nameBytes = stringToBytes12(name);
        return ownerMap[nameBytes];
    }
    function isNameValid(string name)
        internal
        pure
        returns (bool)
    {
        bytes memory temp = bytes(name);
        return temp.length &gt;= 6 &amp;&amp; temp.length &lt;= 12;
    }
    function stringToBytes12(string str)
        internal
        pure
        returns (bytes12 result)
    {
        assembly {
            result := mload(add(str, 32))
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
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="03686c6d646f6a626d64436f6c6c73716a6d642d6c7164">[email&#160;protected]</a>&gt;,
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="84e0e5eaede1e8c4e8ebebf4f6edeae3aaebf6e3">[email&#160;protected]</a>&gt;.
contract TokenRegistry is Claimable {
    address[] public addresses;
    mapping (address =&gt; TokenInfo) addressMap;
    mapping (string =&gt; address) symbolMap;
    ////////////////////////////////////////////////////////////////////////////
    /// Structs                                                              ///
    ////////////////////////////////////////////////////////////////////////////
    struct TokenInfo {
        uint   pos;      // 0 mens unregistered; if &gt; 0, pos + 1 is the
                         // token&#39;s position in `addresses`.
        string symbol;   // Symbol of the token
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Events                                                               ///
    ////////////////////////////////////////////////////////////////////////////
    event TokenRegistered(address addr, string symbol);
    event TokenUnregistered(address addr, string symbol);
    ////////////////////////////////////////////////////////////////////////////
    /// Public Functions                                                     ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Disable default function.
    function () payable public {
        revert();
    }
    function registerToken(
        address addr,
        string  symbol
        )
        external
        onlyOwner
    {
        require(0x0 != addr);
        require(bytes(symbol).length &gt; 0);
        require(0x0 == symbolMap[symbol]);
        require(0 == addressMap[addr].pos);
        addresses.push(addr);
        symbolMap[symbol] = addr;
        addressMap[addr] = TokenInfo(addresses.length, symbol);
        TokenRegistered(addr, symbol);
    }
    function unregisterToken(
        address addr,
        string  symbol
        )
        external
        onlyOwner
    {
        require(addr != 0x0);
        require(symbolMap[symbol] == addr);
        delete symbolMap[symbol];
        uint pos = addressMap[addr].pos;
        require(pos != 0);
        delete addressMap[addr];
        // We will replace the token we need to unregister with the last token
        // Only the pos of the last token will need to be updated
        address lastToken = addresses[addresses.length - 1];
        // Don&#39;t do anything if the last token is the one we want to delete
        if (addr != lastToken) {
            // Swap with the last token and update the pos
            addresses[pos - 1] = lastToken;
            addressMap[lastToken].pos = pos;
        }
        addresses.length--;
        TokenUnregistered(addr, symbol);
    }
    function areAllTokensRegistered(address[] addressList)
        external
        view
        returns (bool)
    {
        for (uint i = 0; i &lt; addressList.length; i++) {
            if (addressMap[addressList[i]].pos == 0) {
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
        return symbolMap[symbol];
    }
    function isTokenRegisteredBySymbol(string symbol)
        public
        view
        returns (bool)
    {
        return symbolMap[symbol] != 0x0;
    }
    function isTokenRegistered(address addr)
        public
        view
        returns (bool)
    {
        return addressMap[addr].pos != 0;
    }
    function getTokens(
        uint start,
        uint count
        )
        public
        view
        returns (address[] addressList)
    {
        uint num = addresses.length;
        if (start &gt;= num) {
            return;
        }
        uint end = start + count;
        if (end &gt; num) {
            end = num;
        }
        if (start == num) {
            return;
        }
        addressList = new address[](end - start);
        for (uint i = start; i &lt; end; i++) {
            addressList[i - start] = addresses[i];
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
/// @title TokenTransferDelegate
/// @dev Acts as a middle man to transfer ERC20 tokens on behalf of different
/// versions of Loopring protocol to avoid ERC20 re-authorization.
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3450555a5d515874585b5b44465d5a531a5b4653">[email&#160;protected]</a>&gt;.
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
    /// @dev Disable default function.
    function () payable public {
        revert();
    }
    /// @dev Add a Loopring protocol address.
    /// @param addr A loopring protocol address.
    function authorizeAddress(address addr)
        onlyOwner
        external
    {
        AddressInfo storage addrInfo = addressInfos[addr];
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
        if (value &gt; 0 &amp;&amp; from != to &amp;&amp; to != 0x0) {
            require(
                ERC20(token).transferFrom(from, to, value)
            );
        }
    }
    function batchTransferToken(
        address lrcTokenAddress,
        address minerFeeRecipient,
        uint8 walletSplitPercentage,
        bytes32[] batch)
        onlyAuthorized
        external
    {
        uint len = batch.length;
        require(len % 7 == 0);
        require(walletSplitPercentage &gt; 0 &amp;&amp; walletSplitPercentage &lt; 100);
        ERC20 lrc = ERC20(lrcTokenAddress);
        for (uint i = 0; i &lt; len; i += 7) {
            address owner = address(batch[i]);
            address prevOwner = address(batch[(i + len - 7) % len]);
            // Pay token to previous order, or to miner as previous order&#39;s
            // margin split or/and this order&#39;s margin split.
            ERC20 token = ERC20(address(batch[i + 1]));
            // Here batch[i + 2] has been checked not to be 0.
            if (owner != prevOwner) {
                require(
                    token.transferFrom(
                        owner,
                        prevOwner,
                        uint(batch[i + 2])
                    )
                );
            }
            // Miner pays LRx fee to order owner
            uint lrcReward = uint(batch[i + 4]);
            if (lrcReward != 0 &amp;&amp; minerFeeRecipient != owner) {
                require(
                    lrc.transferFrom(
                        minerFeeRecipient,
                        owner,
                        lrcReward
                    )
                );
            }
            // Split margin-split income between miner and wallet
            splitPayFee(
                token,
                uint(batch[i + 3]),
                owner,
                minerFeeRecipient,
                address(batch[i + 6]),
                walletSplitPercentage
            );
            // Split LRx fee income between miner and wallet
            splitPayFee(
                lrc,
                uint(batch[i + 5]),
                owner,
                minerFeeRecipient,
                address(batch[i + 6]),
                walletSplitPercentage
            );
        }
    }
    function isAddressAuthorized(address addr)
        public
        view
        returns (bool)
    {
        return addressInfos[addr].authorized;
    }
    function splitPayFee(
        ERC20   token,
        uint    fee,
        address owner,
        address minerFeeRecipient,
        address walletFeeRecipient,
        uint    walletSplitPercentage
        )
        internal
    {
        if (fee == 0) {
            return;
        }
        uint walletFee = (walletFeeRecipient == 0x0) ? 0 : fee.mul(walletSplitPercentage) / 100;
        uint minerFee = fee - walletFee;
        if (walletFee &gt; 0 &amp;&amp; walletFeeRecipient != owner) {
            require(
                token.transferFrom(
                    owner,
                    walletFeeRecipient,
                    walletFee
                )
            );
        }
        if (minerFee &gt; 0 &amp;&amp; minerFeeRecipient != 0x0 &amp;&amp; minerFeeRecipient != owner) {
            require(
                token.transferFrom(
                    owner,
                    minerFeeRecipient,
                    minerFee
                )
            );
        }
    }
}
/// @title Loopring Token Exchange Protocol Implementation Contract
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c1a5a0afa8a4ad81adaeaeb1b3a8afa6efaeb3a6">[email&#160;protected]</a>&gt;,
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="462d2928212a2f272821062a292936342f282168293421">[email&#160;protected]</a>&gt;
///
/// Recognized contributing developers from the community:
///     https://github.com/Brechtpd
///     https://github.com/rainydio
///     https://github.com/BenjaminPrice
///     https://github.com/jonasshen
contract LoopringProtocolImpl is LoopringProtocol {
    using MathBytes32   for bytes32[];
    using MathUint      for uint;
    using MathUint8     for uint8[];
    ////////////////////////////////////////////////////////////////////////////
    /// Variables                                                            ///
    ////////////////////////////////////////////////////////////////////////////
    address public constant lrcTokenAddress       = 0xEF68e7C694F40c8202821eDF525dE3782458639f;
    address public constant tokenRegistryAddress  = 0xa21c1f2AE7f721aE77b1204A4f0811c642638da9;
    address public constant delegateAddress       = 0x7b126ab811f278f288bf1d62d47334351dA20d1d;
    address public constant nameRegistryAddress   = 0xd181c1808e3f010F0F0aABc6Fe1bcE2025DB7Bb7;
    uint64  public ringIndex                      = 0;
    uint8   public constant walletSplitPercentage = 20;
    // Exchange rate (rate) is the amount to sell or sold divided by the amount
    // to buy or bought.
    //
    // Rate ratio is the ratio between executed rate and an order&#39;s original
    // rate.
    //
    // To require all orders&#39; rate ratios to have coefficient ofvariation (CV)
    // smaller than 2.5%, for an example , rateRatioCVSThreshold should be:
    //     `(0.025 * RATE_RATIO_SCALE)^2` or 62500.
    uint    public constant rateRatioCVSThreshold        = 62500;
    uint    public constant MAX_RING_SIZE                = 16;
    uint    public constant RATE_RATIO_SCALE             = 10000;
    uint64  public constant ENTERED_MASK                 = 1 &lt;&lt; 63;
    // The following map is used to keep trace of order fill and cancellation
    // history.
    mapping (bytes32 =&gt; uint) public cancelledOrFilled;
    // This map is used to keep trace of order&#39;s cancellation history.
    mapping (bytes32 =&gt; uint) public cancelled;
    // A map from address to its cutoff timestamp.
    mapping (address =&gt; uint) public cutoffs;
    // A map from address to its trading-pair cutoff timestamp.
    mapping (address =&gt; mapping (bytes20 =&gt; uint)) public tradingPairCutoffs;
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
    /// @param authAddr     An address to verify miner has access to the order&#39;s
    ///                     auth private-key.
    /// @param validSince   Indicating when this order should be treated as
    ///                     valid for trading, in second.
    /// @param validUntil   Indicating when this order should be treated as
    ///                     expired, in second.
    /// @param lrcFee       Max amount of LRC to pay for miner. The real amount
    ///                     to pay is proportional to fill amount.
    /// @param buyNoMoreThanAmountB -
    ///                     If true, this order does not accept buying more
    ///                     than `amountB`.
    /// @param walletId     The id of the wallet that generated this order.
    /// @param marginSplitPercentage -
    ///                     The percentage of margin paid to miner.
    /// @param v            ECDSA signature parameter v.
    /// @param r            ECDSA signature parameters r.
    /// @param s            ECDSA signature parameters s.
    struct Order {
        address owner;
        address tokenS;
        address tokenB;
        address authAddr;
        uint    validSince;
        uint    validUntil;
        uint    amountS;
        uint    amountB;
        uint    lrcFee;
        bool    buyNoMoreThanAmountB;
        uint    walletId;
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
        bool    marginSplitAsFee;
        Rate    rate;
        uint    fillAmountS;
        uint    lrcReward;
        uint    lrcFee;
        uint    splitS;
        uint    splitB;
    }
    /// @dev A struct to capture parameters passed to submitRing method and
    ///      various of other variables used across the submitRing core logics.
    struct RingParams {
        address[3][]  addressList;
        uint[7][]     uintArgsList;
        uint8[1][]    uint8ArgsList;
        bool[]        buyNoMoreThanAmountBList;
        uint8[]       vList;
        bytes32[]     rList;
        bytes32[]     sList;
        uint          minerId;
        uint          ringSize;         // computed
        uint16        feeSelections;
        address       ringMiner;        // queried
        address       feeRecipient;     // queried
        bytes32       ringHash;         // computed
    }
    ////////////////////////////////////////////////////////////////////////////
    /// Constructor                                                          ///
    ////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////
    /// Public Functions                                                     ///
    ////////////////////////////////////////////////////////////////////////////
    /// @dev Disable default function.
    function () payable public {
        revert();
    }
    function cancelOrder(
        address[4] addresses,
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
        Order memory order = Order(
            addresses[0],
            addresses[1],
            addresses[2],
            addresses[3],
            orderValues[2],
            orderValues[3],
            orderValues[0],
            orderValues[1],
            orderValues[4],
            buyNoMoreThanAmountB,
            orderValues[5],
            marginSplitPercentage
        );
        require(msg.sender == order.owner); // &quot;cancelOrder not submitted by order owner&quot;);
        bytes32 orderHash = calculateOrderHash(order);
        verifySignature(
            order.owner,
            orderHash,
            v,
            r,
            s
        );
        cancelled[orderHash] = cancelled[orderHash].add(cancelAmount);
        cancelledOrFilled[orderHash] = cancelledOrFilled[orderHash].add(cancelAmount);
        OrderCancelled(orderHash, cancelAmount);
    }
    function cancelAllOrdersByTradingPair(
        address token1,
        address token2,
        uint    cutoff
        )
        external
    {
        uint t = (cutoff == 0 || cutoff &gt;= block.timestamp) ? block.timestamp : cutoff;
        bytes20 tokenPair = bytes20(token1) ^ bytes20(token2);
        require(tradingPairCutoffs[msg.sender][tokenPair] &lt; t); // &quot;attempted to set cutoff to a smaller value&quot;
        tradingPairCutoffs[msg.sender][tokenPair] = t;
        OrdersCancelled(
            msg.sender,
            token1,
            token2,
            t
        );
    }
    function cancelAllOrders(uint cutoff)
        external
    {
        uint t = (cutoff == 0 || cutoff &gt;= block.timestamp) ? block.timestamp : cutoff;
        require(cutoffs[msg.sender] &lt; t); // &quot;attempted to set cutoff to a smaller value&quot;
        cutoffs[msg.sender] = t;
        AllOrdersCancelled(msg.sender, t);
    }
    function submitRing(
        address[3][]  addressList,
        uint[7][]     uintArgsList,
        uint8[1][]    uint8ArgsList,
        bool[]        buyNoMoreThanAmountBList,
        uint8[]       vList,
        bytes32[]     rList,
        bytes32[]     sList,
        uint          minerId,
        uint16        feeSelections
        )
        public
    {
        // Check if the highest bit of ringIndex is &#39;1&#39;.
        require(ringIndex &amp; ENTERED_MASK != ENTERED_MASK); // &quot;attempted to re-ent submitRing function&quot;);
        // Set the highest bit of ringIndex to &#39;1&#39;.
        ringIndex |= ENTERED_MASK;
        RingParams memory params = RingParams(
            addressList,
            uintArgsList,
            uint8ArgsList,
            buyNoMoreThanAmountBList,
            vList,
            rList,
            sList,
            minerId,
            addressList.length,
            feeSelections,
            0x0,        // ringMiner
            0x0,        // feeRecipient
            0x0         // ringHash
        );
        verifyInputDataIntegrity(params);
        updateFeeRecipient(params);
        // Assemble input data into structs so we can pass them to other functions.
        // This method also calculates ringHash, therefore it must be called before
        // calling `verifyRingSignatures`.
        OrderState[] memory orders = assembleOrders(params);
        verifyRingSignatures(params);
        verifyTokensRegistered(params);
        handleRing(params, orders);
        ringIndex = (ringIndex ^ ENTERED_MASK) + 1;
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
    /// @dev Verify the ringHash has been signed with each order&#39;s auth private
    ///      keys as well as the miner&#39;s private key.
    function verifyRingSignatures(RingParams params)
        private
        pure
    {
        uint j;
        for (uint i = 0; i &lt; params.ringSize; i++) {
            j = i + params.ringSize;
            verifySignature(
                params.addressList[i][2],  // authAddr
                params.ringHash,
                params.vList[j],
                params.rList[j],
                params.sList[j]
            );
        }
        if (params.ringMiner != 0x0) {
            j++;
            verifySignature(
                params.ringMiner,
                params.ringHash,
                params.vList[j],
                params.rList[j],
                params.sList[j]
            );
        }
    }
    function verifyTokensRegistered(RingParams params)
        private
        view
    {
        // Extract the token addresses
        address[] memory tokens = new address[](params.ringSize);
        for (uint i = 0; i &lt; params.ringSize; i++) {
            tokens[i] = params.addressList[i][1];
        }
        // Test all token addresses at once
        require(
            TokenRegistry(tokenRegistryAddress).areAllTokensRegistered(tokens)
        ); // &quot;token not registered&quot;);
    }
    function updateFeeRecipient(RingParams params)
        private
        view
    {
        if (params.minerId == 0) {
            params.feeRecipient = msg.sender;
        } else {
            (params.feeRecipient, params.ringMiner) = NameRegistry(
                nameRegistryAddress
            ).getParticipantById(
                params.minerId
            );
            if (params.feeRecipient == 0x0) {
                params.feeRecipient = msg.sender;
            }
        }
        uint sigSize = params.ringSize * 2;
        if (params.ringMiner != 0x0) {
            sigSize += 1;
        }
        require(sigSize == params.vList.length); // &quot;ring data is inconsistent - vList&quot;);
        require(sigSize == params.rList.length); // &quot;ring data is inconsistent - rList&quot;);
        require(sigSize == params.sList.length); // &quot;ring data is inconsistent - sList&quot;);
    }
    function handleRing(
        RingParams    params,
        OrderState[]  orders
        )
        private
    {
        uint64 _ringIndex = ringIndex ^ ENTERED_MASK;
        address _lrcTokenAddress = lrcTokenAddress;
        TokenTransferDelegate delegate = TokenTransferDelegate(delegateAddress);
        // Do the hard work.
        verifyRingHasNoSubRing(params.ringSize, orders);
        // Exchange rates calculation are performed by ring-miners as solidity
        // cannot get power-of-1/n operation, therefore we have to verify
        // these rates are correct.
        verifyMinerSuppliedFillRates(params.ringSize, orders);
        // Scale down each order independently by substracting amount-filled and
        // amount-cancelled. Order owner&#39;s current balance and allowance are
        // not taken into consideration in these operations.
        scaleRingBasedOnHistoricalRecords(delegate, params.ringSize, orders);
        // Based on the already verified exchange rate provided by ring-miners,
        // we can furthur scale down orders based on token balance and allowance,
        // then find the smallest order of the ring, then calculate each order&#39;s
        // `fillAmountS`.
        calculateRingFillAmount(params.ringSize, orders);
        // Calculate each order&#39;s `lrcFee` and `lrcRewrard` and splict how much
        // of `fillAmountS` shall be paid to matching order or miner as margin
        // split.
        calculateRingFees(
            delegate,
            params.ringSize,
            orders,
            params.feeRecipient,
            _lrcTokenAddress
        );
        /// Make transfers.
        var (orderHashList, amountsList) = settleRing(
            delegate,
            params.ringSize,
            orders,
            params.feeRecipient,
            _lrcTokenAddress
        );
        RingMined(
            _ringIndex,
            params.ringHash,
            params.ringMiner,
            params.feeRecipient,
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
        uint[6][] memory amountsList)
    {
        bytes32[] memory batch = new bytes32[](ringSize * 7); // ringSize * (owner + tokenS + 4 amounts)
        orderHashList = new bytes32[](ringSize);
        amountsList = new uint[6][](ringSize);
        uint p = 0;
        for (uint i = 0; i &lt; ringSize; i++) {
            OrderState memory state = orders[i];
            Order memory order = state.order;
            uint prevSplitB = orders[(i + ringSize - 1) % ringSize].splitB;
            uint nextFillAmountS = orders[(i + 1) % ringSize].fillAmountS;
            // Store owner and tokenS of every order
            batch[p] = bytes32(order.owner);
            batch[p + 1] = bytes32(order.tokenS);
            // Store all amounts
            batch[p + 2] = bytes32(state.fillAmountS - prevSplitB);
            batch[p + 3] = bytes32(prevSplitB + state.splitS);
            batch[p + 4] = bytes32(state.lrcReward);
            batch[p + 5] = bytes32(state.lrcFee);
            if (order.walletId != 0) {
                batch[p + 6] = bytes32(NameRegistry(nameRegistryAddress).getFeeRecipientById(order.walletId));
            } else {
                batch[p + 6] = bytes32(0x0);
            }
            p += 7;
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
            amountsList[i][4] = state.splitS;
            amountsList[i][5] = state.splitB;
        }
        // Do all transactions
        delegate.batchTransferToken(
            _lrcTokenAddress,
            feeRecipient,
            walletSplitPercentage,
            batch
        );
    }
    /// @dev Verify miner has calculte the rates correctly.
    function verifyMinerSuppliedFillRates(
        uint          ringSize,
        OrderState[]  orders
        )
        private
        view
    {
        uint[] memory rateRatios = new uint[](ringSize);
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
            OrderState memory state = orders[i];
            uint lrcReceiable = 0;
            if (state.lrcFee == 0) {
                // When an order&#39;s LRC fee is 0 or smaller than the specified fee,
                // we help miner automatically select margin-split.
                state.marginSplitAsFee = true;
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
                    state.marginSplitAsFee = true;
                }
            }
            if (!state.marginSplitAsFee) {
                if (lrcReceiable &gt; 0) {
                    if (lrcReceiable &gt;= state.lrcFee) {
                        state.splitB = state.lrcFee;
                        state.lrcFee = 0;
                    } else {
                        state.splitB = lrcReceiable;
                        state.lrcFee -= lrcReceiable;
                    }
                }
            } else {
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
            OrderState memory state = orders[i];
            Order memory order = state.order;
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
        ERC20 token = ERC20(tokenAddress);
        uint allowance = token.allowance(
            tokenOwner,
            address(delegate)
        );
        uint balance = token.balanceOf(tokenOwner);
        return (allowance &lt; balance ? allowance : balance);
    }
    /// @dev verify input data&#39;s basic integrity.
    function verifyInputDataIntegrity(RingParams params)
        private
        pure
    {
        require(params.ringSize == params.addressList.length); // &quot;ring data is inconsistent - addressList&quot;);
        require(params.ringSize == params.uintArgsList.length); // &quot;ring data is inconsistent - uintArgsList&quot;);
        require(params.ringSize == params.uint8ArgsList.length); // &quot;ring data is inconsistent - uint8ArgsList&quot;);
        require(params.ringSize == params.buyNoMoreThanAmountBList.length); // &quot;ring data is inconsistent - buyNoMoreThanAmountBList&quot;);
        // Validate ring-mining related arguments.
        for (uint i = 0; i &lt; params.ringSize; i++) {
            require(params.uintArgsList[i][5] &gt; 0); // &quot;order rateAmountS is zero&quot;);
        }
        //Check ring size
        require(params.ringSize &gt; 1 &amp;&amp; params.ringSize &lt;= MAX_RING_SIZE); // &quot;invalid ring size&quot;);
    }
    /// @dev        assmble order parameters into Order struct.
    /// @return     A list of orders.
    function assembleOrders(RingParams params)
        private
        view
        returns (OrderState[] memory orders)
    {
        orders = new OrderState[](params.ringSize);
        for (uint i = 0; i &lt; params.ringSize; i++) {
            Order memory order = Order(
                params.addressList[i][0],
                params.addressList[i][1],
                params.addressList[(i + 1) % params.ringSize][1],
                params.addressList[i][2],
                params.uintArgsList[i][2],
                params.uintArgsList[i][3],
                params.uintArgsList[i][0],
                params.uintArgsList[i][1],
                params.uintArgsList[i][4],
                params.buyNoMoreThanAmountBList[i],
                params.uintArgsList[i][6],
                params.uint8ArgsList[i][0]
            );
            validateOrder(order);
            bytes32 orderHash = calculateOrderHash(order);
            verifySignature(
                order.owner,
                orderHash,
                params.vList[i],
                params.rList[i],
                params.sList[i]
            );
            bool marginSplitAsFee = (params.feeSelections &amp; (uint16(1) &lt;&lt; i)) &gt; 0;
            orders[i] = OrderState(
                order,
                orderHash,
                marginSplitAsFee,
                Rate(params.uintArgsList[i][5], order.amountB),
                0,   // fillAmountS
                0,   // lrcReward
                0,   // lrcFee
                0,   // splitS
                0    // splitB
            );
            params.ringHash ^= orderHash;
        }
        params.ringHash = keccak256(
            params.ringHash,
            params.minerId,
            params.feeSelections
        );
    }
    /// @dev validate order&#39;s parameters are OK.
    function validateOrder(Order order)
        private
        view
    {
        require(order.owner != 0x0); // invalid order owner
        require(order.tokenS != 0x0); // invalid order tokenS
        require(order.tokenB != 0x0); // invalid order tokenB
        require(order.amountS != 0); // invalid order amountS
        require(order.amountB != 0); // invalid order amountB
        require(order.marginSplitPercentage &lt;= MARGIN_SPLIT_PERCENTAGE_BASE); // invalid order marginSplitPercentage
        require(order.validSince &lt;= block.timestamp); // order is too early to match
        require(order.validUntil &gt; block.timestamp); // order is expired
        bytes20 tradingPair = bytes20(order.tokenS) ^ bytes20(order.tokenB);
        require(order.validSince &gt; tradingPairCutoffs[order.owner][tradingPair]); // order trading pair is cut off
        require(order.validSince &gt; cutoffs[order.owner]); // order is cut off
    }
    /// @dev Get the Keccak-256 hash of order with specified parameters.
    function calculateOrderHash(Order order)
        private
        view
        returns (bytes32)
    {
        return keccak256(
            address(this),
            order.owner,
            order.tokenS,
            order.tokenB,
            order.authAddr,
            order.amountS,
            order.amountB,
            order.validSince,
            order.validUntil,
            order.lrcFee,
            order.buyNoMoreThanAmountB,
            order.walletId,
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
    function getTradingPairCutoffs(address orderOwner, address token1, address token2)
        public
        view
        returns (uint)
    {
        bytes20 tokenPair = bytes20(token1) ^ bytes20(token2);
        return tradingPairCutoffs[orderOwner][tokenPair];
    }
}