// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Factory2 is ERC721, Ownable {
    uint256 public tokenCounter;

    struct Product {
        string name;
        string manufacturer;
        uint256 manufactureDate;
        uint256 expiryDate;
        bool isQualityProduct;
        uint256 price;
    }

    mapping(uint256 => Product) public products;  // key: product id, value: product

    constructor() ERC721("Factory", "FACTORY") {
        tokenCounter = 0;
    }

    function createProduct(
        string memory _manufacturer,
        string memory _name,
        uint256 _manufactureDate,
        uint256 _expiryDate,
        bool _isQualityProduct
    ) public onlyOwner {
        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);
        uint256 price = calculatePrice(_expiryDate);
        products[tokenId] = Product(
            _manufacturer,
            _name,
            _manufactureDate,
            _expiryDate,
            _isQualityProduct,
            price
        );
        tokenCounter++;
    }
    
    function calculatePrice(uint256 _expiryDate) internal view returns (uint256) {
        uint256 remainingDays = (_expiryDate - block.timestamp) / 86400;
        uint256 price;

        if (remainingDays > 30) {
            price = 1000;
        } else if (remainingDays > 7) {
            price = 800;
        } else {
            price = 500;
        }

        return price;
    }

    function updatePrice(uint256 _tokenId) public onlyOwner {
        require(_exists(_tokenId), "Token ID does not exist.");
        uint256 newPrice = calculatePrice(products[_tokenId].expiryDate);
        products[_tokenId].price = newPrice;
    }


    function isProductExpired(uint256 _tokenId) public view returns (bool) {
        require(_exists(_tokenId), "Token ID does not exist.");
        uint256 expiryDate = products[_tokenId].expiryDate;
        return block.timestamp >= expiryDate;
    }

    function calculateAveragePrice() public view returns (uint256) {
        
        require(tokenCounter > 0, "No products available for analysis.");

        uint256 totalPrice = 0;
        uint256 validProductCount = 0;

        for (uint256 i = 0; i < tokenCounter; i++) {
           if (!isProductExpired(i)) {
                totalPrice += products[i].price;
                validProductCount++;
            }
    }

        require(validProductCount > 0, "No valid products available for analysis.");
        return totalPrice / validProductCount;
    }


    function getExpiringProducts(uint256 _daysThreshold) public view returns (uint256[] memory) {
        uint256[] memory expiringProductIds = new uint256[](tokenCounter);
        uint256 expiringProductCount = 0;

        for (uint256 i = 0; i < tokenCounter; i++) {
            uint256 remainingDays = (products[i].expiryDate - block.timestamp) / 86400;
            if (remainingDays <= _daysThreshold && !isProductExpired(i)) {
                expiringProductIds[expiringProductCount] = i;
                expiringProductCount++;
            }
        }

        uint256[] memory result = new uint256[](expiringProductCount);
        for (uint256 i = 0; i < expiringProductCount; i++) {
            result[i] = expiringProductIds[i];
        }
        return result;
    }
    function getProductsByManufacturer(string memory _manufacturer) public view returns (uint256[] memory) {
        uint256[] memory productsByManufacturer = new uint256[](tokenCounter);
        uint256 productCount = 0;

        for (uint256 i = 0; i < tokenCounter; i++) {
            if (keccak256(abi.encodePacked(products[i].manufacturer)) == keccak256(abi.encodePacked(_manufacturer))) {
                productsByManufacturer[productCount] = i;
                productCount++;
            }
        }

        uint256[] memory result = new uint256[](productCount);
        for (uint256 i = 0; i < productCount; i++) {
            result[i] = productsByManufacturer[i];
        }
        return result;
    }

}
