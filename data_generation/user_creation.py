import requests
import re
import os
import sys
from dotenv import load_dotenv
from .colors import colors

# Load environment variables from .env file
load_dotenv()

# Base URL of the user microservice
# Database credentials
BASE_URL = os.getenv("USER_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

# Example function to create a new user registration
def create_user(username, password, role, **kwargs):
    url = f"{BASE_URL}/users/registration"
    if role == "member":
        data = {
            "username": username,
            "password": password,
            "role": role,
            "membershipId": kwargs.get("membershipId"),
            "lastFourOfSSN": kwargs.get("lastFourOfSSN")
        }
    elif role == "admin":
        data = {
            "username": username,
            "password": password,
            "role": role,
            "firstName": kwargs.get("first_name"),
            "lastName": kwargs.get("last_name"),
            "email": kwargs.get("email"),
            "phone": kwargs.get("phone")
        }
    else:
        raise ValueError("Invalid role specified. Must be 'member' or 'admin'.")

    # Open different file during pytest runs
    if 'pytest' in sys.modules:
        file_path = "tests/user_generated_details_pytest.txt"
    else:
        file_path = "data_generation/user_generated_details.txt"

    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    response = requests.post(url, json=data, headers=headers)
    if response.status_code == 201 or response.status_code == 422:
        print(colors.GREEN + f"{role} user with username: {username} has been successfully created." + colors.RESET)

        # Code to open a text file and append to it user created details
        with open(file_path, "a") as file:
            file.write(f"Username: {username}, Role: {role}, Password: {password}\n")
    else:
        print(username, password)
        print(colors.RED + "Failed to register user:", response.text + colors.RESET)

    return response