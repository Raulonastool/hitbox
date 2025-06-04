# HITBOX

Hitbox is an experimental on-chain platformer built with Solidity and Hardhat. NFT holders share control of a single character that explores a hidden world revealed one tile at a time through cryptographic proofs. This repository contains the prototype contracts, scripts, and documentation.

**Authors**: raulonastool  
**Date**: 12/31/2024

## Quick Start

```bash
npm install
npx hardhat compile
npx hardhat test
npx hardhat run scripts/deploy.js --network <network>
```

Set `PRIVATE_KEY` and `RPC_URL` in your environment to deploy to a specific network. Without these variables Hardhat uses its default local node.

## Directory Overview

- `contracts/` – Solidity contracts for the game and NFT.
- `test/` – Hardhat tests.
- `scripts/` – deployment and interaction helpers.
- `docs/` – design documents and specifications.
- `metadata/` – example token metadata.

## Conceptual Goals

- Treat smart contract logic and cryptographic commitments as a form of art.
- Enable "Twitch Plays" style decentralized collaboration among NFT holders.
- Keep the full map hidden yet provably valid using Merkle or zero-knowledge proofs.

## Key Components

- **Game World** – large 2D grid committed on chain.
- **Character Box** – shared player position stored by the contract.
- **Perspective Window** – 32×32 region rendered as on-chain SVG for the NFT.
- **Obstacle Boxes** – optional moving or static obstacles that reset the character on collision.
- **HitboxNFT** – ERC‑721 tokens granting movement rights.

Detailed architecture and contract specifications are available in
[docs/architecture.md](docs/architecture.md) and
[docs/specification.md](docs/specification.md).

## Contributing / Forking

1. Fork or clone this repository.
2. Create a feature branch for your changes.
3. Run the quick start commands and ensure tests pass.
4. Submit a pull request describing your modifications.

We welcome prototypes, front‑end experiments, and gameplay ideas.
