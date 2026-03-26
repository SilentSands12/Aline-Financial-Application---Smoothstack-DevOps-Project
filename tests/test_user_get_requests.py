import pytest
from requests.exceptions import RequestException
from data_generation.user_get_requests import get_user_by_id, get_users
import requests_mock
import os

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

# Base URL of the user microservice
BASE_URL = os.getenv("USER_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

# Mock data for testing
MOCK_USER_ID = 123
MOCK_USER_DATA = {"id": 123, "name": "Test User"}

# Pytest function to test get_user_by_id function
def test_get_user_by_id():
    with requests_mock.Mocker() as m:
        # Mocking the GET request
        m.get(f"{BASE_URL}/users/{MOCK_USER_ID}", json=MOCK_USER_DATA, status_code=200)

        # Calling the function under test
        user_info = get_user_by_id(MOCK_USER_ID)

        # Assertion
        assert user_info == MOCK_USER_DATA

# Pytest function to test get_users function
def test_get_users():
    with requests_mock.Mocker() as m:
        # Mocking the GET request
        m.get(f"{BASE_URL}/users", json=[MOCK_USER_DATA], status_code=200)

        # Calling the function under test
        users_info = get_users()

        # Assertion
        assert users_info == [MOCK_USER_DATA]

# Pytest function to test error handling in get_user_by_id function
def test_get_user_by_id_error():
    with requests_mock.Mocker() as m:
        # Mocking the GET request to simulate an error
        m.get(f"{BASE_URL}/users/{MOCK_USER_ID}", exc=RequestException("Simulated Error"))

        # Calling the function under test
        user_info = get_user_by_id(MOCK_USER_ID)

        # Assertion
        assert user_info is None

# Pytest function to test error handling in get_users function
def test_get_users_error():
    with requests_mock.Mocker() as m:
        # Mocking the GET request to simulate an error
        m.get(f"{BASE_URL}/users", exc=RequestException("Simulated Error"))

        # Calling the function under test
        users_info = get_users()

        # Assertion
        assert users_info is None