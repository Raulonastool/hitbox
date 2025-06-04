# Contract Specification

## HitboxGame

Responsible for maintaining the shared game state.

- `Position public character` – X/Y coordinates of the communal character.
- `mapping(bytes32 => bool) public revealed` – tracks which tiles have been
  uncovered. The key is `keccak256(abi.encodePacked(x, y))`.
- `event CharacterMoved(uint256 x, uint256 y)` – emitted after `move()` updates
  the character.
- `event TileRevealed(uint256 x, uint256 y)` – emitted when a tile becomes known.

### Key Functions

- `move(int256 dx, int256 dy)` – shifts the character by a signed delta.
  The result is clamped to zero for negative coordinates.
- `reveal(uint256 x, uint256 y)` – marks a tile as revealed.

## HitboxNFT

Standard ERC‑721 token contract. Deployed with the address of `HitboxGame` so
future extensions can check ownership before allowing actions.

- `uint256 public nextTokenId` – auto‑incrementing ID used by `mint()`.
- `constructor(address game)` – sets the referenced game contract.
- `mint(address to)` – mints an NFT to `to` using `_safeMint`.

In a full implementation `HitboxNFT` could override `tokenURI()` to return an
on‑chain SVG built from the game's state, but that logic is not present in the
prototype.
