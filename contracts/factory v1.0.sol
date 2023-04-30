// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Factory is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    struct Product {
        string manufacturer;
        uint256 productionDate;
        bool isQualified;
    }

    mapping(uint256 => Product) public products;

    constructor() ERC721("Factory", "FACT") {}

    function mintProduct(
        address to,
        string memory manufacturer,
        uint256 productionDate,
        bool isQualified
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;

        _mint(to, tokenId);
        products[tokenId] = Product(manufacturer, productionDate, isQualified);

        _tokenIdCounter++;
    }

    function getProductInfo(uint256 tokenId)
        public
        view
        returns (
            string memory,
            uint256,
            bool
        )
    {
        require(_exists(tokenId), "Token does not exist.");
        Product storage product = products[tokenId];
        return (product.manufacturer, product.productionDate, product.isQualified);
    }
}
