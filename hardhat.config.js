require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepoliaScroll: {
      url: process.env.SEPOLIA_SCROLL_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
