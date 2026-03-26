import pytest
from requests.exceptions import RequestException
from data_generation.get_account_info import get_account_id, get_account_balance_or_account_by_id
import requests_mock
import os

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

# Base URL of the account microservice
BASE_URL = os.getenv("ACCOUNT_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

# Mock data for testing
MOCK_ACCOUNT_ID = [123, 456]
MOCK_BALANCE_DATA = {"balance": 1000}
MOCK_ACCOUNT_DATA = {"accountNumber": "123456"}

# Pytest function to test get_account_id function
def test_get_account_id():
    with requests_mock.Mocker() as m:
        # Mocking the GET request
        m.get(f"{BASE_URL}/accounts", json={"content": [{"id": id} for id in MOCK_ACCOUNT_ID]}, status_code=200)

        # Calling the function under test
        account_ids = get_account_id()

        # Assertion
        assert account_ids == MOCK_ACCOUNT_ID

# Pytest function to test get_account_balance_or_account_by_id function for balance
def test_get_account_balance():
    with requests_mock.Mocker() as m:
        # Mocking the GET request
        m.get(f"{BASE_URL}/accounts/{MOCK_ACCOUNT_ID[0]}", json=MOCK_BALANCE_DATA, status_code=200)

        # Calling the function under test
        balance = get_account_balance_or_account_by_id(MOCK_ACCOUNT_ID, wanting="balance")

        # Assertion
        assert balance == MOCK_BALANCE_DATA["balance"]

# Pytest function to test get_account_balance_or_account_by_id function for account number
def test_get_account_number():
    with requests_mock.Mocker() as m:
        # Mocking the GET request
        m.get(f"{BASE_URL}/accounts/{MOCK_ACCOUNT_ID[0]}", json=MOCK_ACCOUNT_DATA, status_code=200)

        # Calling the function under test
        account_number = get_account_balance_or_account_by_id(MOCK_ACCOUNT_ID, wanting="account")

        # Assertion
        assert account_number == MOCK_ACCOUNT_DATA["accountNumber"]

# Pytest function to test error handling in get_account_id function
def test_get_account_id_error():
    with requests_mock.Mocker() as m:
        # Mocking the GET request to simulate an error
        m.get(f"{BASE_URL}/accounts", exc=RequestException("Simulated Error"))

        # Calling the function under test
        account_ids = get_account_id()

        # Assertion
        assert account_ids is None

# Pytest function to test error handling in get_account_balance_or_account_by_id function
def test_get_account_error():
    with requests_mock.Mocker() as m:
        # Mocking the GET request to simulate an error
        m.get(f"{BASE_URL}/accounts/{MOCK_ACCOUNT_ID[0]}", exc=RequestException("Simulated Error"))

        # Calling the function under test
        balance = get_account_balance_or_account_by_id(MOCK_ACCOUNT_ID, wanting="balance")

        # Assertion
        assert balance is None