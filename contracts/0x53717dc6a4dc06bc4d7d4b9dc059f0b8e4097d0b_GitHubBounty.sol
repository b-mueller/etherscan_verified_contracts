contract mortal {
    /* Define variable owner of the type address*/
    address owner;

    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { owner = msg.sender; }

    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) suicide(owner); }
}
// &lt;ORACLIZE_API&gt;
/*
Copyright (c) 2015-2016 Oraclize srl, Thomas Bertani



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the &quot;Software&quot;), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setCustomGasPrice(uint _gasPrice);
}
contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;
    
    OraclizeI oraclize;
    modifier oraclizeAPI {
        address oraclizeAddr = OAR.getAddress();
        if (oraclizeAddr == 0){
            oraclize_setNetwork(networkID_auto);
            oraclizeAddr = OAR.getAddress();
        }
        oraclize = OraclizeI(oraclizeAddr);
        _
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed)&gt;0){
            OAR = OraclizeAddrResolverI(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed);
            return true;
        }
        if (getCodeSize(0x9efbea6358bed926b293d2ce63a730d6d98d43dd)&gt;0){
            OAR = OraclizeAddrResolverI(0x9efbea6358bed926b293d2ce63a730d6d98d43dd);
            return true;
        }
        if (getCodeSize(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf)&gt;0){
            OAR = OraclizeAddrResolverI(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf);
            return true;
        }
        return false;
    }
    
    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price &gt; 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price &gt; 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price &gt; 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price &gt; 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price &gt; 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price &gt; 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price &gt; 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price &gt; 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }    

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }


    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i&lt;2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 &gt;= 97)&amp;&amp;(b1 &lt;= 102)) b1 -= 87;
            else if ((b1 &gt;= 48)&amp;&amp;(b1 &lt;= 57)) b1 -= 48;
            if ((b2 &gt;= 97)&amp;&amp;(b2 &lt;= 102)) b2 -= 87;
            else if ((b2 &gt;= 48)&amp;&amp;(b2 &lt;= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }


    function strCompare(string _a, string _b) internal returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length &lt; minLength) minLength = b.length;
        for (uint i = 0; i &lt; minLength; i ++)
            if (a[i] &lt; b[i])
                return -1;
            else if (a[i] &gt; b[i])
                return 1;
        if (a.length &lt; b.length)
            return -1;
        else if (a.length &gt; b.length)
            return 1;
        else
            return 0;
   } 

    function indexOf(string _haystack, string _needle) internal returns (int)
    {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length &lt; 1 || n.length &lt; 1 || (n.length &gt; h.length)) 
            return -1;
        else if(h.length &gt; (2**128 -1))
            return -1;                                  
        else
        {
            uint subindex = 0;
            for (uint i = 0; i &lt; h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex &lt; n.length &amp;&amp; (i + subindex) &lt; h.length &amp;&amp; h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }   
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }   
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i &lt; _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i &lt; _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i &lt; _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i &lt; _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i &lt; _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, &quot;&quot;);
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, &quot;&quot;, &quot;&quot;);
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, &quot;&quot;, &quot;&quot;, &quot;&quot;);
    }

    // parseInt
    function parseInt(string _a) internal returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i&lt;bresult.length; i++){
            if ((bresult[i] &gt;= 48)&amp;&amp;(bresult[i] &lt;= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b &gt; 0) mint *= 10**_b;
        return mint;
    }
    

}
// &lt;/ORACLIZE_API&gt;

contract GitHubBounty is usingOraclize, mortal {
    
    enum QueryType { IssueState, IssueAssignee, UserAddress }
    
    struct Bounty {
        string issueUrl;
        uint prize;
        uint balance;
        uint queriesDelay;
        string closedAt;
        string assigneeLogin;
        address assigneeAddress;
    }
 
    mapping (bytes32 =&gt; bytes32) queriesKey;
    mapping (bytes32 =&gt; QueryType) queriesType;
    mapping (bytes32 =&gt; Bounty) public bounties;
    bytes32[] public bountiesKey;
    mapping (address =&gt; bool) public sponsors;
    
    uint contractBalance;
    
    event SponsorAdded(address sponsorAddr);
    event BountyAdded(bytes32 bountyKey, string issueUrl);
    event IssueStateLoaded(bytes32 bountyKey, string closedAt);
    event IssueAssigneeLoaded(bytes32 bountyKey, string login);
    event UserAddressLoaded(bytes32 bountyKey, string ethAddress);
    event SendingBounty(bytes32 bountyKey, uint prize);
    event BountySent(bytes32 bountyKey);
    
    uint oraclizeGasLimit = 1000000;

    function GitHubBounty() {
    }
    
    function addSponsor(address sponsorAddr)
    {
        if (msg.sender != owner) throw;
        sponsors[sponsorAddr] = true;
        SponsorAdded(sponsorAddr);
    }
    
    // issueUrl: full API url of github issue, e.g. https://api.github.com/repos/polybioz/hello-world/issues/6
    // queriesDelay: oraclize queries delay in minutes, e.g. 60*24 for one day, min 1 minute
    function addIssueBounty(string issueUrl, uint queriesDelay){
        
        if (!sponsors[msg.sender]) throw;
        if (bytes(issueUrl).length==0) throw;
        if (msg.value == 0) throw;
        if (queriesDelay == 0) throw;
        
        bytes32 bountyKey = sha3(issueUrl);
        
        bounties[bountyKey].issueUrl = issueUrl;
        bounties[bountyKey].prize = msg.value;
        bounties[bountyKey].balance = msg.value;
        bounties[bountyKey].queriesDelay = queriesDelay;
        
        bountiesKey.push(bountyKey);
        
        BountyAdded(bountyKey, issueUrl);
 
        getIssueState(queriesDelay, bountyKey);
    }
     
    function getIssueState(uint delay, bytes32 bountyKey) internal {
        contractBalance = this.balance;
        
        string issueUrl = bounties[bountyKey].issueUrl;
        bytes32 myid = oraclize_query(delay, &quot;URL&quot;, strConcat(&quot;json(&quot;,issueUrl,&quot;).closed_at&quot;), oraclizeGasLimit);
        queriesKey[myid] = bountyKey;
        queriesType[myid] = QueryType.IssueState;
        
        bounties[bountyKey].balance -= contractBalance - this.balance;
    }
    
    function getIssueAssignee(uint delay, bytes32 bountyKey) internal {
        contractBalance = this.balance;
        
        string issueUrl = bounties[bountyKey].issueUrl;
        bytes32 myid = oraclize_query(delay, &quot;URL&quot;, strConcat(&quot;json(&quot;,issueUrl,&quot;).assignee.login&quot;), oraclizeGasLimit);
        queriesKey[myid] = bountyKey;
        queriesType[myid] = QueryType.IssueAssignee;
        
        bounties[bountyKey].balance -= contractBalance - this.balance;
    }
    
    function getUserAddress(uint delay, bytes32 bountyKey) internal {
        contractBalance = this.balance;
        
        string login = bounties[bountyKey].assigneeLogin;
        string memory url = strConcat(&quot;https://api.github.com/users/&quot;, login);
        bytes32 myid = oraclize_query(delay, &quot;URL&quot;, strConcat(&quot;json(&quot;,url,&quot;).location&quot;), oraclizeGasLimit);
        queriesKey[myid] = bountyKey;
        queriesType[myid] = QueryType.UserAddress;
        
        bounties[bountyKey].balance -= contractBalance - this.balance;
    }
    
    function sendBounty(bytes32 bountyKey) internal {
        string issueUrl = bounties[bountyKey].issueUrl;
        
        SendingBounty(bountyKey, bounties[bountyKey].balance);
        if(bounties[bountyKey].balance &gt; 0) {
            if (bounties[bountyKey].assigneeAddress.send(bounties[bountyKey].balance)) {
                bounties[bountyKey].balance = 0;
                BountySent(bountyKey);
            }
        }
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
 
        bytes32 bountyKey = queriesKey[myid];
        QueryType queryType = queriesType[myid];
        uint queriesDelay = bounties[bountyKey].queriesDelay;
        
        if(queryType == QueryType.IssueState) {
            IssueStateLoaded(bountyKey, result);
            if(bytes(result).length &lt;= 4) { // oraclize returns &quot;None&quot; instead of null
                getIssueState(queriesDelay, bountyKey);
            }
            else{
                bounties[bountyKey].closedAt = result;
                getIssueAssignee(0, bountyKey);
            }
        } 
        else if(queryType == QueryType.IssueAssignee) {
            IssueAssigneeLoaded(bountyKey, result);
            if(bytes(result).length &lt;= 4) { // oraclize returns &quot;None&quot; instead of null
                getIssueAssignee(queriesDelay, bountyKey);
            }
            else {
                bounties[bountyKey].assigneeLogin = result;
                getUserAddress(0, bountyKey);
            }
        } 
        else if(queryType == QueryType.UserAddress) {
            UserAddressLoaded(bountyKey, result);
            if(bytes(result).length &lt;= 4) { // oraclize returns &quot;None&quot; instead of null
                getUserAddress(queriesDelay, bountyKey);
            }
            else {
                bounties[bountyKey].assigneeAddress = parseAddr(result);
                sendBounty(bountyKey);
            }
        } 
        
        delete queriesType[myid];
        delete queriesKey[myid];
    }
}