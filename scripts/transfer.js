const hre = require("hardhat");
const { encryptDataField, decryptNodeResponse } = require("@swisstronik/swisstronik.js");

const sendShieldedTransaction = async (signer, destination, data, value) => {
    // Get the RPC link from the network configuration
    const rpclink = hre.network.config.url;
  
    // Encrypt transaction data
    const [encryptedData] = await encryptDataField(rpclink, data);
  
    // Construct and sign transaction with encrypted data
    return await signer.sendTransaction({
      from: signer.address,
      to: destination,
      data: encryptedData,
      value,
    });
  };

  async function main() {
    // Address of the deployed contract
    const contractAddress = "0x2C9c3817D019c0CDD16132AA842C0ED9C11C9A5a";
    const receiverAddress = "0x16af037878a6cAce2Ea29d39A3757aC2F6F7aac1"

    // Get the signer (your account)
    const [signer] = await hre.ethers.getSigners();
    const amountToTransfer = hre.ethers.parseEther("10")
  
  
    // Construct a contract instance
    const contractFactory = await hre.ethers.getContractFactory("sNGN");
    const contract = contractFactory.attach(contractAddress);
  
    // Send a shielded transaction to mint 10 sNGN token in the contract
    const tx = await sendShieldedTransaction(signer, contractAddress, contract.interface.encodeFunctionData("transfer", [receiverAddress, amountToTransfer]), 0);
    await tx.wait();
  
    //It should return a TransactionResponse object
    console.log(`Transferred ${amountToTransfer.toString()} tokens to ${receiverAddress}`);
  }

  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });