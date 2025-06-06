const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contract with account:", deployer.address);

  const POAPAttendance = await hre.ethers.getContractFactory("POAPAttendance");
  const contract = await POAPAttendance.deploy(deployer.address);

  console.log("POAPAttendance deployed at:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
