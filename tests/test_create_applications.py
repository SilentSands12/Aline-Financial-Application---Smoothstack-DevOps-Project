import pytest
from data_generation.create_applications import create_applications
import requests_mock

# Mock data for testing
MOCK_DATA_APPLICATION_1 = {
    "applicationType": "CHECKING",
    "noNewApplicants": "false",
    "applicantIds": [],
    "applicants": [{
        "firstName": "testing",
        "middleName": "pytest",
        "lastName": "results",
        "dateOfBirth": "1990-01-31",
        "gender": "MALE",
        "email": "testingpytest882@pytest.com",
        "phone": "111-111-2889",
        "socialSecurity": "111-22-2889",
        "driversLicense": "11112889",
        "income": "50000",
        "address": "289 Sunrise Road",
        "city": "Tyler",
        "state": "Texas",
        "zipcode": "75634",
        "mailingAddress": "289 Sunrise Road",
        "mailingCity": "Tyler",
        "mailingState": "Texas",
        "mailingZipcode": "75634"
    }],
    "applicationAmount": 10000,
    "cardOfferId": 1,
    "depositAccountNumber": "1111122222"
}

# Pytest function to test create_applicant_and_application
def test_create_applicant_and_application():
    with requests_mock.Mocker() as m:
        m.post("http://localhost:8071/applications", json={"id": 1, "applicants": [{"id": 1}], "status":"APPROVED",
                "createdMembers": [{"membershipId": "82712587", "name": "testing results"}]}, status_code=201)
            # Create application
        response = create_applications(
            application_type=MOCK_DATA_APPLICATION_1["applicationType"],
            no_new_applicants=MOCK_DATA_APPLICATION_1["noNewApplicants"],
            applicant_ids=MOCK_DATA_APPLICATION_1["applicantIds"],
            **MOCK_DATA_APPLICATION_1
        )
        assert response.status_code == 201
        assert response.json()["id"] == 1
        assert response.json()["applicants"][0]["id"] == 1