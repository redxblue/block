async function main() {
    const Nft = await ethers.getContractFactory("PropertyNft");
  
    // Start deployment, returning a promise that resolves to a contract object
    const nft = await Nft.deploy();
    console.log("Contract deployed to address:", nft.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
    //contract adddress on localhost 0x5fbdb2315678afecb367f032d93f642f64180aa3