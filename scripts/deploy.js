const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  const HitboxGame = await hre.ethers.getContractFactory("HitboxGame");
  const game = await HitboxGame.deploy();
  await game.deployed();

  console.log("HitboxGame deployed to:", game.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
