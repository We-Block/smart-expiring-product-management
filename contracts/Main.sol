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

/**
 * @title Factory
 * @dev This contract creates ERC721 tokens representing products. It stores product details and allows the owner to create new products.
 */
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
    string constant WRONG_PRICE = "Price must be greater than 0";

    constructor() ERC721("Factory", "FACTORY") {
        tokenCounter = 0;
    }

    event ProductCreated(uint256 indexed tokenId, string manufacturer, string name, uint256 manufactureDate, uint256 expiryDate, bool isQualityProduct, uint256 price);

    /**
    * @dev Creates a new product.
    * @param productManufacturer The manufacturer of the product. Must not be empty.
    * @param productName The name of the product. Must not be empty. 
    * @param manufactureDate The date the product was manufactured. Must be before the expiryDate.
    * @param expiryDate The expiry date of the product. Must be after the manufactureDate.
    * @param isQualityProduct Whether the product is of high quality or not.
    * @param price The price of the product.
    */
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
        require(price > 0, WRONG_PRICE);

        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);

        products.createProduct(tokenCounter, productManufacturer, productName, manufactureDate, expiryDate, isQualityProduct, price);
        tokenCounter = tokenCounter.add(1);

        emit ProductCreated(tokenId, productManufacturer, productName, manufactureDate, expiryDate, isQualityProduct, price);
    }

    /**
    * @dev Creates multiple new products in a batch.
    * @param _products An array of Product structs containing the details of the products to create.
    */
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

    /**
    * @dev Updates the price of a product. Calculates the discounted price based on the discount percentage 
    * set and updates the product's price.
    * @param productTokenId The ID of the product whose price is to be updated.
    */
    function updatePrice(uint256 productTokenId) public onlyOwner {
        require(_exists(productTokenId), "Product does not exist.");
        uint256 originalPrice = products[productTokenId].updatePrice();
        uint256 discountedPrice = discountData.calculateDiscountedPrice(originalPrice);
        products[productTokenId].price = discountedPrice;
    }

    /**
     * @dev Updates the prices of multiple products in a batch. Calculates the discounted price for each product 
     * based on the discount percentage set and updates the product's price.
    * @param productTokenIds An array of IDs of the products whose prices are to be updated.
    */
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

