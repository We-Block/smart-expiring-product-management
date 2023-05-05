// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract FactoryTest2 is ERC721, Ownable {
    using SafeMath for uint256;
    uint256 public tokenCounter;
    
    string constant EMPTY_MANUFACTURER = "Manufacturer name should not be empty";
    string constant EMPTY_NAME = "Product name should not be empty"; 
    string constant INVALID_DATES = "Manufacture date should be earlier than expiry date";
    string constant NO_PRODUCTS = "No products available for analysis.";
    string constant NO_VALID_PRODUCTS = "No valid products available for analysis.";
    uint256 constant THIRTY_DAYS = 30;
    uint256 constant SEVEN_DAYS = 7;
    uint256 constant PRICE_30_DAYS = 1000;
    uint256 constant PRICE_7_DAYS = 800;
    uint256 constant PRICE_LESS_7_DAYS = 500;
    uint256 constant SECONDS_IN_DAY = 86400;


    struct Product {
        string name;
        string manufacturer;
        uint256 manufactureDate;
        uint256 expiryDate;
        bool isQualityProduct;
        uint256 price;
    }

    mapping(uint256 => Product) public products;

    constructor() ERC721("Factory", "FACTORY") {
        tokenCounter = 0;
    }

    event ProductCreated(uint256 indexed tokenId, string manufacturer, string name, uint256 manufactureDate, uint256 expiryDate, bool isQualityProduct, uint256 price);

    
    /**
    * @dev Creates a new product
    * @param productManufacturer The manufacturer of the product
    * @param productName The name of the product
    * @param manufactureDate The manufacture date of the product
    * @param expiryDate The expiry date of the product
    * @param isQualityProduct Whether the product is of high quality
    * @param price The price of the product
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

        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);   
        
        products[tokenId] = Product(
            string(productManufacturer),
            string(productName),
            manufactureDate,
            expiryDate,
            isQualityProduct,
            price
        );
        tokenCounter = tokenCounter.add(1);

        emit ProductCreated(tokenId, productManufacturer, productName, manufactureDate, expiryDate, isQualityProduct, price);
    }


    
    /**
    * @dev Creates multiple products 
    * @param _products An array of Product structs containing details of products to create
    */
    function createProductsBatch(Product[] calldata _products) public onlyOwner {
        uint256 productsLength = _products.length;
        for (uint256 i = 0; i < productsLength; i++) {
            Product calldata newProduct = _products[i];
            createProduct(
                newProduct.name,
                newProduct.manufacturer,
                newProduct.manufactureDate,
                newProduct.expiryDate,
                newProduct.isQualityProduct,
                newProduct.price
            );
        }
    }



    /**
    * @dev Calculates the price of a product based on its expiry date
    * @param productExpiryDate The expiry date of the product
    * @return The calculated price of the product
    */
    function calculatePrice(uint256 productExpiryDate) internal view returns (uint256) {
    
        require(productExpiryDate > block.timestamp, "Expiry date must be in the future");  

        uint256 remainingDays = (productExpiryDate - block.timestamp) / 86400;

        return remainingDays > THIRTY_DAYS ? PRICE_30_DAYS : (remainingDays > SEVEN_DAYS ? PRICE_7_DAYS : PRICE_LESS_7_DAYS); 
    }

    

    /**
    * @dev Updates the price of a product
    * @param productTokenId The ID of the product to update
    */ 
    function updatePrice(uint256 productTokenId) public onlyOwner { 
        require(_exists(productTokenId), "Product does not exist."); 
        products[productTokenId].price = calculatePrice(products[productTokenId].expiryDate);
        

    }



    /**
    * @dev Updates the prices of multiple products
    * @param productTokenIds The IDs of the products to update 
    */
    function updatePricesBatch(uint256[] memory productTokenIds) public onlyOwner {
        uint256 productTokenIdsLength = productTokenIds.length;
        for (uint256 i = 0; i < productTokenIdsLength; i++) {
            uint256 productTokenId = productTokenIds[i];
            require(_exists(productTokenId), "Product does not exist.");
            products[productTokenId].price = calculatePrice(products[productTokenId].expiryDate);
        }
    
    }



    /**
    * @dev Calculates the average price of all non-expired products
    * @return The average price 
    */
    function calculateAveragePrice() public view returns (uint256) {
    
        require(tokenCounter > 0, NO_PRODUCTS);

        uint256 totalPrice = 0;
        uint256 nonExpiredProductCount = 0; 
        uint256 productCount = tokenCounter;

        for (uint256 i = 0; i < productCount; i++) {
            // Check if the product is not expired
            if (block.timestamp < products[i].expiryDate) {
                totalPrice += products[i].price;
                nonExpiredProductCount++;
            }
        }   

        require(nonExpiredProductCount > 0, NO_VALID_PRODUCTS);
        return totalPrice / nonExpiredProductCount; 
    }




    /**
    * @dev Gets the IDs of products expiring within a given threshold
    * @param expiryThresholdInDays The threshold in days 
    * @return The IDs of expiring products
    */
    function getExpiringProducts(uint256 expiryThresholdInDays) public view returns (uint256[] memory) {
    
        require(expiryThresholdInDays > 0, "Threshold must be positive");
    
        uint256[] memory expiringProductIds = new uint256[](tokenCounter);
        uint256 nonExpiredProductCount = 0; 
        uint256 productCount = tokenCounter;

        for (uint256 i = 0; i < productCount; i++) {
            uint256 daysUntilExpiry = (products[i].expiryDate - block.timestamp) / SECONDS_IN_DAY;
            // Check if the remaining days are within the threshold and the product is not expired
            if (daysUntilExpiry <= expiryThresholdInDays && block.timestamp < products[i].expiryDate) {
                expiringProductIds[nonExpiredProductCount] = i;
                nonExpiredProductCount++;
            }
        }

        uint256[] memory result = new uint256[](nonExpiredProductCount);
        for (uint256 i = 0; i < nonExpiredProductCount; i++) {
            result[i] = expiringProductIds[i];
        }
        return result;
    }


    /**
    * @dev Gets the IDs of products by a given manufacturer 
    * @param productManufacturer The name of the manufacturer
    * @return The IDs of products by the given manufacturer
    */ 
    function getProductsByManufacturer(string memory productManufacturer) public view returns (uint256[] memory) {
        uint256 TOTAL_PRODUCT_COUNT = tokenCounter;
    
        require(bytes(productManufacturer).length > 0, "Manufacturer name cannot be empty");
    
        uint256[] memory productsByManufacturer = new uint256[](TOTAL_PRODUCT_COUNT);
        uint256 productCount = 0;  

        bytes32 manufacturerHash = keccak256(abi.encodePacked(productManufacturer));

        for (uint256 i = 0; i < TOTAL_PRODUCT_COUNT; i++) {
            if (keccak256(abi.encodePacked(products[i].manufacturer)) == manufacturerHash) {
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
