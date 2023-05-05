// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DiscountLib {
    struct DiscountData {
        bool isActive;
        uint256 percentage;
    }

    function setDiscount(DiscountData storage self, uint256 percentage) public {
        require(percentage > 0 && percentage < 100, "Invalid discount percentage");
        self.isActive = true;
        self.percentage = percentage;
    }

    function cancelDiscount(DiscountData storage self) public {
        self.isActive = false;
        self.percentage = 0;
    }

    function calculateDiscountedPrice(DiscountData storage self, uint256 originalPrice) public view returns (uint256) {
        if (self.isActive) {
            return originalPrice * (100 - self.percentage) / 100;
        } else {
            return originalPrice;
        }
    }
}
