pragma solidity ^0.4.21;

// Donate all your ethers to 0x7Ec 
// Made by EtherGuy (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4227362a273025373b022f232b2e6c212d2f">[email&#160;protected]</a>)
// CryptoGaming Discord https://discord.gg/gjrHXFr
// UI @ htpts://0x7.surge.sh

contract InteractiveDonation{
    address constant public Donated = 0x7Ec915B8d3FFee3deaAe5Aa90DeF8Ad826d2e110;
    
    event Quote(address Sent, string Text, uint256 AmtDonate);

    string public DonatedBanner = &quot;&quot;;
    

    
    function Donate(string quote) public payable {
        require(msg.sender != Donated); // GTFO dont donate to yourself
        
        emit Quote(msg.sender, quote, msg.value);
    }
    
    function Withdraw() public {
        if (msg.sender != Donated){
            emit Quote(msg.sender, &quot;OMG CHEATER ATTEMPTING TO WITHDRAW&quot;, 0);
            return;
        }
        address contr = this;
        msg.sender.transfer(contr.balance);
    }   
    
    function DonatorInteract(string text) public {
        require(msg.sender == Donated);
        emit Quote(msg.sender, text, 0);
    }
    
    function DonatorSetBanner(string img) public {
        require(msg.sender == Donated);
        DonatedBanner = img;
    }
    
    function() public payable{
        require(msg.sender != Donated); // Nice cheat but no donating to yourself 
    }
    
}