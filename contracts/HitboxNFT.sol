// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./HitboxGame.sol";

/**
 * @title HitboxNFT
 * @dev Minimal NFT contract for testing tokenURI logic.
 */
contract HitboxNFT {
    HitboxGame public game;
    mapping(uint256 => address) public ownerOf;
    string public baseURI;

    constructor(address game_, string memory baseURI_) {
        game = HitboxGame(game_);
        baseURI = baseURI_;
    }

    function mint(address to, uint256 tokenId) external {
        ownerOf[tokenId] = to;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(ownerOf[tokenId] != address(0), "NONEXISTENT");
        (uint256 x, uint256 y) = game.getPosition();
        return string(
            abi.encodePacked(
                baseURI,
                "/",
                _toString(tokenId),
                "?x=",
                _toString(x),
                "&y=",
                _toString(y)
            )
        );
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
