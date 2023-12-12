# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell

npm i
npm install --save-dev @nomicfoundation/hardhat-toolbox
npm install dotenv

npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js

// se trabaja con la red de Sepolia
npx hardhat run scripts/deploy.js --network sepolia
npx hardhat flatten > Flattened.sol

