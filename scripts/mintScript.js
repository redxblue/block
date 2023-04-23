const {ethers}=require('hardhat')
const b=async()=>{
    //console.log(process.argv[2]);
    const signer =await ethers.getSigners();
    console.log(signer[0])
    const newNft=await propertynft.connect(signer[0]).mint("0x70997970C51812dc3A010C7d01b50e0d17dc79C8","third")
    console.log(newNft)

}
