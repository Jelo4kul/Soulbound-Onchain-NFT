const ethers = require("ethers");
const { getContractAt } = require("@nomiclabs/hardhat-ethers/internal/helpers");

//Helper method for fetching environment variable from .env
function getEnvVariable(Key, defaultvalue){
    if(process.env[Key]){
        return process.env[Key];
    }
    if(!defaultvalue){
        throw `${Key} is not defined and no default value was passed`;
    }
    return defaultvalue;
}

//Helper method for fetching a connection provider to the Ethereum Network
function getProvider(){
    return ethers.getDefaultProvider(getEnvVariable("NETWORK", "rinkeby"), {
        alchemy:getEnvVariable("ALCHEMY_KEY")
    });
}

//Helper method for fetching a wallet account using an environment variable for the PK
function getAccount(){
    return new ethers.Wallet(getEnvVariable("PRIVATE_KEY"), getProvider());
}


//Helper method for fetching a contract instance at a given address
function getContract(contractName, hre){
    const account = getAccount();
    return getContractAt(hre, contractName, getEnvVariable("NFT_CONTRACT_ADDRESS"), account);
}

module.exports = {
    getEnvVariable,
    getProvider,
    getAccount,
    getContract
}