// SPDX-License-Identifier: MIT
/**
 * @title Category Library
 * @author w33d
 * @notice Library for managing product categories and category-based operations
 * @dev This library contains functions to group and manage products by category
 */
pragma solidity ^0.8.0;

import "./ProductLib.sol";

library CategoryLib {
    /**
    * @dev Gets all products of a specific category.
    * @param products The mapping of all products.
    * @param tokenCounter The total number of products.
    * @param category The category to filter by.
    * @return An array of IDs of products in the specified category.
    */
    function getProductsByCategory(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenCounter,
        ProductLib.Category category
    ) internal view returns (uint256[] memory) {
        // First pass: count matching products
        uint256 matchingCount = 0;
        for (uint256 i = 0; i < tokenCounter; i++) {
            if (products[i].category == category) {
                matchingCount++;
            }
        }
        
        // Create array with exact size needed
        uint256[] memory result = new uint256[](matchingCount);
        
        // Second pass: fill the array
        if (matchingCount > 0) {
            uint256 index = 0;
            for (uint256 i = 0; i < tokenCounter; i++) {
                if (products[i].category == category) {
                    result[index] = i;
                    index++;
                }
            }
        }
        return result;
    }
    
    /**
    * @dev Updates prices for all products in a specific category.
    * @param products The mapping of all products.
    * @param tokenCounter The total number of products.
    * @param category The category to update.
    * @param priceAdjustmentPercent The percentage to adjust the price (can be positive or negative).
    */
    function updatePricesByCategory(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenCounter,
        ProductLib.Category category,
        int8 priceAdjustmentPercent
    ) internal {
        require(priceAdjustmentPercent > -100, "Cannot decrease price by 100% or more");
        
        for (uint256 i = 0; i < tokenCounter; i++) {
            if (products[i].category == category) {
                uint256 currentPrice = products[i].price;
                if (priceAdjustmentPercent >= 0) {
                    // Price increase
                    products[i].price = currentPrice + (currentPrice * uint8(priceAdjustmentPercent) / 100);
                } else {
                    // Price decrease
                    products[i].price = currentPrice - (currentPrice * uint8(-priceAdjustmentPercent) / 100);
                }
            }
        }
    }
}
