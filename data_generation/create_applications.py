import requests
import os
import sys
from dotenv import load_dotenv
from .colors import colors

# Load environment variables from .env file
load_dotenv()

# Base URL of the user microservice
# Database credentials
BASE_URL = os.getenv("APPLICATION_BASE_URL")
BEARER_TOKEN = os.getenv("BEARER_TOKEN")

# Example function to create applications which then creates a member and an applicant
def create_applications(application_type, no_new_applicants, applicant_ids, **kwargs):
    url = f"{BASE_URL}/applications"

    # Construct application data
    app_data = {
        "applicationType": application_type,
        "noNewApplicants": no_new_applicants,
        "applicantIds": applicant_ids,
        "applicants": kwargs.get("applicants", []),
        "applicationAmount": kwargs.get("application_amount"),
        "cardOfferId": kwargs.get("card_offer_id"),
        "depositAccountNumber": kwargs.get("deposit_account_number")
    }

    last_four_of_ssn = ''.join(app_data["applicants"][0].get("socialSecurity")).replace('-','')[5::]

        # Open different file during pytest runs
    if 'pytest' in sys.modules:
        file_path = "tests/application_generated_details_pytest.txt"
    else:
        file_path = "data_generation/application_generated_details.txt"

    headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
    response = requests.post(url, json=app_data, headers=headers)
    if response.status_code == 201:
        response_json = response.json()
        application_id = response_json["id"]
        if response_json["status"] == "APPROVED":
            membership_id = response_json["createdMembers"][0].get("membershipId")
            name = response_json["createdMembers"][0].get("name")
            print(colors.GREEN + f"Application with id {application_id} was created for member {name} and approved! Membership_id is {membership_id} Congrats!" + colors.RESET)
            # Code to open a text file and append to it user created details
            with open(file_path, "a") as file:
                file.write(f"Name: {name} | Last_four_of_SSN: {last_four_of_ssn} | membershipId: {membership_id}\n")
        else:
            print(colors.MAGENTA + f"Application with id {application_id} was created but not approved. Reason: {response_json["reasons"]}" + colors.RESET)
    else:
        print(colors.RED + "\nFailed to create application:", response.text, response.status_code + colors.RESET)

    return response
