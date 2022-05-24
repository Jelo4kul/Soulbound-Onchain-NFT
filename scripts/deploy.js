const { task } = require("hardhat/config");
const { getAccount } = require("./helpers");

task("check-balance", "Checks the balance of your account")
.setAction(async function(taskArguments, hre){
    const account = getAccount();
    console.log(`Account balance for ${account.address}: ${await account.getBalance()}`);
});

task("deploy", "Deploys the OnchainNFT.sol smart contract")
.setAction(async function(taskArguments, hre){
    const account = getAccount();
    const nftContractFactory = await hre.ethers.getContractFactory("OnchainNft", account);
    const nft = await nftContractFactory.deploy("0x22009fE88FD79Ec22E568751069a3A6eBc5250bd");
    //console.log(`Deployed smart contract to address: ${nft.address}`);
});