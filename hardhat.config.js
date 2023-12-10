require("@nomicfoundation/hardhat-toolbox");
<<<<<<< HEAD
require('dotenv').config()

const account = process.env.DEPLOYER_SIGNER_PRIVATE_KEY;
const endpoint = process.env.INFURA_ENDPOINT;
=======
>>>>>>> ef8d48881c0dda3cbd093515e24d2ac1ba9a6d4b

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
<<<<<<< HEAD
  networks: {
    sepolia: {
      url:endpoint,
      accounts:[account]
    }
  }
};

=======
};
>>>>>>> ef8d48881c0dda3cbd093515e24d2ac1ba9a6d4b
