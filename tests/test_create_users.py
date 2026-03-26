import pytest
from data_generation.user_creation import create_user
import requests_mock

# Mock data for testing
MOCK_DATA_MEMBER = {
    "username": "test_user",
    "password": "Password123!",
    "role": "member",
    "membership_id": "06727470",
    "last_four_of_ssn": "0987"
}

MOCK_DATA_ADMIN = {
    "username": "admin_user_test2",
    "password": "AdminPassword123!",
    "role": "admin",
    "first_name": "AdminTest",
    "last_name": "UserTest",
    "email": "admin_test2@example.com",
    "phone": "321-456-7890"
}

# Pytest function to test create_user function for admin role
def test_create_admin_user():
    with requests_mock.Mocker() as m:
        m.post("http://localhost:8070/users/registration", json={"id": 1}, status_code=201)
        response = create_user(**MOCK_DATA_ADMIN)
        assert response.status_code == 201
        assert response.json()["id"] == 1

# Pytest function to test create_user function for member role
def test_create_member_user():
    with requests_mock.Mocker() as m:
        m.post("http://localhost:8070/users/registration", json={"id": 2}, status_code=201)
        response = create_user(**MOCK_DATA_MEMBER)
        assert response.status_code == 201
        assert response.json()["id"] == 2

# Pytest function to test if create_user function raises ValueError for invalid role
def test_invalid_role():
    with pytest.raises(ValueError):
        create_user(username="test", password="Password123!", role="invalid_role")