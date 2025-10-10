#!/bin/bash

# Function to read password with asterisks
read_password() {
    local prompt="$1"
    local password=""
    local char
    
    echo -n "$prompt"
    
    # Disable terminal echo
    stty -echo
    
    while true; do
        # Read one character at a time
        IFS= read -r -k 1 char 2>/dev/null || IFS= read -r -n 1 char
        
        # Break on Enter (newline)
        if [[ $char == $'\n' ]] || [[ $char == $'\r' ]] || [[ -z $char ]]; then
            break
        fi
        
        # Handle backspace/delete
        if [[ $char == $'\x7f' ]] || [[ $char == $'\x08' ]]; then
            if [[ -n $password ]]; then
                password="${password%?}"
                echo -ne '\b \b'
            fi
        else
            password+="$char"
            echo -n '*'
        fi
    done
    
    # Re-enable terminal echo
    stty echo
    echo ""
    
    # Return the password via the variable name passed as second argument
    eval "$2='$password'"
}

# Prompt user for their Databricks' host URL
echo -n "Enter your Databricks host URL: "
read DATABRICKS_HOST

# Prompt user for their Databricks' token (input hidden for security)
read_password "Enter your Databricks token: " DATABRICKS_TOKEN

# Prompt user for their Databricks account ID
echo -n "Enter your Databricks account ID (for account-level operations): "
read DATABRICKS_ACCOUNT_ID

# Set environment variables
export DATABRICKS_HOST="$DATABRICKS_HOST"
export DATABRICKS_TOKEN="$DATABRICKS_TOKEN"
export DATABRICKS_ACCOUNT_ID="$DATABRICKS_ACCOUNT_ID"

# Copy the Databricks Host and Token to TF_VAR_ environment variables for Terraform
export TF_VAR_databricks_host="$DATABRICKS_HOST"
export TF_VAR_databricks_token="$DATABRICKS_TOKEN"

# Show that they are set (don’t usually print passwords in real scripts!)
echo "Databricks host is set to: $DATABRICKS_HOST"
echo "Databricks token has been captured and stored in DATABRICKS_TOKEN (not displayed)"
echo "Databricks account ID is set to: $DATABRICKS_ACCOUNT_ID"
echo "Environment variables have been set. You can now run Terraform commands."