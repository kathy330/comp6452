# COMP6452 Project2 - Milk Chain

## install environment

- install node.js & npm
- install truffle 
- install ganache [CLI](https://www.npmjs.com/package/ganache)/[GUI](https://trufflesuite.com/ganache/)
- install required python library

## Ganache

run ganache `ganache`, keep ganache on the background

## Comply and deploy sc

1. In this project folder run `truffle init`, don't overwrite the existing files
2. Deploy your contract：`truffle migrate`
3. After running `truffle migrate` use the delegate contract address and update the address to the `\servers\.env` file
4. After you installed all the required Python library, run code `python3 databaseBlockchainAPI.py` to open the database

## User APIs

### 1. Create a user

- **URL:** `http://localhost:5000/users/`
- **Method** `POST`
- **Data**:
```json
{
    "user_blockchain_address": "REPLACE_THIS_WITH_THE_REAL_BLOCKCHAIN_ADDRESS",
    "role": "Farmer",
    "name": "Zhiyang",
    "mobile": "+0412412553",
    "email": "z5142124@ad.unsw.edu.au",
    "address": "20 Gloucester Street"
}
```

### 2. Query a user

- **URL:** `http://localhost:5000/users/<userID>`
- **Method** `GET`
- **Note**: Use the returned userID from the returned result in "Create an user" API.


### 3. Update a user

- **URL:** `http://localhost:5000/users/<userID>`
- **Method** `PUT`
- **Data**:
```json
{
    "user_blockchain_address": "REPLACE_THIS_WITH_THE_REAL_BLOCKCHAIN_ADDRESS",
    "role": "Farmer",
    "name": "Zhiyang",
    "mobile": "+0412412553",
    "email": "z5142124@ad.unsw.edu.au",
    "address": "20 Gloucester Street"
}
```

### 4. Delete a user

- **URL:** `http://localhost:5000/users/<userID>`
- **Method** `DELETE`
- **Note**: Use the returned userID from the returned result in "Create an user" API.

### 5. List users

- **URL:** `http://localhost:5000/listAllUsers?page=1&per_page=20`
- **Method** `GET`
- **Note**: This request will return a list of users accordining to the pagenation parameters passed in. **Page** is which page you are after, and **per_page** is how many users you are after per page.

## FarmerProcessorAPI

### 1. Create Order

- **URL:** `http://localhost:5000/farmerProcessor/createOrder`
- **Method:** `POST`
- **Data:**

```json
{
  "quantity": 100,
  "contractAddress": "0xYourAccountAddress"
}
```

### 2. View Order

- **URL:** `http://localhost:5000/farmerProcessor/viewOrder?_orderId=1`
- **Method:** `GET`

### 3. Cancel Order

- **URL:** `http://localhost:5000/farmerProcessor/cancelOrder`
- **Method:** `POST`
- **Data:**

```json
{
  "orderId": 1,
  "contractAddress": "0xYourAccountAddress"
}
```

### 4. Create Offer

- **URL:** `http://localhost:5000/farmerProcessor/createOffer`
- **Method:** `POST`
- **Data:**

```json
{
  "orderId": 1,
  "productionDate": "2023-07-23",
  "pricePerLiter": 10,
  "origin": "USA",
  "contractAddress": "0xYourAccountAddress"
}
```

### 5. Cancel Offer

- **URL:** `http://localhost:5000/farmerProcessor/cancelOffer`
- **Method:** `POST`
- **Data:**

```json
{
  "offerId": 1,
  "contractAddress": "0xYourAccountAddress"
}
```

### 6. View Offers

- **URL:** `http://localhost:5000/farmerProcessor/viewOffers?orderId=1`
- **Method:** `GET`

### 7. Accept Offer

- **URL:** `http://localhost:5000/farmerProcessor/acceptOffer`
- **Method:** `POST`
- **Data:**

```json
{
  "orderId": 1,
  "offerId": 1,
  "contractAddress": "0xYourAccountAddress"
}
```

### 8. Get All Transactions

- **URL:** `http://localhost:5000/farmerProcessor/getAllTransactions`
- **Method:** `GET`

Please note that the above `"0xYourAccountAddress"`, `1`, etc. are just examples, and you need to replace them with your own parameter values according to the actual situation.
