import pytest
from requests.exceptions import RequestException
from data_generation.get_bank_branches_info import get_bank_information
import requests_mock
from data_generation.colors import colors

# Mock data for testing
MOCK_BANK_DATA = {
    "content": [
        {
            "id": 1,
            "routingNumber": "123456789",
            "address": "123 Main St",
            "city": "Example City",
            "state": "CA",
            "zipcode": "12345"
        },
        {
            "id": 2,
            "routingNumber": "987654321",
            "address": "456 Oak St",
            "city": "Another City",
            "state": "NY",
            "zipcode": "54321"
        }
    ]
}

# Pytest function to test get_bank_information function
def test_get_bank_information_success(capfd):
    with requests_mock.Mocker() as m:
        # Mocking the GET request
        m.get("http://localhost:8083/banks", json=MOCK_BANK_DATA, status_code=200)

        # Calling the function under test
        get_bank_information()

        # Capture printed output
        captured = capfd.readouterr()

        # Expected output
        expected_output = (
            f"{colors.CYAN}Bank ID: 1{colors.RESET}\nRouting Number: 123456789\nAddress: 123 Main St\nCity: Example City\nState: CA\nZipcode: 12345\n{'-' * 30}\n"
            f"{colors.CYAN}Bank ID: 2{colors.RESET}\nRouting Number: 987654321\nAddress: 456 Oak St\nCity: Another City\nState: NY\nZipcode: 54321\n{'-' * 30}\n"
        )

        # Assertion
        assert captured.out == expected_output

# Pytest function to test error handling in get_bank_information function
def test_get_bank_information_error(capfd):
    with requests_mock.Mocker() as m:
        # Mocking the GET request to simulate an error
        m.get("http://localhost:8083/banks", exc=RequestException("Simulated Error"))

        # Calling the function under test
        get_bank_information()

        # Capture printed output
        captured = capfd.readouterr()

        # Expected output
        expected_output = f"{colors.RED}Failed to fetch bank information.{colors.RESET}\n"

        # Assertion
        assert captured.out == expected_output