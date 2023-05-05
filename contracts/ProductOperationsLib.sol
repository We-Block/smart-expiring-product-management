// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductLib.sol";
import "./PriceLib.sol";

library ProductOperationsLib {
    using ProductLib for ProductLib.Product;

    function createProduct(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenId,
        string memory manufacturer,
        string memory name,
        uint256 manufactureDate,
        uint256 expiryDate,
        bool isQualityProduct,
        uint256 price
    ) internal {
        ProductLib.Product memory newProduct = ProductLib.Product(
            string(manufacturer),
            string(name),
            manufactureDate,
            expiryDate,
            isQualityProduct,
            price
        );

        require(newProduct.isValidProduct(), "Invalid product");
        products[tokenId] = newProduct;
    }
}