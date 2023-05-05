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
    struct Product {  
   /** The name of the product */
   string name;  
   /** The manufacturer of the product*/
   string manufacturer;  
   /** The date the product was manufactured*/
   uint256 manufactureDate;  
   /** The expiration date of the product */
   uint256 expiryDate;  
   /** Whether the product meets quality standards */
   bool isQualityProduct;  
   /** The price of the product */
   uint256 price;
}  

/**
 * @notice Checks if a Product is valid based on its properties
 * @param product The Product to validate  
 * @return isValid True if the Product is valid, false otherwise
 */
    function isValidProduct(Product memory product) internal pure returns (bool) {
        return bytes(product.name).length > 0 && bytes(product.manufacturer).length > 0 && product.manufactureDate < product.expiryDate;
    }
}
