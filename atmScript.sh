#!/bin/bash

# File to store customer data
customer_file="customerDatabase.txt"
# File to store transaction history
transaction_file="transactionDatabase.txt"

# Function to initialize customer data file
initialize_customer_file() {
    touch "$customer_file"
}

# Function to initialize transaction history file
initialize_transaction_file() {
    touch "$transaction_file"
}

# Function to check if user ID already exists
user_id_exists() {
    user_id=$1
    if grep -q "^$user_id," "$customer_file"; then
        return 0
    else
        return 1
    fi
}

# Function to sign up
sign_up() {
    user_id=$(zenity --entry --title="Sign Up" --text="Enter your user ID:")
    if [ -z "$user_id" ]; then
        zenity --error --title="Error" --text="User ID cannot be empty!"
        return
    fi

    if user_id_exists "$user_id"; then
        zenity --error --title="Error" --text="User ID already exists! Please choose a different one."
        return
    fi

    password=$(zenity --password --title="Sign Up" --text="Enter your password:")
    if [ -z "$password" ]; then
        zenity --error --title="Error" --text="Password cannot be empty!"
        return
    fi

    name=$(zenity --entry --title="Sign Up" --text="Enter your full name:")
    if [ -z "$name" ]; then
        zenity --error --title="Error" --text="Name cannot be empty!"
        return
    fi

    echo "$user_id,$name,0,$password" >> "$customer_file"
    zenity --info --title="Sign Up" --text="Account created successfully!"
}

# Function to log in
log_in() {
    user_id=$(zenity --entry --title="Login" --text="Enter your user ID:")
    password=$(zenity --password --title="Login" --text="Enter your password:")
    while IFS=, read -r acc_num name balance pass; do
        if [ "$acc_num" == "$user_id" ] && [ "$pass" == "$password" ]; then
            account_number=$user_id
            account_name=$name
            return 0
        fi
    done < "$customer_file"
    return 1
}

# Function to read customer data
read_customer_data() {
    while IFS=, read -r acc_num name balance pass; do
        if [ "$acc_num" == "$1" ]; then
            customer_data="$name,$balance,$pass"
            break
        fi
    done < "$customer_file"
}

# Function to display balance
display_balance() {
    read_customer_data "$1"
    if [ -n "$customer_data" ]; then
        balance=$(echo "$customer_data" | cut -d ',' -f 2)
        zenity --info --title="Balance" --text="Name: $(echo "$customer_data" | cut -d ',' -f 1)\nBalance: Rs. $balance"
    else
        zenity --error --title="Error" --text="Invalid account number!"
    fi
}

# Function to deposit money
deposit() {
    read_customer_data "$1"
    if [ -n "$customer_data" ]; then
        balance=$(echo "$customer_data" | cut -d ',' -f 2)
        amount=$(zenity --entry --title="Deposit" --text="Enter amount to deposit:")
        if [[ $amount =~ ^[0-9]+$ ]]; then
            new_balance=$((balance + amount))
            # Update customer file with new balance
            awk -v acc_num="$1" -v new_bal="$new_balance" 'BEGIN{FS=OFS=","} $1 == acc_num {$3=new_bal} 1' "$customer_file" > temp && mv temp "$customer_file"
            echo "$(date '+%Y-%m-%d %H:%M:%S'),Deposit,$amount,$1" >> "$transaction_file"
            zenity --info --title="Deposit" --text="Rs. $amount deposited successfully."
        else
            zenity --error --title="Error" --text="Invalid amount entered!"
        fi
    else
        zenity --error --title="Error" --text="Invalid account number!"
    fi
}

# Function to withdraw money
withdraw() {
    read_customer_data "$1"
    if [ -n "$customer_data" ]; then
        balance=$(echo "$customer_data" | cut -d ',' -f 2)
        amount=$(zenity --entry --title="Withdraw" --text="Enter amount to withdraw:")
        if [[ $amount =~ ^[0-9]+$ ]]; then
            if [ $amount -le $balance ]; then
                new_balance=$((balance - amount))
                # Update customer file with new balance
                awk -v acc_num="$1" -v new_bal="$new_balance" 'BEGIN{FS=OFS=","} $1 == acc_num {$3=new_bal} 1' "$customer_file" > temp && mv temp "$customer_file"
                echo "$(date '+%Y-%m-%d %H:%M:%S'),Withdraw,$amount,$1" >> "$transaction_file"
                zenity --info --title="Withdraw" --text="Rs. $amount withdrawn successfully."
            else
                zenity --error --title="Error" --text="Insufficient funds in your account."
            fi
        else
            zenity --error --title="Error" --text="Invalid amount entered!"
        fi
    else
        zenity --error --title="Error" --text="Invalid account number!"
    fi
}


# Function to display transaction history
display_transaction_history() {
    if [ -z "$account_number" ]; then
        zenity --error --title="Error" --text="No user logged in!"
        return
    fi

    date_selected=$(zenity --calendar --title="Select Date" --text="Select the date to view transactions" --date-format="%Y-%m-%d" --window-icon=info)
    if [ -n "$date_selected" ]; then
        transactions=$(awk -v date="$date_selected" -v acc_num="$account_number" -F ',' '$1 ~ date && $4 == acc_num' "$transaction_file" | zenity --text-info --title="Transaction History" --width=600 --height=300)
        if [ -z "$transactions" ]; then
            zenity --info --title="Transaction History" --text="No transactions found for the selected date."
        fi
    fi
}



# Main menu
while true; do
    choice=$(zenity --list --title="ATM Simulator" --column="Options" "Sign Up" "Log In" "Exit")
    case $choice in
        "Sign Up")
            sign_up
            ;;
        "Log In")
            log_in
            if [ $? -eq 0 ]; then
                while true; do
                    action=$(zenity --list --title="ATM Simulator" --column="Options" "Display Balance" "Deposit" "Withdraw" "Transaction History" "Exit")
                    case $action in
                        "Display Balance")
                            display_balance "$account_number"
                            ;;
                        "Deposit")
                            deposit "$account_number"
                            ;;
                        "Withdraw")
                            withdraw "$account_number"
                            ;;
                        "Transaction History")
                            display_transaction_history
                            ;;
                        "Exit")
                            break
                            ;;
                        *)
                            zenity --error --title="Error" --text="Invalid option!"
                            ;;
                    esac
                done
            fi
            ;;
        "Exit")
            zenity --info --title="Exit" --text="Thank you for using ATM Simulator."
            exit
            ;;
        *)
            zenity --error --title="Error" --text="Invalid option!"
            ;;
    esac
done
