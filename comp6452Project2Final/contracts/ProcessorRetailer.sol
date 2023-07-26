// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Oracle.sol";

contract ProcessorRetailer {
    Oracle public oracle;

    constructor(address _oracleAddress) {
        oracle = Oracle(_oracleAddress);
    }

    struct Order {
        address processorAddress;
        uint productId;
        uint quantity;
        string status;
        address retailer;
    }

    struct Offer {
        uint price;
        uint[] offerIds;
        string bestBeforeDate;
        string milkType;
        string productionDate;
        uint temperature;
        uint nitrogenContent;
        uint sterilizationTime;
        string origin;
        uint orderId;
        string status;
        address processor;
    }

    struct Transaction {
        uint orderId;
        uint offerId;
        uint[] offerIds;
        uint timestamp;
        address processor;
        address retailer;
    }

    mapping(uint => Order) public orders;
    mapping(uint => Offer) public offers;
    mapping(uint => Transaction) public transactions;
    uint public nextOrderId = 1;
    uint public nextOfferId = 1;
    uint public nextTransactionId = 1;

    /**
     * @dev Retailer can create a new order
     * @param _processorAddress The address of the processor(Milk brand)
     * @param _productId The product id(Universal Product Code) of the milk product
     * @param _quantity The quantity of the milk product
     * @return The id of the created order
     */
    function createOrder(
        address _processorAddress,
        uint _productId,
        uint _quantity
    ) public returns (uint) {
        orders[nextOrderId] = Order(
            _processorAddress,
            _productId,
            _quantity,
            "In progress",
            msg.sender
        );
        uint currentOrderId = nextOrderId;
        nextOrderId++;
        return currentOrderId;
    }

    /**
     * @dev Retailer can cancel an existing order
     * @param _orderId The id of the order to cancel
     * @return The id of the cancelled order
     */
    function cancelOrder(uint _orderId) public returns (uint) {
        require(
            orders[_orderId].retailer == msg.sender,
            "Only the retailer who created the order can cancel it"
        );
        require(
            keccak256(abi.encodePacked(orders[_orderId].status)) ==
                keccak256(abi.encodePacked("Completed")),
            "This transaction has been finalised. You may not cancel it"
        );
        orders[_orderId].status = "Cancelled";
        return _orderId;
    }

    /**
     * @dev Processor can create a new offer
     * @param _price The price of the milk product
     * @param _offerIds The array of offer_ids from the farmers.
     * @param _bestBeforeDate The best before date of the milk product
     * @param _milkType The milk type of the milk product(i.e Full cream, Skimmed, Low fat)
     * @param _productionDate The production date of the milk product
     * @param _origin The origin of the milk product
     * @param _orderId The id of the order
     * @return The id of the created offer
     */
    function createOffer(
        uint _price,
        uint[] memory _offerIds,
        string memory _bestBeforeDate,
        string memory _milkType,
        string memory _productionDate,
        string memory _origin,
        uint _orderId
    ) public returns (uint) {
        (
            uint _temperature,
            uint _nitrogenContent,
            uint _sterilizationTime
        ) = oracle.getData(tx.origin);
        offers[nextOfferId] = Offer(
            _price,
            _offerIds,
            _bestBeforeDate,
            _milkType,
            _productionDate,
            _temperature,
            _nitrogenContent,
            _sterilizationTime,
            _origin,
            _orderId,
            "In progress",
            msg.sender
        );
        uint current = nextOfferId;
        nextOfferId++;
        return current;
    }

    /**
     * @dev Processor can cancel an existing offer
     * @param _offerId The id of the offer to cancel
     * @return The id of the cancelled offer
     */
    function cancelOffer(uint _offerId) public returns (uint) {
        require(
            offers[_offerId].processor == msg.sender,
            "Only the processor who created the offer can cancel it"
        );
        offers[_offerId].status = "Cancelled";
        return _offerId;
    }

    /**
     * @notice Processor views all orders from different retailer
     * @dev Returns all the orders for a specific processor address
     * @param _processorAddress The address of the processor
     * @return An array of Order structs for the given processor address
     */
    function viewOrders(
        address _processorAddress
    ) public view returns (Order[] memory) {
        uint orderCount = 0;
        for (uint i = 1; i < nextOrderId; i++) {
            if (
                orders[i].processorAddress == _processorAddress &&
                keccak256(abi.encodePacked(orders[i].status)) ==
                keccak256(abi.encodePacked("In progress"))
            ) {
                orderCount++;
            }
        }

        Order[] memory myOrders = new Order[](orderCount);
        uint counter = 0;
        for (uint i = 1; i < nextOrderId; i++) {
            if (
                orders[i].processorAddress == _processorAddress &&
                keccak256(abi.encodePacked(orders[i].status)) ==
                keccak256(abi.encodePacked("In progress"))
            ) {
                myOrders[counter] = orders[i];
                counter++;
            }
        }

        return myOrders;
    }

    /**
     * @dev Returns all the offers for a specific order to a Retailer
     * @param _orderId The id of the order
     * @return An array of Offer structs for the given order
     */
    function viewOffers(uint _orderId) public view returns (Offer[] memory) {
        uint offerCount = 0;
        for (uint i = 1; i < nextOfferId; i++) {
            if (
                offers[i].orderId == _orderId &&
                keccak256(abi.encodePacked(offers[i].status)) ==
                keccak256(abi.encodePacked("In progress"))
            ) {
                offerCount++;
            }
        }

        Offer[] memory myOffers = new Offer[](offerCount);
        uint counter = 0;
        for (uint i = 1; i < nextOfferId; i++) {
            if (
                offers[i].orderId == _orderId &&
                keccak256(abi.encodePacked(offers[i].status)) ==
                keccak256(abi.encodePacked("In progress"))
            ) {
                myOffers[counter] = offers[i];
                counter++;
            }
        }

        return myOffers;
    }

    /**
     * @dev Retailer can accept an offer and creates a transaction
     * @param _orderId The id of the order
     * @param _offerId The id of the offer
     * @return The id of the created transaction
     */
    function acceptOffer(uint _orderId, uint _offerId) public returns (uint) {
        require(
            orders[_orderId].retailer == msg.sender,
            "Only the retailer who created the order can accept offers"
        );
        require(
            keccak256(abi.encodePacked(orders[_orderId].status)) ==
                keccak256(abi.encodePacked("In progress")),
            "Order must be in progress"
        );
        require(
            keccak256(abi.encodePacked(offers[_offerId].status)) ==
                keccak256(abi.encodePacked("In progress")),
            "Offer must be in progress"
        );
        require(
            offers[_offerId].orderId == _orderId,
            "Offer must correspond to the order"
        );

        offers[_offerId].status = "Completed";
        orders[_orderId].status = "Completed";
        transactions[nextTransactionId] = Transaction(
            _orderId,
            _offerId,
            offers[_offerId].offerIds,
            block.timestamp,
            offers[_offerId].processor,
            orders[_orderId].retailer
        );
        uint currentTransactionId = nextTransactionId;
        nextTransactionId++;
        return currentTransactionId;
    }

    /**
     * @dev Returns all the transactions
     * @return An array of all Transaction structs
     */
    function getAllTransactions() public view returns (Transaction[] memory) {
        Transaction[] memory transactionsArray = new Transaction[](
            nextTransactionId
        );
        for (uint i = 1; i < nextTransactionId; i++) {
            transactionsArray[i - 1] = transactions[i];
        }
        return transactionsArray;
    }
}
