// SPDX-License-Identifier: MIT
/**
 * @title Price Library
 * @author w33d
 * @notice Library for calculating price
 * @dev This library contains fucntions used to calculate price and update price
 */
pragma solidity ^0.8.0;

import "./ProductLib.sol";

library PriceLib {
    /**
     * @dev Constants for product price tiers based on days to expiry
     */
    uint256 constant THIRTY_DAYS = 30;
    uint256 constant SEVEN_DAYS = 7;
    uint256 constant PRICE_30_DAYS = 1000;
    uint256 constant PRICE_7_DAYS = 800;
    uint256 constant PRICE_LESS_7_DAYS = 500;
    uint256 constant SECONDS_IN_DAY = 86400;

    /**
     * @dev Calculates price based on number of days until product expiry.
     * @param productExpiryDate Expiry date of the product
     * @return The calculated price
     */
    function calculatePrice(uint256 productExpiryDate) internal view returns (uint256) {
        require(productExpiryDate > block.timestamp, "Expiry date must be in the future");

        uint256 remainingDays = (productExpiryDate - block.timestamp) / SECONDS_IN_DAY;

        if (remainingDays > THIRTY_DAYS) {
            return PRICE_30_DAYS;
        } else if (remainingDays > SEVEN_DAYS) {
            return PRICE_7_DAYS;
        } else {
            return PRICE_LESS_7_DAYS;
        }
    }

    /**
    * @dev Updates the price of a product by calculating the new price based on expiry date
    * @param product The Product struct to update
    * @return The newly calculated price
    */
    function updatePrice(ProductLib.Product storage product) internal returns (uint256) {
        product.price = calculatePrice(product.expiryDate);
        return product.price;
    }
}
