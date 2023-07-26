// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "../contracts/RetailerCustomer.sol";

contract TestRetailerCustomer {
    RetailerCustomer retailerCustomer;

    function beforeAll() public {
        retailerCustomer = new RetailerCustomer();
    }

    function checkCreateProduct() public {
        retailerCustomer.createProduct(1, "A", "A", "AUS", 10, "A", 100);
        RetailerCustomer.MilkProduct[] memory products = retailerCustomer.viewProduct(1);
        Assert.equal(products[0].productType, 1, "Product type should be 1");
        Assert.equal(products[0].milkType, "A", "Milk type should be A");
    }

    function checkUpdateProduct() public {
        retailerCustomer.updateProduct(1, "B", "B", "B", 20, "B", 200);
        RetailerCustomer.MilkProduct[] memory products = retailerCustomer.viewProduct(1);
        Assert.equal(products[0].milkType, "B", "Milk type should be B");
        Assert.equal(products[0].brand, "B", "Brand should be B");
    }

}
