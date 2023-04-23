// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyNft is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    constructor() ERC721("PropertyNft", "PNT") {
        // Start token ID at 1. By default is starts at 0.
        // _tokenIdCounter.increment();
    }
    function mint(address _to, string calldata _uri) external returns (uint256)  {
            uint256 _tokenId=_tokenIdCounter.current();
            _tokenIdCounter.increment();
            _mint(_to, _tokenId);
            _setTokenURI(_tokenId, _uri);
            return _tokenId; 
    }
    function totalSupply()public view returns(uint256){
            return _tokenIdCounter.current();
    }

}