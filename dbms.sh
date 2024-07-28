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
function create_table() {
  read -p "Enter table name: " table_name
  read -p "Enter columns (comma separated): " columns
  read -p "Enter primary key column: " primary_key
  echo "$columns|$primary_key" > "$table_name"
  echo "Table '$table_name' created."
}

# Function to list all tables in the connected database
function list_tables() {
  echo "Tables:"
  ls
}


# Function to drop a table in the connected database
function drop_table() {
  read -p "Enter table name to drop: " table_name
  rm "$table_name"
  echo "Table '$table_name' dropped."
}


# Function to insert data into a table
function insert_into_table() {
  read -p "Enter table name: " table_name
  if [ -f "$table_name" ]; then
    columns=$(head -1 "$table_name" | cut -d'|' -f1)
    IFS=',' read -ra col_array <<< "$columns"
    record=""
    for col in "${col_array[@]}"; do
      read -p "Enter value for $col: " value
      record+="$value|"
    done
    record="${record%|}"
    echo "$record" >> "$table_name"
    echo "Record inserted."
  else
    echo "Table '$table_name' does not exist."
  fi
}

# Function to select data from a table
function select_from_table() {
  read -p "Enter table name: " table_name
  if [ -f "$table_name" ]; then
    cat "$table_name"
  else
    echo "Table '$table_name' does not exist."
  fi
}

# Function to delete data from a table
function delete_from_table() {
  read -p "Enter table name: " table_name
  if [ -f "$table_name" ]; then
    read -p "Enter primary key value to delete: " pk_value

    # Read the column names and identify the primary key column
    header=$(head -1 "$table_name")
    IFS='|' read -ra columns <<< "$header"
    pk_col_index=-1

    # Assuming the first column is the primary key column
    pk_col_index=0

    # Temporary file to store the updated table data
    temp_file=$(mktemp)

    # Use awk to delete the record with the matching primary key value
    awk -v pk_col_index=$((pk_col_index + 1)) -v pk_value="$pk_value" -F '|' '
      NR==1 { print; next }
      $pk_col_index != pk_value { print }
    ' "$table_name" > "$temp_file"

    # Check if any records were deleted by comparing file sizes
    original_size=$(wc -c < "$table_name")
    new_size=$(wc -c < "$temp_file")

    # Move the temporary file back to the original table file if the size differs
    if [ "$original_size" -ne "$new_size" ]; then
      mv "$temp_file" "$table_name"
      echo "Record with primary key value '$pk_value' deleted successfully."
    else
      rm "$temp_file"
      echo "Failed to delete the record with primary key value '$pk_value'."
    fi
  else
    echo "Table '$table_name' does not exist."
  fi
}


# Function to update data in a table
function update_table() {
  read -p "Enter table name: " table_name
  if [ -f "$table_name" ]; then
    read -p "Enter primary key value to update: " pk_value

    # Extract the header and primary key column name
    header=$(head -1 "$table_name")
    IFS='|' read -ra columns <<< "$header"
    
    # Assuming the primary key column is always the first column (change if necessary)
    pk_col_index=0
    
    # Find the record with the primary key value
    record=$(awk -v pk_index="$((pk_col_index + 1))" -v pk_value="$pk_value" -F '|' '
      NR==1 {next}  # Skip the header
      $pk_index == pk_value {print; exit}' "$table_name")

    if [ -z "$record" ]; then
      echo "No record found with primary key value '$pk_value'."
      return
    fi

    echo "Current record: $record"
    IFS='|' read -ra old_values <<< "$record"
    updated_record=""

    for i in "${!columns[@]}"; do
      read -p "Enter new value for ${columns[$i]} (current: ${old_values[$i]}): " new_value
      updated_record+="${new_value:-${old_values[$i]}}|"
    done

    updated_record="${updated_record%|}"

    # Create a temporary file with the updated data
    awk -v pk_index="$((pk_col_index + 1))" -v pk_value="$pk_value" -v updated_record="$updated_record" -F '|' '
      BEGIN {OFS = FS}
      NR==1 {print; next}
      $pk_index == pk_value {print updated_record; next}
      {print}' "$table_name" > tmpfile && mv tmpfile "$table_name"

    # Verify if the record has been updated
    new_record=$(awk -v pk_index="$((pk_col_index + 1))" -v pk_value="$pk_value" -F '|' '
      NR==1 {next}
      $pk_index == pk_value {print; exit}' "$table_name")

    if [ "$record" != "$new_record" ]; then
      echo "Record updated successfully."
      echo "Updated record: $new_record"
    else
      echo "Record was not updated."
    fi
  else
    echo "Table '$table_name' does not exist."
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