// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract RetailerCustomer {

    struct MilkProduct {
        uint productType;
        string milkType;
        string brand;
        string origin;
        uint price;
        string description;
        uint stock;
        address retailer;
    }

    struct Transaction {
        uint productType;
        uint quantity;
        uint[] offerIds;
        string status;
        address customer;
        address retailer;
    }


    mapping(uint => MilkProduct) public products;
    uint[] public productTypes;  // Array to store all productTypes

    mapping(uint => Transaction) public transactions;
    uint public nextTransactionId = 1;

    /**
     * @dev Retailer can create a new product
     * @param _productType The product id(Universal Product Code) of the product
     * @param _milkType The milk type
     * @param _brand The brand of the milk product
     * @param _origin The origin of the milk product
     * @param _price The price of the milk product
     * @param _description The description of the milk product
     * @param _stock The stock of the milk product
     */
    function createProduct(
        uint _productType, 
        string memory _milkType, 
        string memory _brand, 
        string memory _origin, 
        uint _price, 
        string memory _description, 
        uint _stock
    ) public {
        require(products[_productType].retailer == address(0), "Product already exists");
        products[_productType] = MilkProduct(_productType, _milkType, _brand, _origin, _price, _description, _stock, msg.sender);
        productTypes.push(_productType);  // Add productType to the array when creating a product
    }

    /**
     * @dev Retailer can update an existing product, if the parameter is empty (0 or ""), then means this information will not be modified
     * @param _productType The product id(Universal Product Code) of the product
     * @param _milkType The milk type
     * @param _brand The brand of the milk product
     * @param _origin The origin of the milk product
     * @param _price The price of the milk product
     * @param _description The description of the milk product
     * @param _stock The stock of the milk product
     */    
    function updateProduct(
        uint _productType, 
        string memory _milkType, 
        string memory _brand, 
        string memory _origin, 
        uint _price, 
        string memory _description, 
        uint _stock
    ) public {
        require(products[_productType].retailer == msg.sender, "Only the retailer who created the product can update it");

        if (bytes(_milkType).length > 0) {
            products[_productType].milkType = _milkType;
        }
        if (bytes(_brand).length > 0) {
            products[_productType].brand = _brand;
        }
        if (bytes(_origin).length > 0) {
            products[_productType].origin = _origin;
        }
        if (_price > 0) {
            products[_productType].price = _price;
        }
        if (bytes(_description).length > 0) {
            products[_productType].description = _description;
        }
        if (_stock > 0) {
            products[_productType].stock = _stock;
        }
    }

    /**
     * @dev Retailer can remove an existing product
     * @param _productType The product id(Universal Product Code) of the product to remove
     */
    function removeProduct(uint _productType) public {
        require(products[_productType].retailer == msg.sender, "Only the retailer who created the product can remove it");
        delete products[_productType];
    }

    /**
     * @dev Customer can view a specific product or all products
     * @param _productType The  product id(Universal Product Code) of the product to view, if 0 view all products
     * @return An array of MilkProduct structs
     */
    function viewProduct(uint _productType) public view returns (MilkProduct[] memory) {
        // If _productType is 0, return all products
        if (_productType == 0) {
            uint productCount = productTypes.length;

            MilkProduct[] memory allProducts = new MilkProduct[](productCount);
            for (uint i = 0; i < productCount; i++) {
                allProducts[i] = products[productTypes[i]];
            }

            return allProducts;
        } else { // If _productType is not 0, return the product of _productType
            require(products[_productType].retailer != address(0), "Product does not exist");

            MilkProduct[] memory product = new MilkProduct[](1);
            product[0] = products[_productType];

            return product;
        }
    }

    /**
     * @dev Customer can buy milk product
     * @param _productType The type of the product to buy
     * @param _quantity The quantity of the product to buy
     */
    function buyProduct(uint _productType, uint _quantity) public {
        require(products[_productType].retailer != address(0), "Product does not exist");
        require(products[_productType].stock >= _quantity, "Not enough stock");

        products[_productType].stock -= _quantity;
        transactions[nextTransactionId] = Transaction(_productType, _quantity, new uint[](0), "Incomplete", msg.sender, products[_productType].retailer);
        nextTransactionId++;
    }

    /**
     * @dev Retailer will add the farmer's offer_ids to transaction record
     * @param _transactionId The id of the transaction to update
     * @param _offerIds The array of farmer's offer_ids
     */
    function updateTransaction(uint _transactionId, uint[] memory _offerIds) public {
        require(keccak256(abi.encodePacked(transactions[_transactionId].status)) == keccak256(abi.encodePacked("Incomplete")), "Transaction is not incomplete");
        require(products[transactions[_transactionId].productType].retailer == msg.sender, "Only the retailer of the product can update the transaction");

        transactions[_transactionId].offerIds = _offerIds;
        transactions[_transactionId].status = "Complete";
    }

    /**
     * @dev Returns all the transactions
     * @return An array of all Transaction structs
     */
    function getAllTransactions() public view returns (Transaction[] memory) {
        Transaction[] memory transactionsArray = new Transaction[](nextTransactionId);
        for (uint i = 1; i < nextTransactionId; i++) {
            transactionsArray[i - 1] = transactions[i];
        }
        return transactionsArray;
    }

}
