// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FarmerProcessor {
    struct Order {
        uint id;
        uint quantity;
        string status;
        address processor;
    }

    struct Offer {
        uint id;
        uint orderId;
        string productionDate;
        uint pricePerLiter;
        string origin;
        string status;
        address farmer;
    }

    struct Transaction {
        uint orderId;
        uint offerId;
        uint timestamp;
        address farmer;
        address processor;
    }

    mapping(uint => Order) public orders;
    mapping(uint => Offer) public offers;
    mapping(uint => Transaction) public transactions;
    uint public nextOrderId = 1;
    uint public nextOfferId = 1;
    uint public nextTransactionId = 1;

    /**
     * @dev Processor can create a new order
     * @param _quantity The quantity of milk (In Litre)
     * @return The id of the created order
     */
    function createOrder(uint _quantity) public returns (uint) {
        orders[nextOrderId] = Order(
            nextOrderId,
            _quantity,
            "In progress",
            msg.sender
        );
        uint current = nextOrderId;
        nextOrderId++;
        return current;
    }

    /**
     * @dev Processor can cancel an existing order
     * @param _orderId The id of the order to cancel
     * @return The id of the cancelled order
     */
    function cancelOrder(uint _orderId) public returns (uint) {
        require(
            orders[_orderId].processor == msg.sender,
            "Only the processor who created the order can cancel it"
        );
        orders[_orderId].status = "Cancelled";
        return _orderId;
    }

    /**
     * @dev Processor can view an existing order
     * @param _orderId The id of the order
     * @return Order information
     */
    function viewOrder(
        uint _orderId
    ) public view returns (uint, uint, string memory, address) {
        Order memory order = orders[_orderId];
        return (order.id, order.quantity, order.status, order.processor);
    }

    /**
     * @dev Farmer can create a offer
     * @param _orderId The id of the order this offer is related to
     * @param _productionDate The production date of milk
     * @param _pricePerLiter The price per liter of milk
     * @param _origin The origin of the milk
     * @return The id of the created offer
     */
    function createOffer(
        uint _orderId,
        string memory _productionDate,
        uint _pricePerLiter,
        string memory _origin
    ) public returns (uint) {
        offers[nextOfferId] = Offer(
            nextOfferId,
            _orderId,
            _productionDate,
            _pricePerLiter,
            _origin,
            "In progress",
            msg.sender
        );
        uint current = nextOfferId;
        nextOfferId++;
        return current;
    }

    /**
     * @dev Farmer can cancel an existing offer
     * @param _offerId The id of the offer to cancel
     * @return The id of the cancelled offer
     */
    function cancelOffer(uint _offerId) public returns (uint) {
        require(
            offers[_offerId].farmer == msg.sender,
            "Only the farmer who created the offer can cancel it"
        );
        offers[_offerId].status = "Cancelled";
        return _offerId;
    }

    /**
     * @dev Processors can list all the offers for their specific order
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

        Offer[] memory activeOffers = new Offer[](offerCount);
        uint counter = 0;
        for (uint i = 1; i < nextOfferId; i++) {
            if (
                offers[i].orderId == _orderId &&
                keccak256(abi.encodePacked(offers[i].status)) ==
                keccak256(abi.encodePacked("In progress"))
            ) {
                activeOffers[counter] = offers[i];
                counter++;
            }
        }

        return activeOffers;
    }

    /**
     * @dev Processor can accpet a satisfying offer and make a transaction
     * @param _orderId The id of the order
     * @param _offerId The id of the offer
     * @return The id of the created transaction
     */
    function acceptOffer(uint _orderId, uint _offerId) public returns (uint) {
        require(
            orders[_orderId].processor == msg.sender,
            "Only the processor who created the order can accept offers"
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
            block.timestamp,
            offers[_offerId].farmer,
            orders[_orderId].processor
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
