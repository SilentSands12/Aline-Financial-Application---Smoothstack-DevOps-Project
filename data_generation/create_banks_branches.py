import requests
import os
import sys
from dotenv import load_dotenv
from .fake_data_functions import generate_data
from .colors import colors

# Load environment variables from .env file
load_dotenv()

# Base URL of the bank microservice
BASE_URL = os.getenv("BANK_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

# Function to create a new bank
def create_bank(routing_number, address, city, state, zipcode):
    url = f"{BASE_URL}/banks"
    data = {
        "routingNumber": routing_number,
        "address": address,
        "city": city,
        "state": state,
        "zipcode": zipcode
    }

    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    response = requests.post(url, json=data, headers=headers)
    if response.status_code == 201:
        response_json = response.json()
        print(colors.GREEN + f"Bank created successfully. Bank id is {response_json["id"]}" + colors.RESET)
    else:
        print(colors.RED + "Failed to create bank:", response.text + colors.RESET)

    return response

def create_branch(name, address, city, state, zipcode, phone, bank_id):
    url = f"{BASE_URL}/branches"
    data = {
        "name": name,
        "address": address,
        "city": city,
        "state": state,
        "zipcode": zipcode,
        "phone": phone,
        "bankID": bank_id
    }

    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    response = requests.post(url, json=data, headers=headers)
    if response.status_code == 201:
        response_json = response.json()
        print(colors.GREEN + f"Branch created successfully. Branch id is {response_json["id"]}" + colors.RESET)
    else:
        print(colors.RED + "Failed to create branch:", response.text + colors.RESET)

    return response