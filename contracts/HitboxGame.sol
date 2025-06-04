// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title HitboxGame
/// @notice Minimal contract storing a world root commitment
contract HitboxGame {
    /// @notice Merkle root commitment to the world map
    bytes32 public worldRoot;

    /// @param _worldRoot Initial world root
    constructor(bytes32 _worldRoot) {
        worldRoot = _worldRoot;
    }
}

