// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

interface IHitboxGame {
    function characterPosition() external view returns (uint256, uint256);
}

/**
 * @title HitboxNFT
 * @notice ERC-721 that renders a 32×32 SVG showing the character’s
 *         current position in the HitboxGame contract.
 */
contract HitboxNFT is ERC721 {
    IHitboxGame public immutable game;
    uint256 public nextId;

    constructor(address gameAddress) ERC721("HitboxNFT", "HIT") {
        game = IHitboxGame(gameAddress);
    }

    // -----------------------------------------------------------------------
    // Minting
    // -----------------------------------------------------------------------

    function mint() external {
        _mint(msg.sender, nextId);
        nextId++;
    }

    // -----------------------------------------------------------------------
    // Metadata
    // -----------------------------------------------------------------------

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721: query for nonexistent token");

        (uint256 x, uint256 y) = game.characterPosition();

        string memory svg   = _buildSvg(x, y);
        string memory image = string.concat(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svg))
        );

        string memory json = string.concat(
            '{"name":"Hitbox #', _toString(tokenId),
            '","description":"On-chain game","image":"', image, '"}'
        );

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        );
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------

    function _buildSvg(uint256 x, uint256 y) internal pure returns (string memory) {
        string memory rect = string(
            abi.encodePacked(
                "<rect fill='red' x='", _toString(x % 32),
                "' y='", _toString(y % 32),
                "' width='1' height='1'/>"
            )
        );

        return string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>",
                "<rect width='32' height='32' fill='black'/>",
                rect,
                "</svg>"
            )
        );
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
