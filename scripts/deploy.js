const hre = require("hardhat");

async function main() {
  const DEPNMarket = await hre.ethers.getContractFactory("DEPNMarket");
  const lock = await DEPNMarket.deploy();

  await lock.deployed();

  console.log(`DEPNMarket deployed to ${lock.address}`);

  const DEPNToken = await hre.ethers.getContractFactory("DEPNToken");
  const DEPNTokenDeploy = await DEPNToken.deploy();

  await DEPNTokenDeploy.deployed();

  console.log(`DEPNToken deployed to ${DEPNTokenDeploy.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
