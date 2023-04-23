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
    ropsten: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
};
/////////////////////Custom tasks///////////////////
task('mint','This mints an nft in the deployed contract ')
.addOptionalParam("tokenuri","The greeting to print", "Hello, World!")
.setAction(async({tokenuri})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const signer =await ethers.getSigners();
  console.log(signer[0])
  const newNft=await propertynft.connect(signer[0]).mint("0x70997970C51812dc3A010C7d01b50e0d17dc79C8",tokenuri)
  console.log(newNft)
    
})
task('getTokenUri','Get token owner')
.addOptionalParam("tokenid")
.setAction(async({tokenid})=>{
  const PropertyNft = await ethers.getContractFactory("PropertyNft")
  const propertynft = await PropertyNft.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
  const tokenUri=await propertynft.tokenURI(tokenid)
  const owner=await propertynft.ownerOf(tokenid)
  console.log(tokenUri)
  console.log(`Owner of token ${tokenid} with token URI "${tokenUri}" is ${owner}`)
  
})