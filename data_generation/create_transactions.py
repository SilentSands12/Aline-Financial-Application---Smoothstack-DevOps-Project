import requests
import os
from dotenv import load_dotenv
from datetime import datetime

# Load environment variables from .env file
load_dotenv()

# Base URL of the transactions microservice
BASE_URL = os.getenv("TRANSACTIONS_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

# Example function to create a new transaction
def create_transaction(type, method, amount, merchant_code=None, merchant_name=None, description=None, account_number=None, hold=False):
    url = f"{BASE_URL}/transactions"
    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    try:
        transaction_data = {
                "type": type,
                "method": method,
                "date": datetime.now().isoformat(),
                "amount": amount,
                "merchantCode": merchant_code,
                "merchantName": merchant_name,
                "description": description,
                "cardRequest": None,
                "accountNumber": account_number,
                "hold": hold
        }
        response = requests.post(url, json=transaction_data, headers=headers)
        print(f"{type} transaction was made to account {account_number} for an amount of {amount}")
        return response
    except requests.RequestException as e:
        return None


# Function to create a transfer transaction
def create_transfer_transaction(from_account_number, to_account_number, amount, memo):
    url = f"{BASE_URL}/transactions/transfer"
    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    try:
        transaction_data = {
            "fromAccountNumber": from_account_number,
            "toAccountNumber": to_account_number,
            "amount": amount,
            "memo": memo,
            "date": datetime.now().isoformat()
        }
        response = requests.post(url, json=transaction_data, headers=headers)
        print(f"A transfer was made to account {to_account_number} from account {from_account_number} for an amount of {amount}")
        return response
    except requests.RequestException as e:
        return None