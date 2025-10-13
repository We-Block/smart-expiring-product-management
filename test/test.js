const Factory = artifacts.require("Factory");

contract("Factory", (accounts) => {
    const [owner, manufacturer, distributor, retailer, outsider] = accounts;
    const categoryFood = 0; // ProductLib.Category.Food

    let factory;

    const nowInSeconds = () => Math.floor(Date.now() / 1000);

    const defaultProductArgs = () => {
        const now = nowInSeconds();
        return {
            manufacturer: "Acme Corp",
            name: "Organic Milk",
            manufactureDate: now - 7 * 86400,
            expiryDate: now + 45 * 86400,
            category: categoryFood,
            quantity: 50,
            isQualityProduct: true,
            price: 1_000
        };
    };

    beforeEach(async () => {
        factory = await Factory.new({ from: owner });
    });

    it("allows the deployer to create a product without extra role setup", async () => {
        const args = defaultProductArgs();

        await factory.createProduct(
            args.manufacturer,
            args.name,
            args.manufactureDate,
            args.expiryDate,
            args.category,
            args.quantity,
            args.isQualityProduct,
            args.price,
            { from: owner }
        );

        const stored = await factory.products(0);
        assert.equal(stored.name, args.name, "product name should match");
        assert.equal(stored.manufacturer, args.manufacturer, "manufacturer should match");
        assert.equal(Number(stored.quantity), args.quantity, "quantity should match");
    });

    it("enforces role checks when updating product location", async () => {
        const args = defaultProductArgs();
        await factory.assignRole(manufacturer, 2, { from: owner }); // grant manufacturer role
        await factory.createProduct(
            args.manufacturer,
            args.name,
            args.manufactureDate,
            args.expiryDate,
            args.category,
            args.quantity,
            args.isQualityProduct,
            args.price,
            { from: manufacturer }
        );

        try {
            await factory.updateProductLocation(0, 1, { from: outsider });
            assert.fail("expected distributor restriction");
        } catch (error) {
            assert(
                error.message.includes("Only distributors can set this location"),
                "should revert with distributor message"
            );
        }

        await factory.assignRole(distributor, 3, { from: owner });
        await factory.updateProductLocation(0, 1, { from: distributor });
        const stored = await factory.products(0);
        assert.equal(Number(stored.currentLocation), 1, "location should be Distributor");
    });

    it("zeroes price for expired products when updating pricing", async () => {
        const now = nowInSeconds();
        await factory.createProduct(
            "Time Capsule",
            "Expired Juice",
            now - 30 * 86400,
            now - 1,
            categoryFood,
            10,
            true,
            500,
            { from: owner }
        );

        await factory.updatePrice(0, { from: owner });
        const stored = await factory.products(0);
        assert.equal(Number(stored.price), 0, "expired product price should be zero");
    });

    it("rejects quantity updates for products that were never created", async () => {
        try {
            await factory.updateProductQuantity(99, 5, { from: owner });
            assert.fail("expected missing product to revert");
        } catch (error) {
            assert(
                error.message.includes("Product does not exist"),
                "should revert with missing product message"
            );
        }
    });
});
