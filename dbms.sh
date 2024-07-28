#!/bin/bash

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

# Function to display the database menu
display_db_menu() {
    echo "Database Menu:"
    echo "1. Create Table"
    echo "2. List Tables"
    echo "3. Drop Table"
    echo "4. Insert into Table"
    echo "5. Select From Table"
    echo "6. Delete From Table"
    echo "7. Update Table"
    echo "8. Exit to Main Menu"
    echo -n "Please enter your choice [1-8]: "
}

# Function to create a new database
create_database() {
  read -p "Enter database name: " dbname
  # Check if the database name is empty
  if [ -z "$dbname" ]; then
        echo "Database name cannot be empty!"
        return 1
   fi
  
  # Define a regex pattern for valid database names
  # Must start with a letter only 
  regex='^[a-zA-Z]'
  
  # Check if the database name matches the regex
  if [[ $dbname =~ $regex ]]; then
    # Check if the database directory already exists
    if [ -d "$dbname" ]; then
      echo "Database '$dbname' already exists."
    else
      mkdir -p "databases/$dbname"
      echo "Database '$dbname' created."
    fi
  else
    echo "Invalid database name. The name must start with a letter only"
  fi
}

# Function to list the database
list_databases() {
  echo "Databases:"
  ls -d databases/*/ 2>/dev/null || echo "No databases found."
}

# Function to connect to a database
connect_database() {
    echo -n "Enter the name of the database to connect to: "
    read dbname
    if [ -d "databases/$dbname" ]; then
        echo "Connected to database '$dbname'."
        while :; do
            display_db_menu
            read db_choice
            case $db_choice in
                1) create_table "$dbname" ;;
                2) list_tables "$dbname" ;;
                3) drop_table "$dbname" ;;
                4) insert_into_table "$dbname" ;;
                5) select_from_table "$dbname" ;;
                6) delete_from_table "$dbname" ;;
                7) update_table "$dbname" ;;
                8) break ;;
                *) echo "Invalid choice, please try again." ;;
            esac
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

# Function to create a table in the connected database
create_table() {
    dbname=$1
    echo -n "Enter the name of the new table: "

    read tablename
    if [ -z "$tablename" ]; then
        echo "Table name cannot be empty!"
        return 1
    fi
# Check if the table name matches the regex 
    if [[ $tablename =~ $regex ]]; then
        if [ -f "$tablename" ]; then
            echo "The table '$tablename' already exists."

        else
            echo "Enter the columns for the table (format: column_name:data_type). Type 'done' when finished:"
            columns=()
            while :; do
                read column
                if [ "$column" == "done" ]; then
                    break
                fi
                columns+=("$column")
            done

            if [ ${#columns[@]} -eq 0 ]; then
                echo "No columns specified. Table creation aborted."
                return 1
            fi

            # Ask for the primary key
            echo "Enter the primary key column name from the above list:"
            read primary_key

            if [[ ! " ${columns[@]} " =~ " ${primary_key} " ]]; then
                echo "Primary key column not found in the column list. Table creation aborted."
                return 1
            fi

            # Create the table file with column definitions
            echo "${columns[*]}" > "$tablename"
            echo "Primary Key: $primary_key" >> "$tablename"
            echo "Table '$tablename' created in database '$dbname' with columns: ${columns[*]} and primary key: $primary_key"
        fi
    
    else 
        echo "Invalid database name. The name must start with a letter only"
    fi
}

# Function to list all tables in the connected database
list_tables() {
    dbname=$1
    echo "List of Tables in database '$dbname':"
    if [ ! "$(ls -A databases/$dbname)" ]; then
        echo "No tables found."
    else
        ls "databases/$dbname"
    fi
}

# Function to drop a table in the connected database
drop_table() {
    dbname=$1
    echo -n "Enter the name of the table to drop: "
    read tablename
    if [ -f "databases/$dbname/$tablename" ]; then
        rm "databases/$dbname/$tablename"
        echo "Table '$tablename' dropped from database '$dbname'."
    else
        echo "Table '$tablename' does not exist."
    fi
}

# Function to insert data into a table
insert_into_table() {
    dbname=$1
    echo -n "Enter the name of the table to insert into: "
    read tablename
    if [ -f "databases/$dbname/$tablename" ]; then
        echo -n "Enter data to insert: "
        read data
        echo "$data" >> "databases/$dbname/$tablename"
        echo "Data inserted into table '$tablename'."
    else
        echo "Table '$tablename' does not exist."
    fi
}

# Function to select data from a table
select_from_table() {
    dbname=$1
    echo -n "Enter the name of the table to select from: "
    read tablename
    if [ -f "databases/$dbname/$tablename" ]; then
        echo "Data from table '$tablename':"
        cat "databases/$dbname/$tablename"
    else
        echo "Table '$tablename' does not exist."
    fi
}

# Function to delete data from a table
delete_from_table() {
    dbname=$1
    echo -n "Enter the name of the table to delete from: "
    read tablename
    if [ -f "databases/$dbname/$tablename" ]; then
        echo -n "Enter data to delete: "
        read data
        sed -i "/$data/d" "databases/$dbname/$tablename"
        echo "Data deleted from table '$tablename'."
    else
        echo "Table '$tablename' does not exist."
    fi
}

# Function to update data in a table
update_table() {
    dbname=$1
    echo -n "Enter the name of the table to update: "
    read tablename
    if [ -f "databases/$dbname/$tablename" ]; then
        echo -n "Enter old data to replace: "
        read old_data
        echo -n "Enter new data: "
        read new_data
        sed -i "s/$old_data/$new_data/g" "databases/$dbname/$tablename"
        echo "Data in table '$tablename' updated."
    else
        echo "Table '$tablename' does not exist."
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