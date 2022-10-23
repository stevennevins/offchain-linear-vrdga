// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {LibLinearVRGDA, LVRGDAInfo} from "./lib/LibLinearVRGDA.sol";

contract LinearVRGDASale is ERC721 {
    using LibLinearVRGDA for LVRGDAInfo;

    bytes32 public paramHash;
    uint256 public numSold;

    constructor(LVRGDAInfo memory auction) ERC721("LinearNFT", "Linear") {
        paramHash = auction.toHash();
    }

    function purchase(LVRGDAInfo calldata auction) external payable {
        require(auction.toHash() == paramHash, "invalid auction");
        require(msg.value == auction.getVRGDAPrice(numSold), "mispriced");
        _mint(msg.sender, numSold++);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "";
    }
}
