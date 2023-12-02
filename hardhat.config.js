require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

const account = process.env.DEPLOYER_SIGNER_PRIVATE_KEY;
const endpoint = process.env.INFURA_ENDPOINT;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url:endpoint,
      accounts:[account]
    }
  }
};

