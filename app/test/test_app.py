import json
import pytest
from app import app, items_collection

@pytest.fixture
def client():
    app.config['TESTING'] = True
    # Clear the collection before each test
    items_collection.delete_many({})
    with app.test_client() as client:
        yield client

def test_home(client):
    res = client.get('/')
    assert res.status_code == 200
    assert b'Lost and Found Management System' in res.data

def test_report_and_get(client):
    payload = {
        "type": "lost",
        "name": "Black Wallet",
        "description": "Leather wallet with ID",
        "location": "Library",
        "date": "2025-10-27",
        "contact": "akash@example.com"
    }
    res = client.post('/report', data=payload)
    assert res.status_code == 302  # redirect after successful post

    res2 = client.get('/items')
    assert res2.status_code == 200
    # Since it's rendering a template, check if the item is in the response
    assert b'Black Wallet' in res2.data

def test_claim_item(client):
    # add another item
    payload = {
        "type": "found",
        "name": "Keys",
        "description": "Keychain",
        "location": "Cafeteria",
        "date": "2025-10-27",
        "contact": "finder@example.com"
    }
    r = client.post('/report', data=payload)
    assert r.status_code == 302  # redirect

    # Get the item from DB
    item = items_collection.find_one({'name': 'Keys'})
    item_id = item['id']
    rc = client.post(f'/items/{item_id}/claim')
    assert rc.status_code == 302  # redirect

    # Check if claimed
    updated_item = items_collection.find_one({'id': item_id})
    assert updated_item['claimed'] == True
