import pytest
import requests_mock
from data_generation.create_banks_branches import *

MOCK_DATA_BANK= {
    "routing_number": "123456789",
    "address": "123 Main St!",
    "city": "New York",
    "state": "NY",
    "zipcode": "10001",
}

# Fixture for mocking the POST requests
@pytest.fixture
def mock_bank_creation():
    with requests_mock.Mocker() as m:
        yield m

# Test function for creating a bank
def test_create_bank(mock_bank_creation):
    mock_response_json = {"id": 1}
    mock_bank_creation.post("http://localhost:8083/banks", json=mock_response_json, status_code=201)

    # Call the function to create a bank
    # response = create_bank(routing_number="123456789", address="123 Main St", city="New York", state="NY", zipcode="10001")
    response = create_bank(**MOCK_DATA_BANK)

    # Assert the response or any other behavior
    assert response.status_code == 201
    assert response.json()["id"] is not None

# Test function for creating a branch
def test_create_branch(mock_bank_creation):
    mock_response_json = {"id": 1}
    mock_bank_creation.post("http://localhost:8083/branches", json=mock_response_json, status_code=201)

    # Call the function to create a branch
    response = create_branch(name="Branch A", address="456 Elm St", city="Los Angeles", state="CA", zipcode="90001", phone="123-456-7890", bank_id=1)
    assert response.status_code == 201
    assert response.json()["id"] is not None
