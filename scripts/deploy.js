/*  */
const hre = require("hardhat");

async function main() {
  const Vote = await hre.ethers.getContractFactory("Vote");
  const vote = await Vote.deploy();

  await vote.getDeployedCode();

  console.log("Vote app deployed to:", await vote.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
