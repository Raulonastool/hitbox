// scripts/deploy.js
const hre = require('hardhat');

async function main() {
  // Ensure everything is compiled
  await hre.run('compile');

  // -----------------------------------------------------------------------
  // Deployer info
  // -----------------------------------------------------------------------
  const [deployer] = await hre.ethers.getSigners();
  console.log('Deploying contracts with account:', deployer.address);
  console.log(
    'Deployer balance:',
    (await deployer.provider.getBalance(deployer.address)).toString()
  );

  // -----------------------------------------------------------------------
  // Deploy HitboxGame
  // -----------------------------------------------------------------------
  const root = hre.ethers.keccak256(hre.ethers.toUtf8Bytes('genesis')); // dummy Merkle root
  const HitboxGame = await hre.ethers.getContractFactory('HitboxGame');
  const game = await HitboxGame.deploy(root, 0, 0); // start at (0,0)
  await game.deployed();
  console.log('HitboxGame deployed to:', game.address);

  // -----------------------------------------------------------------------
  // Deploy HitboxNFT
  // -----------------------------------------------------------------------
  const HitboxNFT = await hre.ethers.getContractFactory('HitboxNFT');
  const nft = await HitboxNFT.deploy(game.address);
  await nft.deployed();
  console.log('HitboxNFT deployed to:', nft.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
