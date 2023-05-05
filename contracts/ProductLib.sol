// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ProductLib {
    struct Product {
        string name;
        string manufacturer;
        uint256 manufactureDate;
        uint256 expiryDate;
        bool isQualityProduct;
        uint256 price;
    }

    function isValidProduct(Product memory product) internal pure returns (bool) {
        return bytes(product.name).length > 0 && bytes(product.manufacturer).length > 0 && product.manufactureDate < product.expiryDate;
    }
}
