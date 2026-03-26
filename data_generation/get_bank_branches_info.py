import requests
from .colors import colors

def get_bank_information():
    try:
        # Send a GET request to fetch bank information
        response = requests.get("http://localhost:8083/banks")

        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            # Parse the JSON response
            data = response.json()

            # Extract the content part containing bank information
            banks = data["content"]

            # Print each individual bank's information neatly
            for bank in banks:
                print(colors.CYAN + f"Bank ID: {bank['id']}" + colors.RESET)
                print(f"Routing Number: {bank['routingNumber']}")
                print(f"Address: {bank['address']}")
                print(f"City: {bank['city']}")
                print(f"State: {bank['state']}")
                print(f"Zipcode: {bank['zipcode']}")
                print("-" * 30)  # Add a separator for better readability
    except requests.RequestException as e:
        print(colors.RED + "Failed to fetch bank information." + colors.RESET)
        return None
