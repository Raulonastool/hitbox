# HITBOX: A Conceptual On-Chain Platformer

**Authors**: raulonastool
**Date**: 12/31/2024

---

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Conceptual Goals](#conceptual-goals)  
3. [Key Components & Terminology](#key-components--terminology)  
   1. [Game World](#game-world)  
   2. [Character Box](#character-box)  
   3. [Perspective Window](#perspective-window)  
   4. [Obstacle Boxes](#obstacle-boxes)  
   5. [On-Chain Artwork (NFT)](#on-chain-artwork-nft)  
   6. [Hidden World + Zero-Knowledge](#hidden-world--zero-knowledge)  
4. [System Architecture](#system-architecture)  
   1. [High-Level Flow](#high-level-flow)  
   2. [Smart Contracts](#smart-contracts)  
   3. [Data Structures & State](#data-structures--state)  
   4. [Gameplay Logic](#gameplay-logic)  
   5. [On-Chain SVG Rendering](#on-chain-svg-rendering)  
   6. [ZK / Merkle Tree Mechanics](#zk--merkle-tree-mechanics)  
5. [Detailed Functionality](#detailed-functionality)  
   1. [Movement & Collision](#movement--collision)  
   2. [Obstacle Behavior](#obstacle-behavior)  
   3. [Reset Conditions](#reset-conditions)  
   4. [Access Control](#access-control)  
   5. [Fee Structure](#fee-structure)  
   6. [Event Emission](#event-emission)  
6. [Technical Considerations](#technical-considerations)  
   1. [Gas Costs & Scalability](#gas-costs--scalability)  
   2. [Randomness Sources](#randomness-sources)  
   3. [NFT Metadata Updates & Marketplace Caching](#nft-metadata-updates--marketplace-caching)  
   4. [Security Concerns](#security-concerns)  
   5. [StarkNet or Other L2 Options](#starknet-or-other-l2-options)  
7. [Potential Extensions & Front-Ends](#potential-extensions--front-ends)  
8. [Implementation Roadmap](#implementation-roadmap)  
   1. [Phase 1: Prototype](#phase-1-prototype)  
   2. [Phase 2: Full Deployment](#phase-2-full-deployment)  
9. [FAQ / Common Questions](#faq--common-questions)  
10. [Conclusion & Next Steps](#conclusion--next-steps)

---

## 1. Project Overview

**Hitbox** is a conceptual blockchain-based platformer game where the **game world** lives on-chain as a cryptographic commitment (Merkle root or advanced ZK structure). It doubles as both a **code-based art installation** and a **decentralized, collaborative game**. Core elements:

- A **2D grid** map, larger than any single visible screen (retro platformer style).  
- A **character box** that can be moved by NFT holders.  
- A **32×32 window** following the character, effectively acting as the game’s “camera.”  
- Various **obstacle boxes** (some stationary, some on predetermined or random paths).  
- A partially **hidden world**, revealed only when the character explores new tiles. The user (or a front-end) must provide **proof** to confirm each newly revealed tile is valid.  
- An **on-chain SVG** that updates based on game state, forming the NFT artwork on marketplaces.

**The gameplay dynamic** is reminiscent of “Twitch Plays Pokémon,” as all NFT holders collectively control a single character. This fosters a sense of communal chaos and creative exploration.

---

## 2. Conceptual Goals

1. **Code as Art**  
   - Emphasize the smart contract logic, protocol-level truth, and cryptographic primitives as **creative media**.

2. **Decentralized Collaboration**  
   - Only **NFT holders** can move the character; everyone else is a spectator. Similar to “Twitch Plays,” it’s a social experiment in mass coordination.

3. **Hidden but Provable**  
   - The larger world is unknown but guaranteed to exist. **Merkle or zero-knowledge proofs** ensure tiles are revealed consistently with the original map, without fully exposing it from the start.

4. **Multiple Visual Interpretations**  
   - The code is open-source, so anyone can design a front-end to represent the hidden world in different styles or “skins.” Think of how **Loot** derivatives offer multiple “visual layers” over the same data.

5. **Everlasting Ethereum Deployment**  
   - Ultimately, the canonical version of **Hitbox** will live on Ethereum—the widely trusted, “granddaddy” chain for on-chain art. This ensures the piece endures indefinitely, barring extreme catastrophes.

6. **Phased Approach to Zero-Knowledge**  
   - In early phases, store the map as a hashed or Merkle-rooted data structure. Users reveal tiles with a Merkle proof.  
   - In more advanced phases, integrate a full **zero-knowledge approach** (potentially on StarkNet or another ZK-Rollup), anchoring only the final states or periodic checkpoints on Ethereum.

---

## 3. Key Components & Terminology

### 3.1 Game World
- Represents a 2D grid of arbitrary size, e.g., 512×512.  
- **Hidden** to players except for revealed tiles.  
- Stored off-chain or partially on-chain as a cryptographic commitment (Merkle root).

### 3.2 Character Box
- The “player” entity, uniquely controlled by holders of a special NFT.  
- Has coordinates `(x, y)` stored in the game contract.  
- Moves according to user commands (e.g., `moveLeft()`, `jump()`, etc.).

### 3.3 Perspective Window
- Conceptual “camera” that frames a **32×32** region around the character.  
- This is what the on-chain SVG (NFT) displays at any given moment.

### 3.4 Obstacle Boxes
- Either stationary or moving obstacles.  
- Some might have random or cyclical movement patterns.  
- Colliding with them triggers a **reset** of the character’s position.

### 3.5 On-Chain Artwork (NFT)
- An ERC721 or ERC1155 contract that **mints** tokens to grant movement rights.  
- Holds a dynamic **on-chain SVG** reflecting the game state.  
- Marketplaces display the **Hitbox** NFT with updated imagery, showing the 32×32 camera view.
- [Example metadata](metadata/example.json) shows the JSON fields used to encode the dynamic SVG data.

### 3.6 Hidden World + Zero-Knowledge
- The full map or large segments remain hidden.  
- A **Merkle root** or zero-knowledge approach proves each revealed tile matches the original, preventing tampering.  
- For a truly private reveal, L2 solutions like **StarkNet** can handle big computations or advanced ZK logic, periodically anchoring the final “truth” to Ethereum.

---

## 4. System Architecture

### 4.1 High-Level Flow

1. **Initialize**  
   - Deploy `HitboxGame` contract with a **Merkle root** (or similar) representing the entire map.  
   - Deploy `HitboxNFT` contract for tokenized control (movement rights).

2. **Mint NFT**  
   - Collectors purchase or mint the NFT, which grants them the right to call `moveCharacter()`.

3. **User Movement**  
   - A token holder calls `moveCharacter(direction)` on the `HitboxGame`.  
   - The game contract updates the character’s position, checks for collisions, and logs the state change.

4. **Reveal Tiles (Proof Submission)**  
   - When the character steps onto new, previously hidden tiles, the **caller** provides the tile data plus a **Merkle (or ZK) proof**.  
   - The contract verifies that this tile data is consistent with the on-chain Merkle root.  
   - If valid, the tile is now considered “revealed.”

5. **On-Chain SVG Update**  
   - The `HitboxNFT` references `HitboxGame` state to build an updated 32×32 pixel window around the character.  
   - The NFT’s `tokenURI()` returns a fresh **data:` SVG** for marketplaces.

6. **Observing the Game**  
   - Anyone can watch the state changes or see the NFT updates.  
   - Only NFT holders can direct the character’s movements and reveal new areas.

### 4.2 Smart Contracts

1. **`HitboxGame`**  
   - Contains the **Merkle root** referencing the hidden world, plus character/obstacle data.  
   - Manages movement, collisions, tile reveal logic, and events.

2. **`HitboxNFT`**  
   - Implements ERC721 or ERC1155 for tokenized access.  
   - Generates a dynamic SVG in `tokenURI()` that visualizes the 32×32 window based on the game’s state.

### 4.3 Data Structures & State

```solidity
contract HitboxGame {
    // A Merkle root or other cryptographic commitment to the hidden world.
    bytes32 public worldRoot;

    // Main character position.
    struct Position {
        uint256 x;
        uint256 y;
    }
    Position public characterPosition;

    // Obstacles (can be stationary or dynamic).
    struct Obstacle {
        Position currentPosition;
        // Additional fields, e.g., movement pattern or random seed.
    }
    mapping(uint256 => Obstacle) public obstacles;

    // 'window' is conceptual, derived from characterPosition in read-only calls.
}
```

### 4.4 Gameplay Logic
Movement (e.g., moveLeft(), moveRight(), jump()):
Adjust (x, y) accordingly.
Check for collisions with obstacles or boundaries.
Collision Check: If the new position overlaps an obstacle, reset the character to (startX, startY).
Tile Reveal:
If the new position or adjacent positions are unrevealed tiles, the caller provides tile data + a Merkle/zk proof.
The contract verifies the proof. If correct, the tile is marked as “revealed.”
### 4.5 On-Chain SVG Rendering
HitboxNFT.tokenURI() calls HitboxGame to determine the 32×32 region’s data.
Builds an SVG snippet representing this slice of the world.
Returns a base64-encoded data: URI for marketplace display.
### 4.6 ZK / Merkle Tree Mechanics
Commitment: A Merkle root representing the entire map is stored in worldRoot.
Proof Submission: The caller sends (tileData, proof[]) to prove the tile is part of the original map.
Contract Verification:
The contract recomputes hashes from tileData up through the proof’s path.
If the final hash matches worldRoot, the tile is accepted as genuine.
(Optionally) a zero-knowledge circuit can hide certain tile properties if privacy is desired.
Off-Chain Storage: The raw tile data is typically stored off-chain. The contract only needs the final proof to validate correctness.
## 5. Detailed Functionality
### 5.1 Movement & Collision
```
function moveCharacter(Direction dir, TileReveal[] calldata reveals) external onlyNFTCollector payable {
    // 1. (Optional) Check msg.value against any required fee.
    // 2. Update characterPosition based on dir (left, right, up, down, jump).
    // 3. Check collisions (if collision, reset characterPosition).
    // 4. For each unrevealed tile in 'reveals', verify proof against worldRoot.
    // 5. Mark valid tiles as 'revealed' and emit events.
    // 6. Emit CharacterMoved event.
}
```

Direction could be an enum ({ Left, Right, Up, Down, Jump }).
TileReveal might contain (x, y, tileData, proof[]).
### 5.2 Obstacle Behavior
Stationary: (x, y) never changes.
Dynamic: Could shift every move (e.g., left-to-right) or use random seeds.
Updating obstacles might happen each time moveCharacter() is called, or in a separate “tick” method.
### 5.3 Reset Conditions
If the new (x, y) overlaps any obstacle, the character position reverts to (startX, startY).
(Optional) track collision count for stats or NFT metadata.
### 5.4 Access Control
A modifier onlyNFTCollector() ensures only holders of the Hitbox NFT can invoke character movement.
If multiple NFTs exist, define whether each NFT grants a single move per block or unlimited moves, etc.
### 5.5 Fee Structure
Optional per-move fee or gas subsidy, used to fund further development or reduce spam.
Could be managed within moveCharacter().
### 5.6 Event Emission
```
event CharacterMoved(uint256 x, uint256 y);
event CollisionDetected(uint256 obstacleId);
event TileRevealed(uint256 x, uint256 y);
---
```
Off-chain indexers or front-ends can subscribe to these events to visualize state changes in real time.
## 6. Technical Considerations
### 6.1 Gas Costs & Scalability
Merkle proofs for each tile are relatively cheap, but storing large arrays on-chain is expensive.
Consider compressing tile data or using an L2 (like StarkNet, Optimism, Arbitrum, etc.) to reduce costs.
The final or periodic states can still be anchored on Ethereum for permanence.
### 6.2 Randomness Sources
If obstacles or events require randomness, consider Chainlink VRF or blockhash-based pseudo-randomness.
True unpredictability might be valuable for dynamic obstacles or emergent gameplay.
### 6.3 NFT Metadata Updates & Marketplace Caching
Some marketplaces cache metadata. Refreshing may be needed to display updated states.
Ensure your tokenURI() logic efficiently encodes the SVG for every state change.
### 6.4 Security Concerns
Proof Verification: Must properly validate Merkle/zk proofs so no one can inject fraudulent tiles.
Collision & Movement: Ensure coordinates aren’t spoofed.
ZK Implementation: If using zero-knowledge, your circuits and proof system must be robust against exploits.
### 6.5 StarkNet or Other L2 Options
StarkNet natively uses STARK proofs, making it ideal for heavy or complex zero-knowledge logic.
Cairo (StarkNet’s language) is specifically designed for ZK-friendliness but has a learning curve.
Ultimately, your final “state commitments” could be anchored on Ethereum to ensure the artwork’s longevity.
## 7. Potential Extensions & Front-Ends
Custom UIs

Anyone can render the same underlying data with a different art style—pixel art, ASCII, top-down, isometric, etc.
Level Editing

A DAO or community might propose expansions or patches to the map, continuing the game’s narrative.
Forking

Because it’s open-source, new creators can remix or build spin-offs with alternative mechanics or worlds.
## 8. Implementation Roadmap
### 8.1 Phase 1: Prototype
Deploy minimal HitboxGame + HitboxNFT on a testnet (e.g., Goerli, or an L2 testnet).
Use a small map (e.g., 8×8 or 16×16) with a simple hashed reference (not full ZK).
Validate the communal control concept: do people enjoy “Twitch Plays” style interactions?
### 8.2 Phase 2: Full Deployment
Scalable ZK Integration

Migrate the project to or incorporate an L2 like StarkNet for advanced zero-knowledge or heavier computations.
Periodically anchor state on Ethereum for finality and permanence.
Expanded Map & Dynamic Obstacles

Introduce a large hidden world (512×512 or more).
Add time-based or random obstacle movements for richer gameplay.
Final Ethereum Contract

Release the canonical version on Ethereum mainnet, ensuring the art installation remains accessible indefinitely.
All proofs or rollup data from StarkNet can settle to Ethereum, preserving the game’s state for posterity.
## 9. FAQ / Common Questions
**Why not store the entire map on-chain?**

Storing large arrays is prohibitively expensive. Commitments (Merkle roots, ZK proofs) minimize on-chain storage while keeping authenticity verifiable.

**How do I see unrevealed tiles?**

Someone (the user/front-end) must provide the tile data + proof. If valid, the contract marks it revealed. Without that proof, it remains hidden.

**What if I want a purely private map?**

Zero-knowledge approaches can hide tile details while still proving correctness. This may require more advanced circuits or an L2 specialized in ZK (like StarkNet).

**How do I handle dynamic metadata on NFT marketplaces?**

Many marketplaces cache data. You might rely on a metadata “refresh” button, or certain platforms that honor dynamic metadata more readily.

**Why eventually deploy on Ethereum?**

Ethereum has historical significance and is widely considered the most “permanent” chain. Anchoring your final state or storing your final contract on Ethereum helps preserve the art for the long term.
## 10. Conclusion & Next Steps
Hitbox explores the intersection of decentralized gaming, conceptual art, and cryptographic proofs. By combining on-chain logic, interactive NFT mechanics, and a hidden-but-provable world, it aims to spark curiosity, collaboration, and creativity.

**How You Can Contribute**
Review & Comment: Open issues or pull requests with ideas or improvements.
Try the Prototype: Deploy a local or testnet version. Experiment with tile reveals, collisions, and NFT movement rights.
Extend or Fork: Build new front-ends, add new lore, or spin off your own cryptographic world.
Join the Conversation: Discuss on Discord or social platforms. Community input is key to shaping the final deployment.
Thank you for exploring Hitbox!
