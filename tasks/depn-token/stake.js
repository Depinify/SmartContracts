const { networkConfig } = require("../../helper-hardhat-config");

task("stake", "Calls an DEPNMarket Contract to stake")
  .addOptionalParam(
    "contract",
    "The address of the DEPNMarket contract that you want to call"
  )
  .addParam("amount", "amount")
  .setAction(async taskArgs => {
    const networkId = network.config.chainId;
    const contractAddr =
      taskArgs.contract || networkConfig[networkId]["DEPNToken"];
    const amount = taskArgs.amount;

    console.log("Contract:", contractAddr, "network:", network.name);

    const DEPNTokenContract = await ethers.getContractAt(
      "DEPNToken",
      contractAddr
    );

    const stakeResult = await DEPNTokenContract.stake(amount);
    console.log(
      "Contract:",
      contractAddr,
      "Transaction Hash: ",
      stakeResult.hash
    );
    await stakeResult.wait();

    const stakerExists = await DEPNTokenContract.stakerExists();
    console.log("User stake status is:", stakerExists);
  });
module.exports = {};
