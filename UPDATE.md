## v1.0 更新日志

1. 新建一个名为 **Factory** 的智能合约，继承了 `ERC721` 和 `Ownable` 合约。
2. 定义了一个名为 `_tokenIdCounter` 的私有变量，用于生成唯一的 Token ID。
3. 定义了一个名为 **Product** 的结构体，包含了生产商、生产日期和是否合格的信息。
4. 创建了一个映射 (mapping) 名为 `products`，用于将 Token ID 映射到 Product 结构体。
5. 初始化 **Factory** 合约，设置了名字 (Factory) 和符号 (FACT)。
6. 实现了 `mintProduct` 函数，该函数允许合约的拥有者创建新的产品，并为其生成 Token ID。
7. 实现了 `getProductInfo` 函数，用于返回指定 Token ID 的产品信息。

## v1.1 更新日志

1. 更新 Solidity 版本为 `^0.8.0`。
2. 将 `_tokenIdCounter` 变量名修改为 `tokenCounter` 并将其访问权限设为 public。
3. 在 **Product** 结构体中新增了 `name` 和 `expiryDate` 属性，并将 `productionDate` 修改为 `manufactureDate`，将 `isQualified` 修改为 `isQualityProduct`。
4. 为 `Factory` 合约设置的名字 (Factory) 和符号 (FACT) 分别修改为 "Factory" 和 "FACTORY"。
5. 实现了 `createProduct` 函数，用于创建新产品。在创建产品的过程中，根据产品的到期日期计算产品价格。
6. 新增了 `calculatePrice` 函数，根据产品的到期日期动态计算产品价格。
7. 新增了 `updatePrice` 函数，允许合约的拥有者更新指定产品的价格。
8. 实现了 `isProductExpired` 函数，用于检查指定产品是否过期。
9. 新增了 `calculateAveragePrice` 函数，计算所有未过期产品的平均价格。
10. 新增了 `getExpiringProducts` 函数，根据指定的天数阈值返回即将过期的产品列表。
11. 实现了 `getProductsByManufacturer` 函数，根据生产商名称返回产品列表。

## v1.2 更新日志

1. 将合约名称从 `Factory` 更改为 `FactoryTest`。
2. 在 `createProduct` 函数中，新增了对产品生产商名称、产品名称以及生产日期和到期日期的合法性检查。
3. 新增 `ProductCreated` 事件，当创建新产品时触发。
4. 移除了 `createProduct` 函数中的 `calculatePrice` 函数调用，价格作为参数直接传入。
5. 新增了 `createProductsBatch` 函数，允许批量创建产品。
6. 新增了 `updatePricesBatch` 函数，允许批量更新产品价格。

## v1.3 更新日志

1. 引入了 `SafeMath` 库，并使用 `SafeMath` 中的 `add` 函数替换了所有的 `+` 运算。
2. 将合约名称从 `Factory` 更改为 `FactoryTest`。
3. 在 `createProduct` 函数中，新增了对产品生产商名称、产品名称以及生产日期和到期日期的合法性检查。
4. 新增 `ProductCreated` 事件，当创建新产品时触发。
5. 将 `createProduct` 函数的参数从 `memory` 类型更改为 `calldata` 类型，以节省 gas 成本。
6. 移除了 `createProduct` 函数中的 `calculatePrice` 函数调用，价格作为参数直接传入。
7. 新增了 `createProductsBatch` 函数，允许批量创建产品。
8. 优化了 `calculatePrice` 函数的逻辑，使用了三元运算符替换了原来的 `if-else` 语句。
9. 新增了 `updatePricesBatch` 函数，允许批量更新产品价格。
10. 在 `calculateAveragePrice` 和 `getExpiringProducts` 函数中，将 `tokenCounter` 的值提前赋值给一个变量，以减少多次访问 `tokenCounter` 的 gas 成本。
11. 优化了 `getProductsByManufacturer` 函数，将生产商名称的哈希计算提前到循环外部进行。
