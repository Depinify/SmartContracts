const { networkConfig } = require("../../helper-hardhat-config");
task(
  "get-balance",
  "Calls the DEPNToken contract to read the amount of DEPNToken owned by the account."
)
  .addOptionalParam("contract", "The address the DEPNToken contract")
  .addParam("account", "The address of the account you want the balance for")
  .setAction(async taskArgs => {
    const networkId = network.config.chainId;
    const contractAddr =
      taskArgs.contract || networkConfig[networkId]["DEPNToken"];
    const account = taskArgs.account;

    console.log(
      "Reading DEPNToken owned by",
      account,
      "on network",
      network.name
    );

    const DEPNTokenContract = await ethers.getContractAt(
      "DEPNToken",
      contractAddr
    );

    //Call the balanceOf method
    const balance = ethers.utils.formatUnits(
      await DEPNTokenContract.balanceOf(account)
    );
    console.log("Amount of DEPNToken owned by", account, "is", balance);
  });

module.exports = {};
