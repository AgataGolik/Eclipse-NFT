#!/bin/bash

# Function to display messages
show() {
    echo -e "\e[32m$1\e[0m"  # Green colored message
}

mkdir -p Eclipse && cd Eclipse

# Instalacja Node.js, Rust i Solana
install_all() {
    show "Instalacja Node.js, npm, Rust i Solana..."
    
    # Instalacja Node.js i npm
    source <(wget -O - https://raw.githubusercontent.com/zunxbt/installation/main/node.sh)
    
    # Instalacja Rust
    source <(wget -O - https://raw.githubusercontent.com/zunxbt/installation/main/rust.sh)

    # Instalacja Solana
    if ! command -v solana &> /dev/null; then
        show "Solana nie wykryto. Instalacja Solana..."
        sh -c "$(curl -sSfL https://release.solana.com/v1.18.18/install)"
    else
        show "Solana już jest zainstalowana."
    fi

    # Dodanie Solana do PATH
    echo 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

    if command -v solana &> /dev/null; then
        show "Solana dostępna."
    else
        show "Solana nie została dodana do PATH."
        exit 1
    fi
}

# Funkcja do ustawienia portfela
setup_wallet() {
    KEYPAIR_DIR="$HOME/solana_keypairs"
    mkdir -p "$KEYPAIR_DIR"

    show "Czy chcesz użyć istniejącego klucza prywatnego, wprowadzić nowy, czy stworzyć nowy portfel?"
    PS3="Wybierz opcję (1, 2 lub 3): "
    options=("Użyj istniejącego klucza prywatnego" "Wprowadź nowy klucz prywatny" "Stwórz nowy portfel")
    select opt in "${options[@]}"; do
        case $opt in
            "Użyj istniejącego klucza prywatnego"|"Wprowadź nowy klucz prywatny")
                show "Wprowadź klucz prywatny (Base58 lub tablica liczb):"
                read -p "> " PRIVATE_KEY
                KEYPAIR_PATH="$KEYPAIR_DIR/eclipse-wallet.json"
                if [[ $PRIVATE_KEY == \[* ]]; then
                    # Jeśli wprowadzono tablicę liczb
                    echo "$PRIVATE_KEY" > "$KEYPAIR_PATH"
                else
                    # Jeśli wprowadzono Base58
                    npm install bs58  # Instalacja bs58 (jeśli nie jest zainstalowane)
                    byte_array=$(node -e "console.log(JSON.stringify(require('bs58').decode('$PRIVATE_KEY')))")
                    echo "$byte_array" > "$KEYPAIR_PATH"
                fi
                break
                ;;
            "Stwórz nowy portfel")
                show "Tworzę nowy portfel..."
                KEYPAIR_PATH="$KEYPAIR_DIR/eclipse-wallet.json"
                solana-keygen new -o "$KEYPAIR_PATH" --force
                if [[ $? -ne 0 ]]; then
                    show "Nie udało się stworzyć nowego portfela. Zakończono."
                    exit 1
                fi
                break
                ;;
            *) show "Błędna opcja. Spróbuj ponownie." ;;
        esac
    done

    solana config set --keypair "$KEYPAIR_PATH"
    show "Konfiguracja portfela zakończona!"

    # Wyświetlenie zawartości pliku portfela
    show "Zawartość pliku portfela:"
    cat "$KEYPAIR_PATH"
}

# Instalacja zależności npm
create_and_install_dependencies() {
    # Tworzenie package.json
    cat <<EOF > package.json
{
  "name": "eclipse-nft",
  "version": "1.0.0",
  "dependencies": {
    "@metaplex-foundation/umi": "^0.9.2",
    "@metaplex-foundation/umi-bundle-defaults": "^0.9.2",
    "bs58": "^5.0.0"
  }
}
EOF

    show "package.json utworzony. Instalacja zależności npm..."
    npm install
}

# Pobieranie i ustawianie plików .ts
ts_file_Setup() {
    rm -f index.ts upload.ts  # Usuwanie istniejących plików, jeśli są
    
    wget -O index.ts https://raw.githubusercontent.com/zunxbt/Eclipse-NFT/main/index.ts
    wget -O upload.ts https://raw.githubusercontent.com/zunxbt/Eclipse-NFT/main/upload.ts

    show "Pliki .ts pobrane."
}

# Funkcja do mintowania NFT
mint() {
    show "Mintowanie NFT..."
    wget https://picsum.photos/200 -O image.jpg
    npx ts-node index.ts
}

# Wyświetlanie menu
show_menu() {
    echo -e "\n\e[34m===== Eclipse NFT Setup Menu =====\e[0m"
    echo "1) Instalacja Node.js, Rust, i Solana"
    echo "2) Ustawienie portfela"
    echo "3) Instalacja zależności npm"
    echo "4) Ustawienie plików .ts"
    echo "5) Start mintowania"
    echo "6) Wyjście"
    echo -e "===================================\n"
}

# Główna pętla menu
while true; do
    show_menu
    read -p "Wybierz opcję [1-6]: " choice
    case $choice in
        1) install_all ;;
        2) setup_wallet ;;
        3) create_and_install_dependencies ;;
        4) ts_file_Setup ;;
        5) mint ;;
        6) show "Zakończenie skryptu."; exit 0 ;;
        *) show "Nieprawidłowa opcja. Spróbuj ponownie." ;;
    esac
done

