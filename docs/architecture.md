# On-Chain Architecture

This repository contains a lightweight prototype for the **Hitbox** game. Two
smart contracts make up the on-chain portion:

- **`HitboxGame`** – tracks the character's position and which map tiles have
  been revealed.
- **`HitboxNFT`** – standard ERC‑721 tokens intended to represent control of the
  game character.

```
Deploy
  │
  ├─ HitboxGame         (stores character state)
  └─ HitboxNFT ────────▶ (mintable NFTs referencing the game)
```

A typical flow is:

1. Deploy `HitboxGame`.
2. Deploy `HitboxNFT`, passing the game address to the constructor.
3. Mint NFTs to players.
4. NFT holders call `move()` and `reveal()` on `HitboxGame` to update game state.
5. Front‑ends read state and render an SVG or other representation.

`HitboxGame` currently exposes the raw position and reveal map on chain; a future
version could incorporate a Merkle root commitment and proof verification for the
hidden world. The NFT contract simply stores token ownership but can later gate
who is allowed to move the character.
