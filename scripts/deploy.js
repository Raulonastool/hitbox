const hre = require('hardhat');

async function main() {
  await hre.run('compile');

  const HitboxGame = await hre.ethers.getContractFactory('HitboxGame');
  const game = await HitboxGame.deploy();
  await game.deployed();
  console.log('HitboxGame deployed to:', game.address);

  const HitboxNFT = await hre.ethers.getContractFactory('HitboxNFT');
  const nft = await HitboxNFT.deploy(game.address);
  await nft.deployed();
  console.log('HitboxNFT deployed to:', nft.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
