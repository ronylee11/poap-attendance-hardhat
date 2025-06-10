const hre = require("hardhat");

async function main() {
  console.log("Deploying POAPAttendance contract...");

  const POAPAttendance = await hre.ethers.getContractFactory("POAPAttendance");
  const poapAttendance = await POAPAttendance.deploy();

  await poapAttendance.waitForDeployment();

  const address = await poapAttendance.getAddress();
  console.log(`POAPAttendance deployed to: ${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
