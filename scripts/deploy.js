// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const contract = await hre.ethers.deployContract(
    "sNGN"
  );

  await contract.waitForDeployment();  
  console.log(`Swiss-Naira token contract deployed to ${contract.target}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// Swiss-Naira token contract deployed to 
// 0x2C9c3817D019c0CDD16132AA842C0ED9C11C9A5a