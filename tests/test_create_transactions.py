import pytest
from requests.exceptions import RequestException
from data_generation.create_transactions import create_transaction, create_transfer_transaction
import requests_mock
import os

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

# Base URL of the transactions microservice
BASE_URL = os.getenv("TRANSACTIONS_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

# Mock data for testing
MOCK_ACCOUNT_NUMBER = "123456"
MOCK_AMOUNT = 100
MOCK_METHOD = "ACH"
MOCK_DESCRIPTION = "Test transaction"
MOCK_MEMO = "Test transfer"
MOCK_TRANSACTION_RESPONSE = {"transaction_id": 123}

# Pytest function to test create_transaction function
def test_create_transaction():
    with requests_mock.Mocker() as m:
        # Mocking the POST request
        m.post(f"{BASE_URL}/transactions", json=MOCK_TRANSACTION_RESPONSE, status_code=201)

        # Calling the function under test
        response = create_transaction("credit", MOCK_METHOD, MOCK_AMOUNT, description=MOCK_DESCRIPTION, account_number=MOCK_ACCOUNT_NUMBER)

        # Assertion
        assert response.status_code == 201
        assert response.json() == MOCK_TRANSACTION_RESPONSE

# Pytest function to test create_transfer_transaction function
def test_create_transfer_transaction():
    with requests_mock.Mocker() as m:
        # Mocking the POST request
        m.post(f"{BASE_URL}/transactions/transfer", json=MOCK_TRANSACTION_RESPONSE, status_code=201)

        # Calling the function under test
        response = create_transfer_transaction("123", "456", MOCK_AMOUNT, MOCK_MEMO)

        # Assertion
        assert response.status_code == 201
        assert response.json() == MOCK_TRANSACTION_RESPONSE

# Pytest function to test error handling in create_transaction function
def test_create_transaction_error():
    with requests_mock.Mocker() as m:
        # Mocking the POST request to simulate an error
        m.post(f"{BASE_URL}/transactions", exc=RequestException("Simulated Error"))

        # Calling the function under test
        response = create_transaction("credit", MOCK_METHOD, MOCK_AMOUNT, description=MOCK_DESCRIPTION, account_number=MOCK_ACCOUNT_NUMBER)

        # Assertion
        assert response is None

# Pytest function to test error handling in create_transfer_transaction function
def test_create_transfer_transaction_error():
    with requests_mock.Mocker() as m:
        # Mocking the POST request to simulate an error
        m.post(f"{BASE_URL}/transactions/transfer", exc=RequestException("Simulated Error"))

        # Calling the function under test
        response = create_transfer_transaction("123", "456", MOCK_AMOUNT, MOCK_MEMO)

        # Assertion
        assert response is None