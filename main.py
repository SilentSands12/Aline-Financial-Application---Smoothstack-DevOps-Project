from data_generation.user_creation import *
from data_generation.database_connection.database_query import database_query
from data_generation.create_applications import *
from data_generation.fake_data_functions import *
from data_generation.create_banks_branches import *
from data_generation.colors import colors
from data_generation.create_transactions import *

# Usage statement
if __name__ == "__main__":
    exit = 'Y'
    while exit == 'Y':
        print(colors.WHITE + "-------------------- Functions Content Table --------------------" + colors.RESET)
        print(colors.GREEN + "1: User Creations (Admin or Member)" + colors.RESET)
        print(colors.MAGENTA + "2: Application Creation (Includes member and applicant creation)" + colors.RESET)
        print(colors.YELLOW + "3: Bank & Branch Creation" + colors.RESET)
        print(colors.BLUE + "4: Database Connection" + colors.RESET)
        print(colors.CYAN + "5: Create Transactions" + colors.RESET)
        print(colors.RED + "6: Exit Prompt" + colors.RESET)
        print(colors.WHITE + "-----------------------------------------------------------------\n" + colors.RESET)

        while True:
            try:
                decision_execution_choice = int(input(colors.YELLOW+"Please enter the number for the function to run. (1-6): "+ colors.RESET))
                if 1 <= decision_execution_choice <= 6:
                    break  # Exit the loop if the input is valid
                else:
                    print("Input must be a number from 1 to 6.")
            except ValueError:
                print("Input must be an integer.")

        if decision_execution_choice == 1:
            # Generate data
            data = generate_data('user')

            if data["role"] == 'admin':
                create_user(data["username"], data["password"], data["role"],
                            first_name=data["first_name"], last_name=data["last_name"],
                            email=data["email"], phone=data["phone"])
            elif data["role"] == 'member':
                create_user(data["username"], data["password"], data["role"],
                            membershipId=data["membershipId"], lastFourOfSSN=data["lastFourOfSSN"])
            else:
                print("Bad input.")

        elif decision_execution_choice == 2:
            # Generate application data
            app_data = generate_data('application')

            # Create application using generated data
            create_applications(
                app_data["applicationType"],
                app_data["noNewApplicants"],
                app_data["applicantIds"],
                applicants=app_data["applicants"],
                application_amount=app_data["applicationAmount"],
                card_offer_id=app_data["cardOfferId"],
                deposit_account_number=app_data["depositAccountNumber"]
            )
        elif decision_execution_choice == 3:

            bank_or_branch = input(colors.YELLOW + "Will you be creating a bank or branch? " + colors.RESET).lower()
            if bank_or_branch == 'bank':
                # Generate bank data and create bank
                bank_data = generate_data('bank')

                # Create application using generated data
                create_bank(
                    bank_data["routingNumber"],
                    bank_data["address"],
                    bank_data["city"],
                    bank_data["state"],
                    bank_data["zipcode"]
                )
            elif bank_or_branch == 'branch':
                # Generate bank data and create bank
                branch_data = generate_data('branch')

                # Create application using generated data
                create_branch(
                    branch_data["name"],
                    branch_data["address"],
                    branch_data["city"],
                    branch_data["state"],
                    branch_data["zipcode"],
                    branch_data["phone"],
                    branch_data["bankID"]
                )
            else:
                print(colors.RED + "Ooops wrong entry. Redirecting to main prompt." + colors.RESET)

        elif decision_execution_choice == 4:
            # Connects to database and query tables
            database_query()
        elif decision_execution_choice == 5:
            # Will generate a transaction
                # Generate bank data and create bank
                transaction_data = generate_data('transaction')

                if transaction_data["transfer"] == "True":
                     create_transfer_transaction(
                        transaction_data["fromAccountNumber"],
                        transaction_data["toAccountNumber"],
                        transaction_data["amount"],
                        transaction_data["memo"],
                     )
                elif transaction_data["transfer"] == "False":
                     create_transaction(
                         transaction_data["type"],
                         transaction_data["method"],
                         transaction_data["amount"],
                         transaction_data["merchantCode"],
                         transaction_data["merchantName"],
                         transaction_data["description"],
                         transaction_data["accountNumber"],
                         transaction_data["hold"]
                     )
                else:
                    print(colors.RED + "Ooops wrong entry. Redirecting to main prompt." + colors.RESET)
        elif decision_execution_choice == 6:
            # Will exit prompt if choosen
            break
        else:
            print("Error detected. Oops...")

        # Give loop instructions to keep on using main.py file or not
        exit = input(str(colors.YELLOW + "Would you like to use another function? (y/n options) " + colors.RESET)).upper()
        if exit.upper() == 'YES':
            exit = 'Y'
        print('\n')