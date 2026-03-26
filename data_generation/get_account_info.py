import requests
import os
from dotenv import load_dotenv
import json
from .colors import colors

# Load environment variables from .env file
load_dotenv()

# Base URL of the user microservice
# Database credentials
BASE_URL = os.getenv("ACCOUNT_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

def get_account_id():
    url = f"{BASE_URL}/accounts"
    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    try:
        # Send a GET request to fetch bank information
        response = requests.get(url, headers=headers)

        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            # Parse the JSON response
            data = response.json()

            # Extract the content part containing bank information
            accounts = data["content"]

            id_dictionary = []
            # Print each individual bank's information neatly
            for account in accounts:
                id_dictionary.append(account['id'])
            return id_dictionary
    except requests.RequestException as e:
        print(colors.RED + "Failed to fetch account information." + colors.RESET)
        return None

def get_account_balance_or_account_by_id(id, wanting):
    url = f"{BASE_URL}/accounts/{id[0]}"
    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    try:
        # Send a GET request to fetch bank information
        response = requests.get(url, headers=headers)
        data = response.json()
        if wanting == "balance" and response.status_code == 200:
            # Parse the JSON response
            balance = data["balance"]
            return balance
        elif wanting == "account" and response.status_code == 200:
            # Parse the JSON response
            account = data["accountNumber"]
            return account
    except requests.RequestException as e:
        print(colors.RED + "Failed to fetch account information. Status code:" + colors.RESET)
        return None