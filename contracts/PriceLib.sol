// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductLib.sol";

library PriceLib {
    uint256 constant THIRTY_DAYS = 30;
    uint256 constant SEVEN_DAYS = 7;
    uint256 constant PRICE_30_DAYS = 1000;
    uint256 constant PRICE_7_DAYS = 800;
    uint256 constant PRICE_LESS_7_DAYS = 500;
    uint256 constant SECONDS_IN_DAY = 86400;

    function calculatePrice(uint256 productExpiryDate) internal view returns (uint256) {
        require(productExpiryDate > block.timestamp, "Expiry date must be in the future");

        uint256 remainingDays = (productExpiryDate - block.timestamp) / SECONDS_IN_DAY;

        return remainingDays > THIRTY_DAYS ? PRICE_30_DAYS : (remainingDays > SEVEN_DAYS ? PRICE_7_DAYS : PRICE_LESS_7_DAYS);
    }

    function updatePrice(ProductLib.Product storage product) internal returns (uint256) {
        product.price = calculatePrice(product.expiryDate);
        return product.price;
    }
}
