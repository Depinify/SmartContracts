const { networkConfig } = require("../../helper-hardhat-config");
task("get-all-daos", "Calls an DEPNMarket Contract to getAllDaos")
  .addOptionalParam(
    "contract",
    "The address of the DEPNMarket contract that you want to call"
  )
  .setAction(async taskArgs => {
    const networkId = network.config.chainId;
    const contractAddr =
      taskArgs.contract || networkConfig[networkId]["DEPNMarket"];

    console.log(
      "Reading data from DEPNMarket contract ",
      contractAddr,
      "on network",
      network.name
    );
    const DEPNMarketContract = await ethers.getContractAt(
      "DEPNMarket",
      contractAddr
    );

    const result = await DEPNMarketContract.getAllDaos();
    console.log("Data is:", result);
    if (
      result === "" &&
      ["hardhat", "localhost", "ganache"].indexOf(network.name) === 0
    ) {
      console.log(
        "You'll either need to wait another minute, or fix something!"
      );
    }
    if (["hardhat", "localhost", "ganache"].indexOf(network.name) >= 0) {
      console.log(
        "You'll have to manually update the value since you're on a local chain!"
      );
    }
  });

module.exports = {};
