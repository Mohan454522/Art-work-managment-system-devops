from flask import Flask, request, jsonify, abort, render_template, redirect, url_for
from pymongo import MongoClient
import os

app = Flask(__name__)

# MongoDB connection
client = MongoClient('mongodb://localhost:27017/')
db = client['lost_and_found']
items_collection = db['items']

# item schema example:
# {
#   "id": 1,
#   "type": "lost" or "found",
#   "name": "Black Wallet",
#   "description": "leather, many cards",
#   "location": "Library",
#   "date": "2025-10-27",
#   "contact": "akash@example.com",
#   "claimed": False
# }

def _validate_item(data):
    required = ["type", "name", "description", "location", "date", "contact"]
    return all(k in data for k in required)

@app.route('/', methods=['GET'])
def home():
    return render_template('index.html')

@app.route('/report', methods=['GET', 'POST'])
def report_item():
    if request.method == 'POST':
        data = request.form.to_dict()
        if not data or not _validate_item(data):
            return render_template('report.html', error="Invalid payload. required: type,name,description,location,date,contact")
        # Get the next ID
        last_item = items_collection.find_one(sort=[("id", -1)])
        new_id = (last_item['id'] + 1) if last_item else 1
        data['id'] = new_id
        data['claimed'] = False
        items_collection.insert_one(data)
        return redirect(url_for('get_items'))
    return render_template('report.html')

@app.route('/items', methods=['GET'])
def get_items():
    # optionally filter by type or location via query params
    item_type = request.args.get('type')
    location = request.args.get('location')
    query = {}
    if item_type:
        query['type'] = item_type
    if location:
        query['location'] = {'$regex': location, '$options': 'i'}
    results = list(items_collection.find(query))
    return render_template('items.html', items=results)

@app.route('/items/<int:item_id>', methods=['GET'])
def get_item(item_id):
    item = items_collection.find_one({'id': item_id})
    if item:
        return jsonify(item), 200
    abort(404, description="Item not found")

@app.route('/items/<int:item_id>/claim', methods=['POST'])
def claim_item(item_id):
    # mark item as claimed (simple logic)
    result = items_collection.update_one({'id': item_id}, {'$set': {'claimed': True}})
    if result.matched_count > 0:
        return redirect(url_for('get_items'))
    abort(404, description="Item not found")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
