// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @title HitboxGame
 * @dev Simplified game contract used for Hardhat tests.
 *      Maintains character position, basic collision logic,
 *      and tile reveal proofs.
 */
contract HitboxGame {
    struct Position {
        uint256 x;
        uint256 y;
    }

    Position public start = Position(0, 0);
    Position public character = Position(0, 0);
    Position public obstacle = Position(1, 0);

    mapping(address => bool) public authorized;
    mapping(uint256 => mapping(uint256 => bool)) public revealed;

    // Fake world root: keccak256("validTile")
    bytes32 public constant WORLD_ROOT = keccak256("validTile");

    event CharacterMoved(uint256 x, uint256 y);
    event CollisionReset(uint256 x, uint256 y);
    event TileRevealed(uint256 x, uint256 y);

    /**
     * @notice Authorize an address to control the character.
     */
    function authorize(address addr) external {
        authorized[addr] = true;
    }

    /**
     * @notice Move the character in a direction.
     * @param direction 0=up,1=down,2=left,3=right
     * @param tileData data for tile reveal proof
     */
    function move(uint8 direction, bytes calldata tileData) external {
        require(authorized[msg.sender], "Not authorized");

        if (direction == 0) {
            character.y += 1;
        } else if (direction == 1) {
            if (character.y > 0) character.y -= 1;
        } else if (direction == 2) {
            if (character.x > 0) character.x -= 1;
        } else if (direction == 3) {
            character.x += 1;
        } else {
            revert("Invalid direction");
        }

        // Check collision
        if (character.x == obstacle.x && character.y == obstacle.y) {
            character = start;
            emit CollisionReset(character.x, character.y);
        }

        // Verify tile data
        require(keccak256(tileData) == WORLD_ROOT, "Invalid proof");
        revealed[character.x][character.y] = true;
        emit TileRevealed(character.x, character.y);

        emit CharacterMoved(character.x, character.y);
    }

    function getPosition() external view returns (uint256, uint256) {
        return (character.x, character.y);
    }
}
