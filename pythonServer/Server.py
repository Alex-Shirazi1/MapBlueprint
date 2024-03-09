from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from bson.json_util import dumps

app = Flask(__name__)

app.config["MONGO_URI"] = "mongodb://localhost:27017/mapBlueprint-database"

mongo = PyMongo(app)

@app.route('/')
def home():
    return 'Hello, World!'


@app.route('/saveVehicleData', methods=['POST'])
def store_data():
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    # Ensure there's an Id here
    if '_id' not in data:
        return jsonify({"error": "vehicleId is required"}), 400

    vehicle_id = data['_id']
    collection = mongo.db.vehicle_data

    collection.update_one({'_id': vehicle_id}, {"$set": data}, upsert=True)

    return jsonify({"success": "Data updated successfully"}), 200

@app.route('/getVehicleData/<id>', methods=['GET'])
def get_vehicle_data(id):
    collection = mongo.db.vehicle_data
    try:
        data = collection.find_one({'_id': id})
    except Exception as e:
        return jsonify({"error": "Invalid _id format"}), 400

    if data:
        return dumps(data), 200
    else:
        return jsonify({"error": "No data found with the given _id"}), 404


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5050)
