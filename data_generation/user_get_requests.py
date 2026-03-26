import requests
import os
from dotenv import load_dotenv
import json

# Load environment variables from .env file
load_dotenv()

# Base URL of the user microservice
# Database credentials
BASE_URL = os.getenv("USER_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

class UserAPIException(Exception):
    pass

# Example function to get a user profile by ID
def get_user_by_id(user_id):
    url = f"{BASE_URL}/users/{user_id}"
    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()  # Raise exception for non-200 status codes
        user_info = response.json()
        return user_info
    except requests.RequestException as e:
        return None

def get_users():
    url = f"{BASE_URL}/users"
    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()  # Raise exception for non-200 status codes
        user_info = response.json()
        return user_info
    except requests.RequestException as e:
        return None