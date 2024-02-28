# Bash ATM Simulator

This is a simple ATM simulator written in Bash script. It allows users to sign up for new accounts, log in, perform various banking operations such as checking balance, depositing, and withdrawing money, and view transaction history within a specified date range.

## Features

- **Sign Up**: Users can create new accounts by providing a unique user ID, password, and full name.
- **Log In**: Registered users can log in using their user ID and password.
- **Account Operations**:
  - **Display Balance**: Users can check their account balance.
  - **Deposit**: Users can deposit money into their account.
  - **Withdraw**: Users can withdraw money from their account.
- **Transaction History**: Users can view their transaction history within a specified date range.
- **Error Handling**: The script provides error messages for invalid input or other errors using Zenity.

## Files

- `customerDatabase.txt`: Stores customer data including user ID, name, balance, and password.
- `transactionDatabase.txt`: Stores transaction history including timestamp, transaction type, amount, and user ID.

## Usage

1. Ensure you have Bash installed on your system.
2. Run the script using the command `./atm_simulator.sh`.
3. Follow the on-screen prompts to perform various banking operations.

## Dependencies

- `zenity`: A program for creating simple graphical user interfaces in Bash scripts.

## Notes

- Make sure to protect the customer and transaction database files (`customerDatabase.txt` and `transactionDatabase.txt`) to prevent unauthorized access.
- This script is for educational purposes only and may require further enhancements for real-world use cases such as robust security measures, error handling, and scalability.

## License

This project is licensed under the [MIT License](LICENSE).
