const { networkConfig } = require("../../helper-hardhat-config");
task("get-user-all-orders", "Calls an DEPNToken Contract to getUserAllOrders")
  .addOptionalParam(
    "contract",
    "The address of the DEPNToken contract that you want to call"
  )
  .setAction(async taskArgs => {
    const networkId = network.config.chainId;
    const contractAddr =
      taskArgs.contract || networkConfig[networkId]["DEPNToken"];

    console.log(
      "Reading data from DEPNToken contract ",
      contractAddr,
      "on network",
      network.name
    );
    const DEPNTokenContract = await ethers.getContractAt(
      "DEPNToken",
      contractAddr
    );

    const result = await DEPNTokenContract.getUserAllOrders();
    console.log("Data is:", result);
  });

module.exports = {};
