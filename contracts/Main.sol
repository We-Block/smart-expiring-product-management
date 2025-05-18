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
import "./CategoryLib.sol";
import "./AnalyticsLib.sol";
import "./AccessControlLib.sol";

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
    using CategoryLib for mapping(uint256 => ProductLib.Product);
    using AnalyticsLib for mapping(uint256 => ProductLib.Product);
    using AccessControlLib for AccessControlLib.Roles;

    // State variables
    uint256 public tokenCounter;
    mapping(uint256 => ProductLib.Product) public products;
    DiscountLib.DiscountData public discountData;
    AccessControlLib.Roles private roles;
    
    // For inventory turnover calculation
    uint256 public lastInventoryUpdateTime;
    mapping(uint256 => uint256) public productInitialQuantities;

    // Constants
    string constant EMPTY_MANUFACTURER = "Manufacturer name should not be empty";
    string constant EMPTY_NAME = "Product name should not be empty"; 
    string constant INVALID_DATES = "Manufacture date should be earlier than expiry date";
    string constant NO_PRODUCTS = "No products available for analysis.";
    string constant NO_VALID_PRODUCTS = "No valid products available for analysis.";
    string constant WRONG_PRICE = "Price must be greater than 0";

    // Events
    event ProductCreated(uint256 indexed tokenId, string manufacturer, string name, uint256 manufactureDate, uint256 expiryDate, bool isQualityProduct, uint256 price, ProductLib.Category category, uint256 quantity);
    event ProductManufacturerChanged(uint256 id, string manufacturer);
    event ProductLocationChanged(uint256 id, ProductLib.Location newLocation);
    event ProductQuantityChanged(uint256 id, uint256 newQuantity);
    event RoleAssigned(address account, uint8 roleType);
    event RoleRemoved(address account, uint8 roleType);
    event PriceCategoryUpdated(ProductLib.Category category, int8 adjustmentPercent);

    constructor() ERC721("Factory", "FACTORY") {
        tokenCounter = 0;
        lastInventoryUpdateTime = block.timestamp;
        roles.initialize(msg.sender);
    }

    // Role-based modifiers
    modifier onlyAdmin() {
        require(roles.isAdmin(msg.sender), "Caller is not an admin");
       _;
    }
    
    modifier onlyManufacturer() {
        require(roles.isManufacturer(msg.sender), "Caller is not a manufacturer");
       _;
    }
    
    modifier onlyDistributor() {
        require(roles.isDistributor(msg.sender), "Caller is not a distributor");
       _;
    }
    
    modifier onlyRetailer() {
        require(roles.isRetailer(msg.sender), "Caller is not a retailer");
       _;
    }

    /**
    * @dev Creates a new product with enhanced fields.
    * @param productManufacturer The manufacturer of the product.
    * @param productName The name of the product.
    * @param manufactureDate The date the product was manufactured.
    * @param expiryDate The expiry date of the product.
    * @param category The category of the product.
    * @param quantity The initial quantity of the product.
    * @param isQualityProduct Whether the product is of high quality or not.
    * @param price The price of the product.
    */
    function createProduct(
        string calldata productManufacturer,
        string calldata productName,
        uint256 manufactureDate,
        uint256 expiryDate,
        ProductLib.Category category,
        uint256 quantity,
        bool isQualityProduct,
        uint256 price
    ) public onlyManufacturer {
        require(bytes(productManufacturer).length > 0, "Manufacturer name should not be empty");
        require(bytes(productName).length > 0, "Product name should not be empty");
        require(manufactureDate < expiryDate, "Manufacture date should be earlier than expiry date");
        require(price > 0, "Price must be greater than 0");
        require(quantity > 0, "Quantity must be greater than 0");

        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);

        products.createProduct(
            tokenCounter, 
            productManufacturer, 
            productName, 
            manufactureDate, 
            expiryDate, 
            category,
            quantity,
            isQualityProduct, 
            price
        );
        
        productInitialQuantities[tokenId] = quantity;
        tokenCounter = tokenCounter.add(1);

        emit ProductCreated(
            tokenId, 
            productManufacturer, 
            productName, 
            manufactureDate, 
            expiryDate, 
            isQualityProduct, 
            price,
            category,
            quantity
        );
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
                newProduct.category,
                newProduct.quantity,
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

    /** 
    * @dev Calculates the average price of all products.
    * @return The average price of all products.
    */
    function calculateAveragePrice() public view returns (uint256) {
        return products.calculateAveragePrice(tokenCounter);
    }

    /**
    * @dev Gets all products expiring within a given threshold. 
    * @param expiryThresholdInDays The number of days within which the products should expire.
    * @return An array of IDs of the expiring products. 
    */
    function getExpiringProducts(uint256 expiryThresholdInDays) public view returns (uint256[] memory) {
        return products.getExpiringProducts(tokenCounter, expiryThresholdInDays);
    }

    /**
    * @dev Gets all products by a given manufacturer.
    * @param productManufacturer The name of the manufacturer. 
    * @return An array of IDs of the products by the given manufacturer.
    */
    function getProductsByManufacturer(string memory productManufacturer) public view returns (uint256[] memory) {
        return products.getProductsByManufacturer(tokenCounter, productManufacturer);
    }

    /**
    * @dev Sets a discount percentage to be applied to all product prices. 
    * @param percentage The discount percentage to be applied. 
    */
    function setDiscount(uint256 percentage) public onlyOwner {
        discountData.setDiscount(percentage);
    }

    /** 
    * @dev Cancels any applied discount.
    */
    function cancelDiscount() public onlyOwner {
        discountData.cancelDiscount();
    }

    /**
    * @dev Updates the location of a product in the supply chain.
    * @param productTokenId The ID of the product.
    * @param newLocation The new location of the product.
    */
    function updateProductLocation(uint256 productTokenId, ProductLib.Location newLocation) public {
        require(_exists(productTokenId), "Product does not exist");
        
        // Role-based access check for location updates
        if (newLocation == ProductLib.Location.Manufacturer) {
            require(roles.isManufacturer(msg.sender), "Only manufacturers can set this location");
        } else if (newLocation == ProductLib.Location.Distributor) {
            require(roles.isDistributor(msg.sender), "Only distributors can set this location");
        } else if (newLocation == ProductLib.Location.Retailer) {
            require(roles.isRetailer(msg.sender), "Only retailers can set this location");
        }
        
        products.updateProductLocation(productTokenId, newLocation);
        emit ProductLocationChanged(productTokenId, newLocation);
    }
    
    /**
    * @dev Updates the quantity of a product.
    * @param productTokenId The ID of the product.
    * @param newQuantity The new quantity of the product.
    */
    function updateProductQuantity(uint256 productTokenId, uint256 newQuantity) public onlyAdmin {
        require(_exists(productTokenId), "Product does not exist");
        products.updateProductQuantity(productTokenId, newQuantity);
        emit ProductQuantityChanged(productTokenId, newQuantity);
    }

    /**
    * @dev Gets all products of a specific category.
    * @param category The category to filter by.
    * @return An array of IDs of products in the specified category.
    */
    function getProductsByCategory(ProductLib.Category category) public view returns (uint256[] memory) {
        return products.getProductsByCategory(tokenCounter, category);
    }
    
    /**
    * @dev Updates prices for all products in a specific category.
    * @param category The category to update.
    * @param priceAdjustmentPercent The percentage to adjust the price.
    */
    function updatePricesByCategory(ProductLib.Category category, int8 priceAdjustmentPercent) public onlyAdmin {
        products.updatePricesByCategory(tokenCounter, category, priceAdjustmentPercent);
        emit PriceCategoryUpdated(category, priceAdjustmentPercent);
    }
    
    /**
    * @dev Calculates the total inventory value.
    * @return The total value of all products.
    */
    function calculateTotalInventoryValue() public view returns (uint256) {
        return products.calculateTotalInventoryValue(tokenCounter);
    }
    
    /**
    * @dev Calculates the average shelf life of products.
    * @return The average shelf life in days.
    */
    function calculateAverageShelfLife() public view returns (uint256) {
        return products.calculateAverageShelfLife(tokenCounter);
    }
    
    /**
    * @dev Assigns a role to an account.
    * @param account The account to assign the role to.
    * @param roleType The type of role (1=admin, 2=manufacturer, 3=distributor, 4=retailer).
    */
    function assignRole(address account, uint8 roleType) public onlyAdmin {
        require(roleType >= 1 && roleType <= 4, "Invalid role type");
        
        if (roleType == 1) roles.addAdmin(account);
        else if (roleType == 2) roles.addManufacturer(account);
        else if (roleType == 3) roles.addDistributor(account);
        else if (roleType == 4) roles.addRetailer(account);
        
        emit RoleAssigned(account, roleType);
    }
    
    /**
    * @dev Removes a role from an account.
    * @param account The account to remove the role from.
    * @param roleType The type of role to remove.
    */
    function removeRole(address account, uint8 roleType) public onlyAdmin {
        roles.removeRole(account, roleType);
        emit RoleRemoved(account, roleType);
    }
}

