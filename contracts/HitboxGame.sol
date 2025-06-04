// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title HitboxGame
 * @notice Minimal on-chain game world that
 *         • tracks a single character position
 *         • stores obstacles and detects collisions
 *         • lets callers reveal map tiles by Merkle proof
 *         • emits events for off-chain front-ends
 */
contract HitboxGame {
    // -----------------------------------------------------------------------
    // Types
    // -----------------------------------------------------------------------

    struct Position {
        uint256 x;
        uint256 y;
    }

    struct Obstacle {
        Position pos;
    }

    struct TileReveal {
        uint256 x;
        uint256 y;
        bytes32 tileData;   // payload committed in the Merkle tree
        bytes32[] proof;    // proof that (x,y,tileData) ∈ tree(worldRoot)
    }

    enum Direction {
        Left,
        Right,
        Up,
        Down
    }

    // -----------------------------------------------------------------------
    // Immutable & storage
    // -----------------------------------------------------------------------

    bytes32 public immutable worldRoot;          // commitment to the hidden map
    Position public characterPosition;           // player position

    mapping(uint256 => Obstacle) public obstacles;   // up to 256 obstacles
    mapping(bytes32 => bool) public revealedTiles;   // (x,y) → revealed?

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    event CharacterMoved(uint256 x, uint256 y);
    event CollisionDetected(uint256 obstacleId);
    event TileRevealed(uint256 x, uint256 y);

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    /**
     * @param _worldRoot Merkle root of the world tiles
     * @param startX     initial X coordinate
     * @param startY     initial Y coordinate
     */
    constructor(bytes32 _worldRoot, uint256 startX, uint256 startY) {
        worldRoot = _worldRoot;
        characterPosition = Position(startX, startY);
    }

    // -----------------------------------------------------------------------
    // Gameplay
    // -----------------------------------------------------------------------

    /**
     * @notice Move one tile in `dir`, handle collisions, and verify any tile
     *         reveal proofs submitted alongside the move.
     */
    function moveCharacter(Direction dir, TileReveal[] calldata reveals) public {
        Position memory newPos = characterPosition;

        if (dir == Direction.Left && newPos.x > 0)       newPos.x -= 1;
        else if (dir == Direction.Right)                 newPos.x += 1;
        else if (dir == Direction.Up && newPos.y > 0)    newPos.y -= 1;
        else if (dir == Direction.Down)                  newPos.y += 1;

        // Collision check
        uint256 collided = _checkCollision(newPos);
        if (collided != type(uint256).max) {
            characterPosition = Position(0, 0);          // reset on collision
            emit CollisionDetected(collided);
        } else {
            characterPosition = newPos;
        }

        // Verify tile reveals
        for (uint256 i = 0; i < reveals.length; i++) {
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

    // -----------------------------------------------------------------------
    // Convenience wrappers
    // -----------------------------------------------------------------------

    /**
     * @notice Move by signed deltas (−1, 0, +1). Handy for joystick UIs.
     */
    function move(int256 dx, int256 dy) external {
        Direction dir;
        if (dx < 0)      dir = Direction.Left;
        else if (dx > 0) dir = Direction.Right;
        else if (dy < 0) dir = Direction.Up;
        else if (dy > 0) dir = Direction.Down;
        else revert("zero-move");

        TileReveal[] memory empty;
        moveCharacter(dir, empty);
    }

    /**
     * @notice Mark a tile as revealed without a Merkle proof—useful in local tests.
     *         In production, prefer `moveCharacter` with proper proofs.
     */
    function reveal(uint256 x, uint256 y) external {
        bytes32 key = _tileKey(x, y);
        revealedTiles[key] = true;
        emit TileRevealed(x, y);
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------

    function _checkCollision(Position memory pos) internal view returns (uint256) {
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
