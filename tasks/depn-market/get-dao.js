const { networkConfig } = require("../../helper-hardhat-config");
task("get-dao", "Calls an DEPNMarket Contract to getDao by daoId")
  .addOptionalParam(
    "contract",
    "The address of the DEPNMarket contract that you want to call"
  )
  .addParam("daoId", "daoId")
  .setAction(async taskArgs => {
    const networkId = network.config.chainId;
    const contractAddr =
      taskArgs.contract || networkConfig[networkId]["DEPNMarket"];
    const daoId = taskArgs.daoId;

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

    const result = await DEPNMarketContract.getDao(daoId);
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
