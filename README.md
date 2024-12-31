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
7. [Potential Extensions & Front-Ends](#potential-extensions--front-ends)  
8. [Implementation Roadmap](#implementation-roadmap)  
9. [FAQ / Common Questions](#faq--common-questions)  

---

## 1. Project Overview

**Hitbox** is a conceptual blockchain-based platformer game where the **“game world”** lives entirely on-chain. It is simultaneously a **code-based art installation** and a **collaborative decentralized game**. We rely on smart contracts to define:

- A **2D grid** map larger than the screen (mimicking retro platformers).
- A **character box** that moves through this grid.
- A **32×32 pixel window** that follows the character as the “camera.”
- Various **obstacle boxes** (some stationary, some mobile).
- A partially **hidden world** that is only revealed as the character explores (using zero-knowledge or Merkle proofs).
- A **visual NFT** that updates based on the on-chain state, representing the view through the current camera window.

---

## 2. Conceptual Goals

1. **Code as Art**: Highlighting how smart contracts, protocol-level truth, and cryptographic primitives can become a form of artistic expression.  
2. **Decentralized Collaboration**: Only **NFT holders** can move the character, yet everyone can observe the game’s progress.  
3. **Hidden but Proven**: The larger world is unknown but verifiably exists. Movement reveals previously hidden areas.  
4. **Reinterpretable**: The code is open-source, allowing anyone to build alternative visual interfaces or expansions.

---

## 3. Key Components & Terminology

### 3.1 Game World
- A 2D grid representing the play area.  
- Potentially large (e.g., 512×512 tiles, or an arbitrary size).  
- For on-chain storage, we consider **Merkle tree** commitments or compressed representations.

### 3.2 Character Box
- The “player” object.  
- Only one character box exists in the primary game state.  
- Coordinates: (`x`, `y`), stored on-chain.  
- Moves upon user commands (NFT holders call `moveLeft()`, `moveRight()`, `jump()`, etc.).

### 3.3 Perspective Window
- A 32×32 view that centers around the character box.  
- Defines which part of the world is currently “visible” in the on-chain NFT representation.  
- Conceptually, a bounding box around (`character.x - 16`, `character.y - 16`) to (`character.x + 16`, `character.y + 16`).

### 3.4 Obstacle Boxes
- Blocks or enemies in the game world that might be stationary or move in periodic/pseudo-random patterns.  
- Collision with an obstacle triggers a **reset** of the character’s position.

### 3.5 On-Chain Artwork (NFT)
- An ERC721 (or ERC1155) contract that represents the Hitbox “game controller.”  
- Holds an **on-chain SVG** that reflects the current state.  
- The SVG is updated whenever the character moves or a collision occurs.  
- Marketplaces display the NFT as a dynamically generated artwork.

### 3.6 Hidden World + Zero-Knowledge
- The entire map or large segments are not openly stored in a plain array.  
- A **Merkle root** or **zk-proof** approach ensures authenticity without revealing all tiles at once.  
- On each move, newly revealed tiles are proven to match the original design.

---

## 4. System Architecture

### 4.1 High-Level Flow

1. **Initialize Game**  
   - Deploy `HitboxGame` contract with a world Merkle root (or some data structure) describing the hidden map.  
   - Deploy `HitboxNFT` contract to manage the NFT(s) granting movement rights.

2. **Mint NFT**  
   - User(s) buy or acquire the NFT from `HitboxNFT`.  
   - Now they can interact with `HitboxGame`.

3. **Character Movement**  
   - An NFT holder calls `moveCharacter(direction)`.  
   - The game contract updates the character’s position, checks collisions, updates on-chain state.  
   - If new map tiles are revealed, the user provides a Merkle proof or zero-knowledge proof.

4. **On-Chain SVG Update**  
   - After each state change, the NFT contract’s `tokenURI()` references the `HitboxGame` state to build a fresh SVG.  
   - The displayed window is the 32×32 region around the character.

5. **Observing the Game**  
   - Anyone can read the state from the blockchain or view the NFT.  
   - Only NFT holders can push the game forward.

### 4.2 Smart Contracts

There are two primary contracts:

1. **`HitboxGame`** (core logic)  
   - Stores the map data reference (Merkle root), character coordinates, obstacle positions, etc.  
   - Implements movement, collision, and events.

2. **`HitboxNFT`** (ERC721 or ERC1155)  
   - Mints tokens that grant movement rights.  
   - Renders the current state as an on-chain SVG in `tokenURI()`.

### 4.3 Data Structures & State

```solidity
contract HitboxGame {
    // The map is stored as a Merkle root or some compressed representation.
    bytes32 public worldRoot;

    // The character's position.
    struct Position { 
        uint256 x; 
        uint256 y; 
    }
    Position public characterPosition;

    // Obstacles: stationary or dynamic.
    struct Obstacle {
        Position currentPosition;
        // pattern definition or random seed
    }
    mapping(uint256 => Obstacle) public obstacles;

    // The 'window' is conceptual; we compute it using characterPosition.
}
```
---

### 4.4 Gameplay Logic

- **Movement**: Functions like `moveLeft()`, `moveRight()`, `jump()`.  
- **Collision Check**: Compare the new character position with obstacle positions.  
- **Reset**: If a collision occurs, reset the character to initial coordinates.

### 4.5 On-Chain SVG Rendering

- The NFT contract queries the `HitboxGame` contract for relevant data (character position, visible tiles, obstacles in range).  
- Generates an **SVG** snippet for the 32×32 slice.  
- Encodes the SVG in a base64 `data:` URI for `tokenURI()`.

### 4.6 ZK / Merkle Tree Mechanics

- **Merkle Tree**: The map is chunked into tiles or blocks. Each block is hashed; these hashes combine into a Merkle root.  
- **Proof**: When the character enters a new region, the user provides a Merkle proof to show the newly revealed data matches the root.  
- **Zero-Knowledge** (Optional / Advanced): For privacy, store the map in a ZK-friendly structure (e.g., zk-SNARK or STARK) so that block validity can be proven without revealing everything.

---

## 5. Detailed Functionality

### 5.1 Movement & Collision

```solidity
function moveCharacter(Direction dir) external onlyNFTCollector payable {
    // 1. Ensure msg.value covers movement fee (if any).
    // 2. Compute new position.
    // 3. Check collision with obstacles:
    //    - If collision, reset characterPosition.
    // 4. Otherwise, update characterPosition.
    // 5. Emit event (CharacterMoved, ObstaclesUpdated).
}
```

- Directions could be an enum:
  ```solidity
  enum Direction { Left, Right, Up, Down, Jump }
  ```
- For a classic platformer “jump,” add more complex logic (gravity, vertical arcs, etc.).

### 5.2 Obstacle Behavior

- **Stationary**: Simply store the obstacle’s `(x, y)`.  
- **Dynamic**: For instance, obstacles move left/right or follow a pseudo-random path each “tick” or each time the player moves.  
- Implementation detail:
  - Either update obstacles on every player move, or include a dedicated function to progress obstacle states.

### 5.3 Reset Conditions

- If `characterPosition` overlaps with an obstacle, reset `characterPosition` to `(startX, startY)`.  
- (Optional) Track total collisions in the contract to display in metadata or for gameplay logic.

### 5.4 Access Control

- A modifier `onlyNFTCollector()` ensures only token holders can move the character.  
- If multiple NFTs exist, define whether each NFT entitles the holder to a certain number of moves or unlimited moves.

### 5.5 Fee Structure

- An optional fee per move. Potential uses:
  - Funding further development or community treasury.  
  - Incentivizing puzzle-solving.  
  - Creating a scarcity mechanism.

### 5.6 Event Emission

```solidity
event CharacterMoved(uint256 x, uint256 y);
event CollisionDetected(uint256 obstacleId);
event TilesRevealed(bytes32[] merkleProof);
```

- These events allow off-chain indexers or UIs to track progress.

---

## 6. Technical Considerations

### 6.1 Gas Costs & Scalability

- Storing large maps on-chain is costly.  
- Mitigations:
  - Use a Merkle root or compressed data structure.  
  - Consider deploying on Layer-2 (Arbitrum, Optimism, zkSync, Polygon) for lower fees.

### 6.2 Randomness Sources

- For dynamic obstacles or procedural generation, a secure random source (e.g., Chainlink VRF) may be needed.  
- For a purely conceptual project, blockhash-based pseudo-randomness might suffice, albeit less secure.

### 6.3 NFT Metadata Updates & Marketplace Caching

- Some NFT marketplaces cache metadata. You might need to “refresh” or rely on platforms that support dynamic metadata.  
- Make sure your contract’s `tokenURI()` is designed to reflect real-time game state.

### 6.4 Security Concerns

- Guard against fake Merkle proofs or malicious moves.  
- Verify collisions carefully.  
- For zero-knowledge proofs, ensure the circuit or proof system is correct and unexploitable.

---

## 7. Potential Extensions & Front-Ends

- **Custom UIs**: Anyone can build a graphical or even text-based front-end that reads the on-chain state.  
- **Level Editing**: Allow a community or DAO to propose expansions to the map.  
- **Forking**: The open-source nature lets others replicate or remix the core concept.

---

## 8. Implementation Roadmap

1. **Proof-of-Concept**  
   - Implement a minimal `HitboxGame` and `HitboxNFT` on a testnet with a small grid.  
   - Store or hardcode a simple 8×8 map as a demo.

2. **Merkle / ZK Integration**  
   - Scale the map, hiding most of it via a Merkle root or zk approach.  
   - Reveal new segments only when the character explores them.

3. **Dynamic Obstacles**  
   - Add timed or turn-based patterns for obstacle movement.

4. **Full On-Chain SVG**  
   - Enhance the `tokenURI()` to generate a robust SVG, perhaps with additional styling or color coding.  
   - Verify that the displayed window updates consistently.

5. **UI / Community Launch**  
   - Build a front-end with Web3 integration.  
   - Mint the initial NFTs on a testnet and let holders interact.  
   - Gather feedback, refine logic, then consider mainnet or L2 deployment.

---

## 9. FAQ / Common Questions

1. **Why store the game on-chain?**  
   Immutability and trustless verification align with the conceptual spirit of decentralized, verifiable art.

2. **How do I see the hidden world if it’s unrevealed?**  
   You can’t, unless you hold valid proofs. It’s part of the “mystery” concept—knowing something exists without seeing it all at once.

3. **Why use zero-knowledge proofs?**  
   They allow proving the authenticity of unrevealed parts without exposing them in plain text.

4. **Does this scale for large maps?**  
   Potentially, but it’s resource-intensive. Layer-2s or off-chain data plus on-chain proofs might be necessary.

5. **Can I build my own front-end or expand the game?**  
   Absolutely. The system is open-source and intended for creative reinterpretation.

---

## Conclusion

**Hitbox** is more than a blockchain game; it’s an evolving artwork and a communal experience. By blending **smart contract logic**, **on-chain SVG rendering**, and **cryptographic proofs**, it pushes the boundaries of decentralized, collaborative art.

### Next Steps / How to Contribute

- **Review the spec**: Suggest clarifications or improvements.  
- **Try it out**: Experiment with a local or testnet deployment.  
- **Extend or fork**: Propose front-end designs, expansions, or alternative mechanics.  

**Thank you for exploring Hitbox!** If you have questions or want to contribute, reach out via [contact info or GitHub issues].
```
