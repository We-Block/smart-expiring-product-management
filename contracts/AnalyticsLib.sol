// SPDX-License-Identifier: MIT
/**
 * @title Analytics Library
 * @author w33d
 * @notice Library for product analytics functions
 * @dev This library contains functions for analyzing product data
 */
pragma solidity ^0.8.0;

import "./ProductLib.sol";

library AnalyticsLib {
    uint256 constant SECONDS_IN_DAY = 86400;

    /**
    * @dev Calculates the total inventory value.
    * @param products The mapping of all products.
    * @param tokenCounter The total number of products.
    * @return The total value of all products (price * quantity).
    */
    function calculateTotalInventoryValue(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenCounter
    ) internal view returns (uint256) {
        uint256 totalValue = 0;
        
        for (uint256 i = 0; i < tokenCounter; i++) {
            if (block.timestamp < products[i].expiryDate) {
                totalValue += products[i].price * products[i].quantity;
            }
        }
        
        return totalValue;
    }
    
    /**
    * @dev Calculates the average shelf life of products.
    * @param products The mapping of all products.
    * @param tokenCounter The total number of products.
    * @return The average shelf life in days.
    */
    function calculateAverageShelfLife(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenCounter
    ) internal view returns (uint256) {
        require(tokenCounter > 0, "No products available for analysis");
        
        uint256 totalShelfLife = 0;
        
        for (uint256 i = 0; i < tokenCounter; i++) {
            uint256 shelfLife = (products[i].expiryDate - products[i].manufactureDate) / SECONDS_IN_DAY;
            totalShelfLife += shelfLife;
        }
        
        return totalShelfLife / tokenCounter;
    }
    
    /**
    * @dev Calculates inventory turnover rate based on quantity changes.
    * @param products The mapping of all products.
    * @param tokenCounter The total number of products.
    * @param startTime The start time for analysis.
    * @param endTime The end time for analysis.
    * @param initialQuantities The initial quantities of products.
    * @param finalQuantities The final quantities of products.
    * @return The inventory turnover rate.
    */
    function calculateInventoryTurnover(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenCounter,
        uint256 startTime,
        uint256 endTime,
        uint256[] memory initialQuantities,
        uint256[] memory finalQuantities
    ) internal view returns (uint256) {
        require(tokenCounter > 0, "No products available for analysis");
        require(initialQuantities.length == tokenCounter && finalQuantities.length == tokenCounter, "Quantity arrays must match token counter");
        
        uint256 totalInitialValue = 0;
        uint256 quantitySold = 0;
        
        for (uint256 i = 0; i < tokenCounter; i++) {
            totalInitialValue += products[i].price * initialQuantities[i];
            
            if (initialQuantities[i] > finalQuantities[i]) {
                quantitySold += (initialQuantities[i] - finalQuantities[i]);
            }
        }
        
        if (totalInitialValue == 0) return 0;
        
        // Calculate turnover rate as percentage of inventory sold
        return (quantitySold * 100) / totalInitialValue;
    }
}
