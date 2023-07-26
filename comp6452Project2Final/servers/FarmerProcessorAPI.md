## Farmer Processor API Documentation

### 1. Create Order

- **URL:** `http://127.0.0.1:5000/farmerProcessor/createOrder`
- **Method:** `POST`
- **Data:**

```json
{
  "quantity": 100,
  "contractAddress": "0xUserBlockchainAddress"
}
```

### 2. View Order

- **URL:** `http://127.0.0.1:5000/farmerProcessor/viewOrder?_orderId=1`
- **Method:** `GET`

### 3. Cancel Order

- **URL:** `http://127.0.0.1:5000/farmerProcessor/cancelOrder`
- **Method:** `POST`
- **Data:**

```json
{
  "orderId": 1,
  "contractAddress": "0xUserBlockchainAddress"
}
```

### 4. Create Offer

- **URL:** `http://127.0.0.1:5000/farmerProcessor/createOffer`
- **Method:** `POST`
- **Data:**

```json
{
  "orderId": 1,
  "productionDate": "2023-07-23",
  "pricePerLiter": 10,
  "origin": "USA",
  "contractAddress": "0xUserBlockchainAddress"
}
```

### 5. Cancel Offer

- **URL:** `http://127.0.0.1:5000/farmerProcessor/cancelOffer`
- **Method:** `POST`
- **Data:**

```json
{
  "offerId": 1,
  "contractAddress": "0xUserBlockchainAddress"
}
```

### 6. View Offers

- **URL:** `http://127.0.0.1:5000/farmerProcessor/viewOffers?orderId=1`
- **Method:** `GET`

### 7. Accept Offer

- **URL:** `http://127.0.0.1:5000/farmerProcessor/acceptOffer`
- **Method:** `POST`
- **Data:**

```json
{
  "orderId": 1,
  "offerId": 1,
  "contractAddress": "0xUserBlockchainAddress"
}
```

### 8. Get All Transactions

- **URL:** `http://127.0.0.1:5000/farmerProcessor/getAllTransactions`
- **Method:** `GET`

Please note that the above `"0xUserBlockchainAddress"`, `1`, etc. are just examples, and you need to replace them with your own parameter values according to the actual situation.
