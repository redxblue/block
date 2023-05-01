/**
 * @type import('hardhat/config').HardhatUserConfig
 * @type import task from 'hardhat/config'
 */
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
const { API_URL, PRIVATE_KEY } = process.env;
module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "localhost",
  networks: {
    hardhat: {},
    localhost: {
      chainId: 31337,
    },
    // ropsten: {
    //   url: API_URL,
    //   accounts: [`0x${PRIVATE_KEY}`],
    // },
  },
};
/////////////////////Custom tasks///////////////////
task('mint','This mints an nft in the deployed contract ')
.addParam("tokenuri",)
.addParam("securitydeposit",)
.addParam("rentamount",)
.setAction(async({tokenuri,securitydeposit,rentamount})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const signer =await ethers.getSigners();
  console.log(signer[0])
  const newNft=await propertynft.connect(signer[0]).mint("0x70997970C51812dc3A010C7d01b50e0d17dc79C8",tokenuri,securitydeposit,rentamount)
  console.log(newNft)
    
})
task('getTokenUri','Get token owner')
.addParam("tokenid")
.setAction(async({tokenid})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const tokenUri=await propertynft.tokenURI(tokenid)
  const owner=await propertynft.ownerOf(tokenid)
  console.log(tokenUri)
  console.log(`Owner of token ${tokenid} with token URI "${tokenUri}" is ${owner}`)
  
})
task('getBalance','Get the contract balance') //accepts no parameter
.setAction(async()=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const balance=await propertynft.getBalance()
  console.log(balance)
})
task('tenentOf','know who rents a property') 
.addParam("tokenid")
.setAction(async({tokenid})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const tenent=await propertynft.tenentOf(tokenid)
  console.log(`tenent of token ID ${tokenid} is ${tenent}`)
})
task('rent','Enter rent agreement') //accepts no parameter
.addParam("tokenid")
.setAction(async({tokenid})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const signer =await ethers.getSigners();
  const rent=await propertynft.connect(signer[0]).rent(tokenid,{value: ethers.utils.parseEther("5")})
  console.log(rent)
  console.log(`tenent of token ID ${tokenid} is ${rent}`)
})
task('payRent','Pay rent') //accepts no parameter
.addParam("tokenid")
.setAction(async({tokenid})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const signer =await ethers.getSigners();
  const paidRent=await propertynft.connect(signer[0]).payRent(tokenid,{value: ethers.utils.parseEther("2")})
  console.log(paidRent)
  console.log(`tenent has paid rent of token ID ${tokenid} with ${paidRent}`)
})
task('endRent','Close contract agreement') //accepts no parameter
.addParam("tokenid")
.addParam("owner")
.setAction(async({tokenid,owner})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const signer =await ethers.getSigners();
  console.log(signer[0].address)
  for(i=0;i<20;++i){
    if(signer[i].address==owner){
      owner=signer[i];            //getting signer object for the owner account as owner variable only had an address in it previously
    }
  }
  const endedRent=await propertynft.connect(owner).endRent(tokenid)
  console.log(endedRent)
  //console.log(`tenent has paid rent of token ID ${tokenid} with ${paidRent}`)
})