// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductLib.sol";
import "./PriceLib.sol";

library ProductOperationsLib {
    using ProductLib for ProductLib.Product;

    /** 
    * @dev Creates a new product.
    * @param products The mapping of all products.
    * @param tokenId The ID of the new product.
    * @param manufacturer The name of the product manufacturer.
    * @param name The name of the product.
    * @param manufactureDate The date the product was manufactured.
    * @param expiryDate The expiry date of the product.
    * @param isQualityProduct Whether the product is of high quality. 
    * @param price The price of the product.
    */
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