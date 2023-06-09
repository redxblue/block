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
        }
    mapping(uint256=>address)public tenentOf;
   // property public propInfo;
    mapping(uint256=>property) public propertyInfo; 
    Counters.Counter private _tokenIdCounter;
    constructor() ERC721("PropertyNft", "PNT") {
        // Start token ID at 1. By default is starts at 0.
        // _tokenIdCounter.increment();
    }
    function mint(address _to, string calldata _uri,uint256 _securityDeposit,
    uint256 _rentAmount) external returns (uint256)  {
            uint256 _tokenId=_tokenIdCounter.current();
            _tokenIdCounter.increment();
            propertyInfo[_tokenId].securityDeposit=_securityDeposit*10**18;
            propertyInfo[_tokenId].rentAmount=_rentAmount*10**18; //representing as eth in wei 1eth= 10^18 wei 
            _mint(_to, _tokenId);
            _setTokenURI(_tokenId, _uri);
            return _tokenId; 
    }
    function rent(uint256 _tokenId) external payable {
        address payable propertyOwner = payable(ownerOf(_tokenId));
		uint256 amount = msg.value; // get the amount of ether in the contract
        uint256 requiredAmount=propertyInfo[_tokenId].securityDeposit + propertyInfo[_tokenId].rentAmount; //gwei is converted to wei here i guess
		require(amount >= requiredAmount, 'Sent an amount equal to the Security deposit and Rent');
        //address payable propertyOwner= payable (ownerOf(_tokenId));
        (bool success, ) = address(this).call{value: (amount- propertyInfo[_tokenId].rentAmount)}(''); //ig the address returned by ownerOf is already payable
		require(success, 'Transaction failed');
		(bool success1, ) = propertyOwner.call{value: (amount- propertyInfo[_tokenId].securityDeposit)}(''); //sending rent amount to property owner
		require(success1, 'Transaction failed1');
        tenentOf[_tokenId]=msg.sender;
		//emit RentEvent(amount);
	}
    function payRent(uint256 _tokenId)external payable{
        require(msg.sender==tenentOf[_tokenId],"");
        uint256 amount = msg.value;
        require(amount >=propertyInfo[_tokenId].rentAmount,"Not enough money sent");
        (bool success, ) = ownerOf(_tokenId).call{value: amount}('');
        require(success, 'Transaction failed');
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    function totalSupply()public view returns(uint256){
            return _tokenIdCounter.current();
    }
    function endRent(uint256 _tokenId)external{
        require(msg.sender== ownerOf(_tokenId),"function only callable by owner of this property");
        payable(tenentOf[_tokenId]).transfer(propertyInfo[_tokenId].securityDeposit);
        tenentOf[_tokenId]=address(0);
    }
    receive() external payable {} // Function to receive Ether. msg.data must be empty
    fallback() external payable {}// Fallback function is called when msg.data is not empty
}