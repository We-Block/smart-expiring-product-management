// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ProductLib.sol";
import "./PriceLib.sol";
import "./QueryLib.sol";
import "./ProductOperationsLib.sol";
import "./DiscountLib.sol";


contract Factory is ERC721, Ownable {
    using SafeMath for uint256;
    using ProductLib for ProductLib.Product;
    using PriceLib for ProductLib.Product;
    using QueryLib for mapping(uint256 => ProductLib.Product);
    using ProductOperationsLib for mapping(uint256 => ProductLib.Product);
    using DiscountLib for DiscountLib.DiscountData;

    uint256 public tokenCounter;
    mapping(uint256 => ProductLib.Product) public products;
    DiscountLib.DiscountData public discountData;

    // Constants
    string constant EMPTY_MANUFACTURER = "Manufacturer name should not be empty";
    string constant EMPTY_NAME = "Product name should not be empty"; 
    string constant INVALID_DATES = "Manufacture date should be earlier than expiry date";
    string constant NO_PRODUCTS = "No products available for analysis.";
    string constant NO_VALID_PRODUCTS = "No valid products available for analysis.";

    constructor() ERC721("Factory", "FACTORY") {
        tokenCounter = 0;
    }

    event ProductCreated(uint256 indexed tokenId, string manufacturer, string name, uint256 manufactureDate, uint256 expiryDate, bool isQualityProduct, uint256 price);

    function createProduct(
        string calldata productManufacturer,
        string calldata productName,
        uint256 manufactureDate,
        uint256 expiryDate,
        bool isQualityProduct,
        uint256 price
    ) public onlyOwner {
        require(bytes(productManufacturer).length > 0, EMPTY_MANUFACTURER);
        require(bytes(productName).length > 0, EMPTY_NAME);
        require(manufactureDate < expiryDate, INVALID_DATES);

        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);

        products.createProduct(tokenCounter, productManufacturer, productName, manufactureDate, expiryDate, isQualityProduct, price);
        tokenCounter = tokenCounter.add(1);

        emit ProductCreated(tokenId, productManufacturer, productName, manufactureDate, expiryDate, isQualityProduct, price);
    }

    function createProductsBatch(ProductLib.Product[] calldata _products) public onlyOwner {
        uint256 productsLength = _products.length;
        for (uint256 i = 0; i < productsLength; i++) {
            ProductLib.Product calldata newProduct = _products[i];
            createProduct(
                newProduct.manufacturer,
                newProduct.name,
                newProduct.manufactureDate,
                newProduct.expiryDate,
                newProduct.isQualityProduct,
                newProduct.price
            );
        }
    }

    function updatePrice(uint256 productTokenId) public onlyOwner {
        require(_exists(productTokenId), "Product does not exist.");
        uint256 originalPrice = products[productTokenId].updatePrice();
        uint256 discountedPrice = discountData.calculateDiscountedPrice(originalPrice);
        products[productTokenId].price = discountedPrice;
    }

    function updatePricesBatch(uint256[] memory productTokenIds) public onlyOwner {
        uint256 productTokenIdsLength = productTokenIds.length;
        for (uint256 i = 0; i < productTokenIdsLength; i++) {
            uint256 productTokenId = productTokenIds[i];
            require(_exists(productTokenId), "Product does not exist.");
            uint256 originalPrice = products[productTokenId].updatePrice();
            uint256 discountedPrice = discountData.calculateDiscountedPrice(originalPrice);
            products[productTokenId].price = discountedPrice;
        }
    }

    function calculateAveragePrice() public view returns (uint256) {
        return products.calculateAveragePrice(tokenCounter);
    }

    function getExpiringProducts(uint256 expiryThresholdInDays) public view returns (uint256[] memory) {
        return products.getExpiringProducts(tokenCounter, expiryThresholdInDays);
    }

    function getProductsByManufacturer(string memory productManufacturer) public view returns (uint256[] memory) {
        return products.getProductsByManufacturer(tokenCounter, productManufacturer);
    }

    function setDiscount(uint256 percentage) public onlyOwner {
        discountData.setDiscount(percentage);
    }

    function cancelDiscount() public onlyOwner {
        discountData.cancelDiscount();
    }
}

