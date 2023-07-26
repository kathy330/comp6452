# COMP6452 Project2 - Milk Chain

## install environment

- install node.js & npm
- install truffle `npm install -g truffle`
- install ganache
- install web3.py library `pip install web3`
- install required python library

## Ganache

run ganache `ganache-cli`, keep ganache on the background

## Comply and deploy sc

1. in your project folder run `truffle init`, don't overwrite the existing files
2. Deploy your contract：`truffle migrate`
3. After run `truffle migrate` use the delegate contract address and update the address to `\servers\.env` file
4. After you installed all the required python library, run code `python3 databaseBlockchainAPI.py` to open the database
5. And then you can use XXX to register user (input ganache address) to interact our
6. Also yoy can view the document `FarmerProcessorAPI.md` to interact with our smart contract using POSTMAN
