// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract HitboxNFT is ERC721 {
    address public game;
    uint256 public nextTokenId = 1;

    constructor(address _game) ERC721("HitboxNFT", "HIT") {
        game = _game;
    }

    function mint(address to) external {
        _safeMint(to, nextTokenId);
        nextTokenId++;
    }
}
