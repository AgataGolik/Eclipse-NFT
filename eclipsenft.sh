#!/bin/bash

curl -s https://raw.githubusercontent.com/zunxbt/logo/main/logo.sh | bash
sleep 3

# Function to display messages
show() {
    echo -e "\e[32m$1\e[0m"  # Green colored message
}

mkdir -p Eclipse && cd Eclipse

# ... (previous functions remain unchanged)

# Modified setup_wallet function
setup_wallet() {
    KEYPAIR_DIR="$HOME/solana_keypairs"
    mkdir -p "$KEYPAIR_DIR"

    show "Do you want to use an existing private key or enter a new one?"
    PS3="Please enter your choice (1 or 2): "
    options=("Use existing private key" "Enter new private key")
    select opt in "${options[@]}"; do
        case $opt in
            "Use existing private key")
                show "Enter the path to your existing private key file:"
                read -p "> " PRIVATE_KEY_PATH
                if [ ! -f "$PRIVATE_KEY_PATH" ]; then
                    show "File not found. Exiting."
                    exit 1
                fi
                KEYPAIR_PATH="$KEYPAIR_DIR/eclipse-wallet.json"
                cp "$PRIVATE_KEY_PATH" "$KEYPAIR_PATH"
                break
                ;;
            "Enter new private key")
                show "Enter your private key (base58 or array format):"
                read -p "> " PRIVATE_KEY
                KEYPAIR_PATH="$KEYPAIR_DIR/eclipse-wallet.json"
                if [[ $PRIVATE_KEY == \[* ]]; then
                    # Array format
                    echo "[${PRIVATE_KEY:1:-1}]" > "$KEYPAIR_PATH"
                else
                    # Base58 format
                    echo "[$PRIVATE_KEY]" > "$KEYPAIR_PATH"
                fi
                break
                ;;
            *) show "Invalid option. Please try again." ;;
        esac
    done

    solana config set --keypair "$KEYPAIR_PATH"
    show "Wallet setup completed!"

    cp "$KEYPAIR_PATH" "$PWD"
}

# ... (rest of the script remains unchanged)

# Main loop
while true; do
    show_menu
    read -p "Choose an option [1-6]: " choice
    case $choice in
        1) install_all ;;
        2) setup_wallet ;;
        3) create_and_install_dependencies ;;
        4) ts_file_Setup ;;
        5) mint ;;
        6) show "Exiting the script."; exit 0 ;;
        *) show "Invalid option. Please try again." ;;
    esac
done
