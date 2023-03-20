//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import { IMetadataRenderer } from "https://github.com/ourzora/zora-drops-contracts/blob/main/src/interfaces/IMetadataRenderer.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { INounsDescriptor } from "./interfaces/INounsDescriptor.sol";
import { INounsSeeder } from "./interfaces/INounsSeeder.sol";
import "erc721a-upgradeable/contracts/interfaces/IERC721AUpgradeable.sol";

contract OnionRenderer {
    using Strings for uint256;

    address private _owner;
    uint public onionHeadId;
    IERC721AUpgradeable public onionToken;
    INounsDescriptor public descriptor;

    constructor(INounsDescriptor _descriptor, IERC721AUpgradeable _onionToken, uint _onionHeadId) {
        _owner = msg.sender;
        descriptor = _descriptor;
        onionToken = _onionToken;
        onionHeadId = _onionHeadId;
    }
    
    function generateSeed(address _address, uint _tokenId) private view returns (INounsSeeder.Seed memory) {
        
        uint256 _pseudorandomness = uint256(keccak256(abi.encodePacked(_address, _tokenId)));

        uint256 backgroundCount = descriptor.backgroundCount();
        uint256 bodyCount = descriptor.bodyCount();
        uint256 accessoryCount = descriptor.accessoryCount();
        uint256 glassesCount = descriptor.glassesCount();

        return INounsSeeder.Seed({
            background: uint48(
                uint48(_pseudorandomness) % backgroundCount
            ),
            body: uint48(
                uint48(_pseudorandomness >> 48) % bodyCount
            ),
            accessory: uint48(
                uint48(_pseudorandomness >> 96) % accessoryCount
            ),
            head: uint48(onionHeadId), 
            glasses: uint48(
                uint48(_pseudorandomness >> 192) % glassesCount
            )
        });
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(onionToken.totalSupply() >= _tokenId, "This onion does not exist :'(");
        
        string memory name = string(abi.encodePacked("Onion #", _tokenId.toString()));
        string memory description = "Onions are a generative edition of Onion nouns. Each onion is dynamically generated and personalized to the owner's address. When Onions change wallets, their traits change as well to reflect the new owner.";
        address onionOwner = onionToken.ownerOf(_tokenId);

        return descriptor.genericDataURI(name, description, generateSeed(onionOwner, _tokenId));
    }

    function contractURI() public view returns (string memory) {
    }
}
