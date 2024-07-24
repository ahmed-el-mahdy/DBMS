!#/bin/bash
# This Script to present DataBase application based on CLI 
#First Function is The Main Menu 
echo " Welcome to DBMS app please select from below mune ^_^ "
# Function to display the main menu
display_menu() {
    echo "Main Menu:"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo "5. Exit"
    echo -n "Please enter your choice [1-5]: "
}

# Function to create a new database
create_database() {
    echo -n "Enter the name of the new database: "
    read dbname
    if [ -z "$dbname" ]; then
        echo "Database name cannot be empty!"
    else
        mkdir -p "databases/$dbname"
        echo "Database '$dbname' created successfully."
    fi
}

# Function to list all databases
list_databases() {
    echo "List of Databases:"
    if [ ! -d "databases" ]; then
        echo "No databases found."
    else
        ls databases
    fi
}

# Function to connect to a database
connect_database() {
    echo -n "Enter the name of the database to connect to: "
    read dbname
    if [ -d "databases/$dbname" ]; then
        echo "Connected to database '$dbname'."
        # Placeholder for database interaction code
        echo "Type 'exit' to disconnect."
        while :; do
            echo -n "$dbname> "
            read cmd
            if [ "$cmd" == "exit" ]; then
                break
            fi
            echo "Command '$cmd' executed in database '$dbname'."
        done
    else
        echo "Database '$dbname' does not exist."
    fi
}

# Function to drop a database
drop_database() {
    echo -n "Enter the name of the database to drop: "
    read dbname
    if [ -d "databases/$dbname" ]; then
        rm -rf "databases/$dbname"
        echo "Database '$dbname' dropped successfully."
    else
        echo "Database '$dbname' does not exist."
    fi
}
# Main program loop
while :; do
    display_menu
    read choice
    case $choice in
        1) create_database ;;
        2) list_databases ;;
        3) connect_database ;;
        4) drop_database ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice, please try again." ;;
    esac
done
