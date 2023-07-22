// SPDX-License-Identifier: MIT
/**
 * @title Discount Library
 * @author w33d
 * @notice Library for update status of discount
 * @dev This library contains several functions to update status of discount and calculate discounted price
 */
pragma solidity ^0.8.0;

library DiscountLib {

    /**
    * @dev Discount data storage struct 
    */
    struct DiscountData {
        bool isActive;
        uint256 percentage;
    }

    /**
    * @dev Sets a discount percentage
    * @param self DiscountData storage pointer
    * @param percentage Discount percentage to set
    */
    function setDiscount(DiscountData storage self, uint256 percentage) public {
        require(percentage > 0 && percentage < 100, "Invalid discount percentage");
        self.isActive = true;
        self.percentage = percentage;
    }

    /**
    * @dev Cancels any active discount
    * @param self DiscountData storage pointer
    */
    function cancelDiscount(DiscountData storage self) public {
        self.isActive = false;
        self.percentage = 0;
    }

    /**
    * @dev Calculates discounted price based on original price and active discount
    * @param self DiscountData storage pointer
    * @param originalPrice Original non-discounted price
    * @return Discounted price
    */
    function calculateDiscountedPrice(DiscountData storage self, uint256 originalPrice) public view returns (uint256) {
        if (self.isActive) {
            return originalPrice * (100 - self.percentage) / 100;
        } else {
            return originalPrice;
        }
    }
}
