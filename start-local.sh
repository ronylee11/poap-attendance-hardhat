#!/bin/bash

# Start Hardhat local network in the background
npx hardhat node &
HARDHAT_PID=$!

# Wait for the network to start
sleep 5

# Deploy the contract
npx hardhat run scripts/deploy.js --network localhost

# Keep the script running
wait $HARDHAT_PID 