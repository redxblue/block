// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyNft is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    // modifier onlyPropertyOwner(_tokenId){
    //     require(msg.sender== ownerOf(_tokenId),"function only callable by owner of this property");
    //     _;
    // }
    struct property{
        uint256 securityDeposit; //is the value getting stored as gwei here??
        uint256 rentAmount; //testing rquired👆
        uint256 latestTransactionTime;
        }
    struct ownerInfo{
        uint256[] ownedProperties;
    }
    struct tenentInfo{
        uint256[] rentedProperties;
    }
    mapping(address=>ownerInfo) propertiesOwnedBy;
    mapping(address=>tenentInfo) propertiesRentedBy;
    mapping(uint256=>address)public tenentOf;
   // property public propInfo;
    mapping(uint256=>property) public propertyInfo; 
    Counters.Counter private _tokenIdCounter;
    constructor() ERC721("PropertyNft", "PNT") {
        // Start token ID at 1. By default is starts at 0.
        // _tokenIdCounter.increment();
    }
    function mint(address _to, string calldata _uri,uint256 _securityDeposit,  //in wei
    uint256 _rentAmount) external returns (uint256)  {
            uint256 _tokenId=_tokenIdCounter.current();
            _tokenIdCounter.increment();
            propertyInfo[_tokenId].securityDeposit=_securityDeposit;
            propertyInfo[_tokenId].rentAmount=_rentAmount;  
            _mint(_to, _tokenId);
            _setTokenURI(_tokenId, _uri);
            propertiesOwnedBy[_to].ownedProperties.push(_tokenId);
            return _tokenId; 
    }
    function rent(uint256 _tokenId) external payable {
        require(tenentOf[_tokenId]==address(0),"Property has already been rented");
        address payable propertyOwner = payable(ownerOf(_tokenId)); //property owner can rent his own property->"a way to remove the property from listing"
		uint256 amount = msg.value; // get the amount of ether in the contract
        uint256 requiredAmount=propertyInfo[_tokenId].securityDeposit + propertyInfo[_tokenId].rentAmount; //gwei is converted to wei here i guess
		require(amount >= requiredAmount, 'Sent an amount equal to the Security deposit and Rent');
        //address payable propertyOwner= payable (ownerOf(_tokenId));
        (bool success, ) = address(this).call{value: (amount- propertyInfo[_tokenId].rentAmount)}(''); //ig the address returned by ownerOf is already payable
		require(success, 'Transaction failed');
		(bool success1, ) = propertyOwner.call{value: (amount- propertyInfo[_tokenId].securityDeposit)}(''); //sending rent amount to property owner
		require(success1, 'Transaction failed1');
        tenentOf[_tokenId]=msg.sender;
        propertiesRentedBy[msg.sender].rentedProperties.push(_tokenId);
        propertyInfo[_tokenId].latestTransactionTime=block.timestamp; //update transaction time to restrict next payment for the next 30 days
		//emit RentEvent(amount);
	}
    function getPropertiesOwnedBy(address _owner)public view returns(uint256[] memory){
        return propertiesOwnedBy[_owner].ownedProperties;
    }
    function getPropertiesRentedBy(address _tenent)public view returns(uint256[] memory){
        return propertiesRentedBy[_tenent].rentedProperties;
    }
    function payRent(uint256 _tokenId)external payable{
        uint256 latestTransactionTime=propertyInfo[_tokenId].latestTransactionTime;
        require(block.timestamp>=latestTransactionTime+60/*1 minute for demo purpose*/,"Payment Date not due yet");
        require(msg.sender==tenentOf[_tokenId],"");
        uint256 amount = msg.value;
        require(amount >=propertyInfo[_tokenId].rentAmount,"Not enough money sent");
        (bool success, ) = ownerOf(_tokenId).call{value: amount}('');
        require(success, 'Transaction failed');
        propertyInfo[_tokenId].latestTransactionTime=block.timestamp; //updates transaction time
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    function totalSupply()public view returns(uint256){
            return _tokenIdCounter.current();
    }
    function endRent(uint256 _tokenId)external{
        require(msg.sender== ownerOf(_tokenId),"function only callable by owner of this property");
        address tenentaddr=tenentOf[_tokenId];
        payable (tenentaddr).transfer(propertyInfo[_tokenId].securityDeposit);
        tenentOf[_tokenId]=address(0);
        propertyInfo[_tokenId].latestTransactionTime=0; //resetting latest transaction time
       uint256 arrayLength= propertiesRentedBy[tenentaddr].rentedProperties.length;//lower gas fees
        for(uint i=0;i<arrayLength;i++){
            if(arrayLength==1){
                propertiesRentedBy[tenentaddr].rentedProperties.pop();
            }
            else if(propertiesRentedBy[tenentaddr].rentedProperties[i]==_tokenId){
                for(uint j=i;j<(arrayLength-1);j++){
                    propertiesRentedBy[tenentaddr].rentedProperties[j]=propertiesRentedBy[tenentaddr].rentedProperties[j+1]; //updating order of tokenid array
                }
                propertiesRentedBy[tenentaddr].rentedProperties.pop();
                arrayLength--; //lower gas fees
            }
        }          
        ////needs to delete from the PropertiesRentedBy array else multiple rows will appear
    }
    receive() external payable {} // Function to receive Ether. msg.data must be empty
    fallback() external payable {}// Fallback function is called when msg.data is not empty
}
