const {ethers}=require('hardhat')
const b=async()=>{
    
    const PropertyNft = await ethers.getContractFactory("PropertyNft")
    const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
    const tokenId=1;
    const tokenUri=await propertynft.tokenURI(tokenId)
    const owner=await propertynft.ownerOf(tokenId)
   // console.log(tokenUri)
    console.log(`Owner of token ${tokenId} with token URI "${tokenUri}" is ${owner}`)
    //const signer =await ethers.getSigners();
    //  console.log(signer[0])
    // const newNft=await propertynft.connect(signer[0]).mint("0x70997970C51812dc3A010C7d01b50e0d17dc79C8","third random token uri")
    // console.log(newNft)
}
b();