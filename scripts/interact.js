// scripts/interact.js
// Helper script to poke the deployed HitboxGame & HitboxNFT contracts.
const hre = require('hardhat');

async function main() {
  const [signer] = await hre.ethers.getSigners();

  // Accept addresses via env vars or CLI args
  const gameAddress = process.env.GAME_ADDRESS || process.argv[2];
  const nftAddress  = process.env.NFT_ADDRESS  || process.argv[3];

  if (!gameAddress || !nftAddress) {
    console.error(
      'Usage:\n' +
        '  GAME_ADDRESS=<addr> NFT_ADDRESS=<addr> ' +
        'npx hardhat run scripts/interact.js --network localhost'
    );
    process.exit(1);
  }

  // Attach to deployed contracts
  const game = await hre.ethers.getContractAt('HitboxGame', gameAddress, signer);
  const nft  = await hre.ethers.getContractAt('HitboxNFT',  nftAddress,  signer);

  // -----------------------------------------------------------------------
  // Demo actions
  // -----------------------------------------------------------------------

  console.log('Moving character right by 1...');
  await (await game.move(1, 0)).wait();

  console.log('Revealing tile at (1,0)...');
  await (await game.reveal(1, 0)).wait();

  const pos = await game.characterPosition();
  console.log(`Character position: (${pos.x}, ${pos.y})`);

  console.log('Minting NFT to signer...');
  await (await nft.mint()).wait();
  console.log('NFT minted with tokenId', (await nft.nextId()) - 1);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
