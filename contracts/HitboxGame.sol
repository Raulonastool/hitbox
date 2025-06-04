// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title HitboxGame
 * @notice Minimal game contract storing a Merkle root of the hidden world.
 *         Handles movement, obstacle collisions and tile reveal proofs.
 */
contract HitboxGame {
    bytes32 public worldRoot;

    struct Position {
        uint256 x;
        uint256 y;
    }

    Position public characterPosition;

    struct Obstacle {
        Position pos;
    }

    mapping(uint256 => Obstacle) public obstacles;

    // Track revealed tiles using a hash of coordinates
    mapping(bytes32 => bool) public revealedTiles;

    event CharacterMoved(uint256 x, uint256 y);
    event CollisionDetected(uint256 obstacleId);
    event TileRevealed(uint256 x, uint256 y);

    constructor(bytes32 _worldRoot, uint256 startX, uint256 startY) {
        worldRoot = _worldRoot;
        characterPosition = Position(startX, startY);
    }

    enum Direction { Left, Right, Up, Down }

    struct TileReveal {
        uint256 x;
        uint256 y;
        bytes32 tileData;
        bytes32[] proof;
    }

    /**
     * @notice Move the character one tile in the specified direction.
     *         Verifies any supplied tile proofs and emits relevant events.
     */
    function moveCharacter(Direction dir, TileReveal[] calldata reveals) external {
        Position memory newPos = characterPosition;

        if (dir == Direction.Left) {
            if (newPos.x > 0) newPos.x -= 1;
        } else if (dir == Direction.Right) {
            newPos.x += 1;
        } else if (dir == Direction.Up) {
            if (newPos.y > 0) newPos.y -= 1;
        } else if (dir == Direction.Down) {
            newPos.y += 1;
        }

        uint256 collided = _checkCollision(newPos);
        if (collided != type(uint256).max) {
            characterPosition = Position(0, 0);
            emit CollisionDetected(collided);
        } else {
            characterPosition = newPos;
        }

        for (uint256 i; i < reveals.length; i++) {
            if (_verifyTile(reveals[i])) {
                bytes32 key = _tileKey(reveals[i].x, reveals[i].y);
                if (!revealedTiles[key]) {
                    revealedTiles[key] = true;
                    emit TileRevealed(reveals[i].x, reveals[i].y);
                }
            }
        }

        emit CharacterMoved(characterPosition.x, characterPosition.y);
    }

    /**
     * @notice Simple collision check against stored obstacles.
     * @return obstacleId ID that was hit or max uint if none.
     */
    function _checkCollision(Position memory pos) internal view returns (uint256 obstacleId) {
        for (uint256 i = 0; i < 256; i++) {
            if (obstacles[i].pos.x == pos.x && obstacles[i].pos.y == pos.y) {
                return i;
            }
        }
        return type(uint256).max;
    }

    function _verifyTile(TileReveal memory reveal) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(reveal.x, reveal.y, reveal.tileData));
        return MerkleProof.verify(reveal.proof, worldRoot, leaf);
    }

    function _tileKey(uint256 x, uint256 y) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(x, y));
    }
}

