const hre = require('hardhat');

async function main() {
  const [signer] = await hre.ethers.getSigners();

  const gameAddress = process.env.GAME_ADDRESS || process.argv[2];
  const nftAddress = process.env.NFT_ADDRESS || process.argv[3];

  if (!gameAddress || !nftAddress) {
    console.error('Usage: GAME_ADDRESS=<addr> NFT_ADDRESS=<addr> npx hardhat run scripts/interact.js --network localhost');
    return;
  }

  const game = await hre.ethers.getContractAt('HitboxGame', gameAddress, signer);
  const nft = await hre.ethers.getContractAt('HitboxNFT', nftAddress, signer);

  console.log('Moving character right by 1...');
  await (await game.move(1, 0)).wait();

  console.log('Revealing tile at (1,0)...');
  await (await game.reveal(1, 0)).wait();

  const position = await game.character();
  console.log('Character position:', position.x.toString(), position.y.toString());

  console.log('Minting NFT to signer...');
  await (await nft.mint(signer.address)).wait();
  console.log('NFT minted with tokenId 1');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
