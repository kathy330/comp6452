from flask import Flask, request, jsonify
from web3 import Web3
import json, uuid, os
from flask_cors import CORS
from pymongo import MongoClient, errors
from flask_mongoengine import MongoEngine
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)
load_dotenv()  # take environment variables from .env.
#####################################################################################################
# the following are all blockchain and database related APIs,                                       #
# mainly the interactions between SCs and database                                                  #
#####################################################################################################

#config the default database
app.config["MONGO_URI"] = "mongodb://localhost:27017/milk-chain"
db = MongoEngine(app)

# define your user table structure
class User(db.Document):
    user_blockchain_address = db.StringField(required=True)
    role = db.StringField(required=True, choices=('Farmer', 'Processor', 'Retailer', 'Customer'))
    name = db.StringField(required=True)
    mobile = db.StringField(required=True)
    email = db.StringField(required=True)
    address = db.StringField(required=True)
    
    meta = {'collection': 'users'}

def connect_to_mongodb():
    try:
        # user mongoDB default port27017 to connect local mongodb
        client = MongoClient('mongodb://localhost:27017/milk-chain')
        return client
    except errors.ServerSelectionTimeoutError as err:
        # print error and return None
        print("pymongo ERROR:", err)
        return None

#####################################################################################################
# * the following are all user related APIs, mainly for user CRUD operations.                       #
#####################################################################################################

@app.route('/users', methods=['POST'])
def create_user():
    '''Create a new user'''
    data = request.get_json()
    
    data["userID"] = str(uuid.uuid4())
    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']  
        # Save the order in MongoDB
        
        users.insert_one(data)
    
    #user = User(**data).save()
    return jsonify({'userID': str(data["userID"])}), 201

@app.route('/users/<id>', methods=['GET'])
def get_user(id):
    '''Fetch a user given its identifier'''
    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        user = users.find_one({'userID': id})
        if user:
            # Convert ObjectId to string
            user['_id'] = str(user['_id'])
            return jsonify(user), 200
        else:
            return jsonify(error="User {} doesn't exist".format(id)), 404

@app.route('/users/<id>', methods=['PUT'])
def update_user(id):
    '''Update a user given its identifier'''
    data = request.get_json()
    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        user = users.find_one({'userID': id})
        if user:
            users.update_one({'userID': id}, {'$set': data})
            return jsonify(result=f'User {str(id)} updated'), 200
        else:
            return jsonify(error="User {} doesn't exist or has been deleted".format(id)), 404


@app.route('/users/<id>', methods=['DELETE'])
def delete_user(id):
    '''Delete a user given its identifier'''
    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        user = users.find_one({'userID': id})
        if user:
            users.delete_one({'userID': id})
            return jsonify(result=f'User {str(id)} deleted'), 200
        else:
            return jsonify(error="User {} doesn't exist or has been deleted".format(id)), 404

@app.route('/listAllUsers', methods=['GET'])
def list_all_users():
    '''List all users with pagination'''
    page = request.args.get('page', default=1, type=int)
    per_page = request.args.get('per_page', default=20, type=int)

    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        start_index = (page - 1) * per_page
        end_index = start_index + per_page
        users_list = list(users.find().skip(start_index).limit(per_page))
        
        # Convert ObjectId to string
        for user in users_list:
            user['_id'] = str(user['_id'])
        return jsonify(users=users_list, page=page), 200
    
#####################################################################################################
# * web3                                                                                            #
#####################################################################################################
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

with open("build/contracts/FarmerProcessorDelegate.json") as f:
    contract_json = json.load(f)
contract_abi = contract_json["abi"]

#####################################################################################################
# Replace this with the address of the deployed contract                                            #
#####################################################################################################
contract_address = os.getenv('FARMER_PROCESSOR_CONTRACT_ADDRESS')
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

@app.route('/farmerProcessor/viewOrder', methods=['GET'])
def view_order():
    _orderId = request.args.get('_orderId')
    if not _orderId:
        return jsonify({'error': 'Missing _orderId parameter'}), 400
    _orderId = int(_orderId)
    order = contract.functions.viewOrder(_orderId).call()
    return jsonify({'order': order}), 200

