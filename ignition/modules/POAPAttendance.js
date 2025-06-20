const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

export default buildModule("POAPAttendanceModule", (m) => {
  const JAN_1ST_2030 = 1893456000;
  const ONE_GWEI = 1_000_000_000n;

  module.exports = buildModule("LockModule", (m) => {
    const unlockTime = m.getParameter("unlockTime", JAN_1ST_2030);
    const lockedAmount = m.getParameter("lockedAmount", ONE_GWEI);

    const poapContract = m.contract("POAPAttendance", [unlockTime], {
      value: lockedAmount,
      gasLimit: 5000000,
    });

    return { poapContract };
  });
});
