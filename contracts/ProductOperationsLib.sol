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
    * @param category The category of the product.
    * @param quantity The initial quantity.
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
        ProductLib.Category category,
        uint256 quantity,
        bool isQualityProduct,
        uint256 price
    ) internal {
        ProductLib.Product memory newProduct = ProductLib.Product({
            name: name,
            manufacturer: manufacturer,
            manufactureDate: manufactureDate,
            expiryDate: expiryDate,
            price: price,
            category: category,
            currentLocation: ProductLib.Location.Manufacturer,
            quantity: quantity,
            isQualityProduct: isQualityProduct
        });

        require(newProduct.isValidProduct(), "Invalid product");
        require(price > 0, "Price must be greater than zero");
        products[tokenId] = newProduct;
    }
    
    /**
    * @dev Updates the location of a product in the supply chain.
    * @param products The mapping of all products.
    * @param tokenId The ID of the product.
    * @param newLocation The new location of the product.
    */
    function updateProductLocation(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenId,
        ProductLib.Location newLocation
    ) internal {
        require(tokenId < products.length, "Product does not exist");
        products[tokenId].updateLocation(newLocation);
    }
    
    /**
    * @dev Updates the quantity of a product.
    * @param products The mapping of all products.
    * @param tokenId The ID of the product.
    * @param newQuantity The new quantity of the product.
    */
    function updateProductQuantity(
        mapping(uint256 => ProductLib.Product) storage products,
        uint256 tokenId,
        uint256 newQuantity
    ) internal {
        require(tokenId < products.length, "Product does not exist");
        products[tokenId].updateQuantity(newQuantity);
    }
}