@app.route('/farmerProcessor/createOrder', methods=['POST'])
def create_order():
    # Parse the request payload
    payload = request.get_json(force=True)
    quantity = payload["quantity"]
    account_address = payload["contractAddress"]

    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        
        # * Retrieve the user with the given account_address
        user = users.find_one({'user_blockchain_address': account_address})
        if user is not None:
            if user['role'] != 'Processor':
                return {"status" : "Only Processor is allowed to use this function"}, 403

    # Contract interaction
    try:
        # Call the function to simulate the transaction and get the result
        result = contract.functions.createOrder(quantity).call({'from': account_address})

        # Send the transaction
        tx_hash = contract.functions.createOrder(quantity).transact({'from': account_address})
        tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    except ValueError as e:
        return {"status": str(e), "transactionResponse": str(e)}, 500
    db = client['milk-chain']
    orders = db['orders']
    # Save the order in MongoDB
    order = {
        'processor_address': account_address,
        'quantity': quantity,
    }
    orders.insert_one(order)
    return {"status": "Order Created!!!", "transactionResponse": result}, 200

@app.route('/farmerProcessor/cancelOrder', methods=['POST'])
def cancel_order():
    data = request.get_json()
    order_id = data['orderId']
    order_creator_address = data['contractAddress']
    
    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        
        # Retrieve the user with the given account_address
        user = users.find_one({'user_blockchain_address': order_creator_address})
        if user is not None:
            if user['role'] != 'Processor':
                return {"status" : "Only Processor is allowed to use this function"}, 403
    
    result = contract.functions.cancelOrder(order_id).call({'from': order_creator_address})

    tx_hash = contract.functions.cancelOrder(order_id).transact({'from': order_creator_address})
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    # Return the transaction receipt as the response
    return {"status": "Order Cancelled!!!", "transactionResponse": result}

@app.route('/farmerProcessor/createOffer', methods=['POST'])
def create_offer():
    data = request.get_json()
    order_id = data['orderId']
    production_date = data['productionDate']
    price_per_liter = data['pricePerLiter']
    origin = data['origin']
    creator_address = data['contractAddress']

    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        
        # Retrieve the user with the given account_address
        user = users.find_one({'user_blockchain_address': creator_address})
        if user is not None:
            if user['role'] != 'Farmer':
                return {"status" : "Only Farmer is allowed to use this function"}, 403

    result = contract.functions.createOffer(order_id, production_date, price_per_liter, origin).call({'from': creator_address})
    tx_hash = contract.functions.createOffer(order_id, production_date, price_per_liter, origin).transact({'from': creator_address})
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    return {"status": "Offer Created!!!", "transactionResponse": result}

@app.route('/farmerProcessor/cancelOffer', methods=['POST'])
def cancel_offer():
    data = request.get_json()
    offer_id = data['offerId']
    creator_address = data['contractAddress']

    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        
        # Retrieve the user with the given account_address
        user = users.find_one({'user_blockchain_address': creator_address})
        if user is not None:
            if user['role'] != 'Farmer':
                return {"status" : "Only Farmer is allowed to use this function"}, 403

    result = contract.functions.cancelOffer(offer_id).call({'from': creator_address})
    tx_hash = contract.functions.cancelOffer(offer_id).transact({'from': creator_address})
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    return {"status": "Offer Cancelled!!!", "transactionResponse": result}

@app.route('/farmerProcessor/viewOffers', methods=['GET'])
def view_offers():
    order_id = request.args.get('orderId')
    if not order_id:
        return jsonify({'error': 'Missing orderId parameter'}), 400
    order_id = int(order_id)

    offers = contract.functions.viewOffers(order_id).call()
    return jsonify({'offers': offers}), 200

@app.route('/farmerProcessor/acceptOffer', methods=['POST'])
def accept_offer():
    data = request.get_json()
    order_id = data['orderId']
    offer_id = data['offerId']
    acceptor_address = data['contractAddress']

    client = connect_to_mongodb()
    if client is not None:
        db = client['milk-chain']
        users = db['users']
        
        # Retrieve the user with the given account_address
        user = users.find_one({'user_blockchain_address': acceptor_address})
        if user is not None:
            if user['role'] != 'Processor':
                return {"status" : "Only Processor is allowed to use this function"}, 403

    result = contract.functions.acceptOffer(order_id, offer_id).call({'from': acceptor_address})
    
    tx_hash = contract.functions.acceptOffer(order_id, offer_id).transact({'from': acceptor_address})
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    return {"status": "Offer Accepted!!!", "transactionResponse": result}

@app.route('/farmerProcessor/getAllTransactions', methods=['GET'])
def get_all_transactions():
    transactions = contract.functions.getAllTransactions().call()
    return jsonify({'transactions': transactions}), 200



if __name__ == '__main__':
    app.run(debug=True)
