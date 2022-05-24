const { task } = require("hardhat/config");
const { getContract } = require("./helpers");
const { ethers } = require("ethers");

task("mint", "Mints NFT from the contract")
.setAction(async function(taskArguments, hre) {
    const contract = await getContract("OnchainNft", hre);
    const transactionResponse = await contract.mintExp({
        gasLimit: 500_000
    });
    console.log(`Transaction Hash:${transactionResponse.hash}`);
});