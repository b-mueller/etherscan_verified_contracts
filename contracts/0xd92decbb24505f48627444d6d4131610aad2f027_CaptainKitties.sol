pragma solidity ^0.4.18;

/* ==================================================================== */
/* Copyright (c) 2018 The Priate Conquest Project.  All rights reserved.
/* 
/* https://www.pirateconquest.com One of the world&#39;s slg games of blockchain 
/*  
/* authors <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="413320282f38012d283724323520336f222e2c">[email&#160;protected]</a>/<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="52183d3c3c2b7c1427123e3b2437212633207c313d3f">[email&#160;protected]</a>
/*                 
/* ==================================================================== */

contract KittyInterface {
  function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens);
  function ownerOf(uint256 _tokenId) external view returns (address owner);
  function balanceOf(address _owner) public view returns (uint256 count);
}

interface KittyTokenInterface {
  function transferFrom(address _from, address _to, uint256 _tokenId) external;
  function setTokenPrice(uint256 _tokenId, uint256 _price) external;
  function CreateKittyToken(address _owner,uint256 _price, uint32 _kittyId) public;
}

contract CaptainKitties {
  address owner;
  //event 
  event CreateKitty(uint _count,address _owner);

  KittyInterface kittyContract;
  KittyTokenInterface kittyToken;
  /// @dev Trust contract
  mapping (address =&gt; bool) actionContracts;
  mapping (address =&gt; uint256) kittyToCount;
  mapping (address =&gt; bool) kittyGetOrNot;
 

  function CaptainKitties() public {
    owner = msg.sender;
  }  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function setKittyTokenAddress(address _address) external onlyOwner {
    kittyToken = KittyTokenInterface(_address);
  }

  function createKitties() external payable {
    uint256 kittycount = kittyContract.balanceOf(msg.sender);
    require(kittyGetOrNot[msg.sender] == false);
    if (kittycount&gt;=9) {
      kittycount=9;
    }
    if (kittycount&gt;0 &amp;&amp; kittyToCount[msg.sender]==0) {
      kittyToCount[msg.sender] = kittycount;
      kittyGetOrNot[msg.sender] = true;
      for (uint i=0;i&lt;kittycount;i++) {
        kittyToken.CreateKittyToken(msg.sender,0, 1);
      }
      //event
      CreateKitty(kittycount,msg.sender);
    }
  }

  function getKitties() external view returns(uint256 kittycnt,uint256 captaincnt,bool bGetOrNot) {
    kittycnt = kittyContract.balanceOf(msg.sender);
    captaincnt = kittyToCount[msg.sender];
    bGetOrNot = kittyGetOrNot[msg.sender];
  }

  function getKittyGetOrNot(address _addr) external view returns (bool) {
    return kittyGetOrNot[_addr];
  }

  function getKittyCount(address _addr) external view returns (uint256) {
    return kittyToCount[_addr];
  }

  function birthKitty() external {
  }

}