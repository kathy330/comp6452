// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "remix_tests.sol"; // This import is automatically injected by Remix.
import "../contracts/FarmerProcessor.sol";

contract TestFarmerProcessor {
    FarmerProcessor farmerProcessor;

    function beforeAll() public {
        farmerProcessor = new FarmerProcessor();
    }

    function checkCreateOrder() public {
        uint orderId = farmerProcessor.createOrder(100);
        Assert.equal(orderId, 1, "Initial order id should be 1");
    }

    function checkCancelOrder() public {
        uint orderId = farmerProcessor.cancelOrder(1);
        Assert.equal(orderId, 1, "Cancelled order id should be 1");
    }

    function checkCreateOffer() public {
        uint offerId = farmerProcessor.createOffer(1, "2023-07-25", 10, "AUS");
        Assert.equal(offerId, 1, "Initial offer id should be 1");
    }

    function checkCancelOffer() public {
        uint offerId = farmerProcessor.cancelOffer(1);
        Assert.equal(offerId, 1, "Cancelled offer id should be 1");
    }

    function checkViewOffers() public {
        FarmerProcessor.Offer[] memory offers = farmerProcessor.viewOffers(1);
        Assert.equal(offers.length, 0, "Active offers length should be 0");
    }

    function checkAcceptOffer() public {
        farmerProcessor.createOrder(100);
        farmerProcessor.createOffer(2, "2023-07-25", 10, "AUS");
        uint transactionId = farmerProcessor.acceptOffer(2, 2);
        Assert.equal(transactionId, 1, "Initial transaction id should be 1");
    }
}
