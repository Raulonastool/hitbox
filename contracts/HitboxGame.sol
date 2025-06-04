// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HitboxGame {
    struct Position {
        uint256 x;
        uint256 y;
    }

    Position public character;

    mapping(bytes32 => bool) public revealed;

    event CharacterMoved(uint256 x, uint256 y);
    event TileRevealed(uint256 x, uint256 y);

    function move(int256 dx, int256 dy) external {
        int256 nx = int256(character.x) + dx;
        int256 ny = int256(character.y) + dy;
        if (nx < 0) nx = 0;
        if (ny < 0) ny = 0;
        character.x = uint256(nx);
        character.y = uint256(ny);
        emit CharacterMoved(character.x, character.y);
    }

    function reveal(uint256 x, uint256 y) external {
        bytes32 key = keccak256(abi.encodePacked(x, y));
        revealed[key] = true;
        emit TileRevealed(x, y);
    }
}
