const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("POAPAttendanceModule", (m) => {
  const poapAttendance = m.contract("POAPAttendance", [], {
    from: m.getAccount(0),
  });

  return { poapAttendance };
}); 