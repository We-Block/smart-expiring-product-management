// SPDX-License-Identifier: MIT
/**
 * @title Product Library
 * @author w33d
 * @notice Library for managing product information
 * @dev This library contains a Product struct to represent product info and a function to validate products
 */
pragma solidity ^0.8.0;

/** 
 * @notice The Product struct represents information about a product
 */
library ProductLib {
    // Define product categories
    enum Category { 
        Food, 
        Beverage, 
        Pharmaceutical, 
        Cosmetic, 
        Other 
    }
    
    // Define supply chain locations
    enum Location {
        Manufacturer,
        Distributor,
        Retailer,
        Customer
    }
    
    struct Product {  
        /** The name of the product */
        string name;  
        /** The manufacturer of the product */
        string manufacturer;  
        /** The date the product was manufactured */
        uint256 manufactureDate;  
        /** The expiration date of the product */
        uint256 expiryDate;  
        /** The price of the product */
        uint256 price;
        /** The category of the product */
        Category category;
        /** The current location in the supply chain */
        Location currentLocation;
        /** Quantity in inventory */
        uint256 quantity;
        /** Whether the product meets quality standards */
        bool isQualityProduct;  
    }  

    /**
     * @notice Checks if a Product is valid based on its properties
     * @param product The Product to validate  
     * @return isValid True if the Product is valid, false otherwise
     */
    function isValidProduct(Product memory product) internal pure returns (bool) {
        return bytes(product.name).length > 0 && 
               bytes(product.manufacturer).length > 0 && 
               product.manufactureDate < product.expiryDate &&
               product.quantity > 0;
    }
    
    /**
     * @notice Updates the location of a product in the supply chain
     * @param product The Product to update
     * @param newLocation The new location
     */
    function updateLocation(Product storage product, Location newLocation) internal {
        // Validate location transition
        require(uint8(newLocation) >= uint8(product.currentLocation), "Invalid location transition");
        product.currentLocation = newLocation;
    }
    
    /**
     * @notice Updates the inventory quantity
     * @param product The Product to update
     * @param newQuantity The new quantity
     */
    function updateQuantity(Product storage product, uint256 newQuantity) internal {
        product.quantity = newQuantity;
    }
}
