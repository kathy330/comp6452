// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "../contracts/ProcessorRetailer.sol";

contract TestProcessorRetailer {
    ProcessorRetailer processorRetailer;

    function beforeAll() public {
        processorRetailer = new ProcessorRetailer();
    }

    function checkCreateOrder() public {
        uint orderId = processorRetailer.createOrder(address(this), 1, 100);
        Assert.equal(orderId, 1, "Initial order id should be 1");
    }

    function checkCreateOffer() public {
        uint[] memory offerIds = new uint[](0);
        uint offerId = processorRetailer.createOffer(10, offerIds, "2023-07-25", "A", "2023-07-24", "AUS", 1);
        Assert.equal(offerId, 1, "Initial offer id should be 1");
    }

    function checkCancelOffer() public {
        uint offerId = processorRetailer.cancelOffer(1);
        Assert.equal(offerId, 1, "Cancelled offer id should be 1");
    }

    function checkViewOffers() public {
        ProcessorRetailer.Offer[] memory offers = processorRetailer.viewOffers(1);
        Assert.equal(offers.length, 0, "Active offers length should be 0");
    }

    function checkAcceptOffer() public {
        processorRetailer.createOrder(address(this), 1, 100);
        uint[] memory offerIds = new uint[](0);
        processorRetailer.createOffer(10, offerIds, "2023-07-25", "A", "2023-07-24", "AUS", 2);
        uint transactionId = processorRetailer.acceptOffer(2, 2);
        Assert.equal(transactionId, 1, "Initial transaction id should be 1");
    }
}
