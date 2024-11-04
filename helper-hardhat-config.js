const networkConfig = {
  11155111: {
    name: "sepolia",
    // Deploy Operator contract parameters
    owner: "0xCed9FFFCa7fB00B25b2F6CDCfBCcF2e679dfe15b",

    // linkToken address
    linkToken: "0x779877A7B0D9E8603169DdbD7836e478b4624789",

    // Oracle contract address
    oracle: "0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD",

    // Serverless Oracle contract address
    ZtControl: "0x0B9f15d07a2B91C2e321d3C1F9AD1fB3369aa6C0",
    mesh: "0x1b08714A2b422b27F1E8e4AE23bC4Ff6e73866ba",
    cod: "0x54cA3ACe7871f2Ec83B2fE06ED125e287cfAf1c9",
    // Container contract
    pod: "0x3971e1D7EE2375D5f067cCF1e2Dd1ACDd42e3EB4",
    deployment: "0x326820a4620eaA76871d2851E9d360619FE1b5Eb",
    cluster: "0x9Eb57282148E070DDb991A789887DaD6C6D0E1e9",
    node: "0xC74bf154E532Ff11473a833D924765537EC9B0c3",
    // ApiMarket
    DEPNMarket: "0x87F8dDD5fcA4Cd33a260666F9AF115b0482Ea9dd",
    DEPNToken: "0xE34f38912f6B73751aC3e38268dc7C18d9cd205C",

    //Serverless Site Info
    sitename: "gw105",
    sitehost: "http://198.211.96.142:8080",
    ztMeshJob: "84981edb58a2455aade2e9d797ae86f1",
    codjob: "3c09c86cffbd4563a3c0b2b97f411aec",

    // Parameters for calling the setAuthorizedSenders method in the Operator contract
    authorizedSenders: "0x68dd2c02ae32fc47EafE970dfc02d14030a0c624",

    fee: "0.1",
    fundAmount: "10", // 100
    automationUpdateInterval: "30"
  }
};
const developmentChains = ["hardhat", "localhost"];
const VERIFICATION_BLOCK_CONFIRMATIONS = 6;

module.exports = {
  networkConfig,
  developmentChains,
  VERIFICATION_BLOCK_CONFIRMATIONS
};
