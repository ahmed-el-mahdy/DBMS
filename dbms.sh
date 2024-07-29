#!/bin/bash

# Function to display the main menu  ##checked
display_menu() {
    echo "Main Menu:"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo "5. Exit"
    echo -n "Please enter your choice [1-5]: "
}

# Function to display the database menu     ##checked
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

# Function to create a new database     ##checked
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
=======
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

# Function to connect to a database  ##check
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


# Function to create a table in the connected database  ##checked
create_table() {
    dbname=$1
    dbpath="databases/$dbname"

    # Check if the database directory exists
    if [ ! -d "$dbpath" ]; then
        echo "Database '$dbname' does not exist."
        return 1
    fi

    echo -n "Enter the name of the new table: "
    read tablename
    if [ -z "$tablename" ]; then
        echo "Table name cannot be empty!"
        return 1
    fi
    #Define regex to check
    regex='^[a-zA-Z][a-zA-Z0-9]*$'  

    # Check if the table name matches the regex 
    if [[ $tablename =~ $regex ]]; then
        tablefile="$dbpath/$tablename"


        if [ -f "$tablefile" ]; then
            echo "The table '$tablename' already exists."
            
        else
        #After entering each column, the user should press Enter to input the next column.
        #When the user has finished entering all the columns, they should type done and press Enter.
            echo "Enter the columns for the table (format: column_name:data_type(int,text)). Type 'done' when finished:"
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

            # Extract just the column names for primary key validation
            column_names=()
            for col in "${columns[@]}"; do
                column_names+=("${col%%:*}")
            done

            # Ask for the primary key
            echo "Enter the primary key column name from the above list:"
            read primary_key

            if [[ ! " ${column_names[@]} " =~ " ${primary_key} " ]]; then
                echo "Primary key column not found in the column list. Table creation aborted."
                return 1
            fi

            # Create the table file with column definitions
            echo "${columns[*]}" > "$tablefile"
            echo "Primary Key: $primary_key" >> "$tablefile"
            echo "Table '$tablefile' created in database '$dbname' with columns: ${columns[*]} and primary key: $primary_key"
        fi
    
    else 
        echo "Invalid Table name. The name must start with a letter only"
    fi
}

# Function to list all tables in the connected database  ##checked 
list_tables() {
    dbname=$1
    echo "List of Tables in database '$dbname':"
    if [ ! "$(ls -A databases/$dbname)" ]; then
        echo "No tables found."
    else
        ls "databases/$dbname"
    fi
}

# Function to drop a table in the connected database    ##checked
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
################################################################################

# Function to add a column to an existing table  ##checked
add_column_to_table() {
    dbname=$1
    tablename=$2
    tablefile="databases/$dbname/$tablename"

    # Check if the table file exists
    if [ ! -f "$tablefile" ]; then
        echo "Table '$tablename' does not exist in database '$dbname'."
        return 1
    fi
    
echo "Enter the columns for the table (format: column_name:data_type(int,text)). Type 'done' when finished:"

    columns=()
    while :; do
        read column
        if [ "$column" == "done" ]; then
            break
        fi
        # Check if the table name matches the regex 
        if [[ ! "$column" =~ ^[a-zA-Z][a-zA-Z0-9]*:(int|text)$ ]]; then
            echo "Invalid column format. Use 'column_name:data_type'."
            continue
        fi 
        
        columns+=("$column")
    done

    if [ ${#columns[@]} -eq 0 ]; then
        echo "No columns specified. Table creation aborted."
        return 1
    fi

    echo "${columns[*]}" >> "$tablefile"        
    echo "Columns '${columns[*]}' created in Table '$tablename' in database: '$dbname' successfully."
}



# Function to insert data into a table

insert_into_table() {
    dbname=$1
    dbpath="databases/$dbname"
    echo -n "Enter the name of the table to insert into: "
    read tablename
    tablefile="$dbpath/$tablename"

    if [ ! -f "$tablefile" ]; then
        echo -n "Table '$tablename' does not exist."
        return 1
    fi 

    echo "Do you want to add a new column or insert data as a row? (column/row)"
    read action

    if [ "$action" == "column" ]; then
        add_column_to_table "$dbname" "$tablename"
    elif [ "$action" == "row" ]; then
        # Read the columns from the table file
        columns=$(head -n 1 "$tablefile")
        IFS=' ' read -r -a column_array <<< "$columns"

        data=()
        for col in "${column_array[@]}"; do
            column_name=${col%%:*}
            data_type=${col##*:}

            while :; do 
                echo -n "Enter data for column '$column_name' ($data_type): "
                read value
            # Validate the input data type
                if [[ "$data_type" == "int" && ! "$value" =~ ^-?[0-9]+$ ]]; then
                    echo "Invalid data type for column '$column_name'. Expected integer."
                return 1
                elif [[ "$data_type" == "text" && ! "$value" =~ ^[a-zA-Z]+$ ]]; then
                    echo "Invalid data type for column '$column_name'. Expected text."
                else 
                break
                fi
            done

            data+=("$value")
        done

        # Insert data into the table
        echo "${data[*]}" >> "$tablefile"
        echo "Data inserted into table '$tablename'."
    else
        echo "Invalid action. Please choose 'column' or 'row'."
        return 1
    fi


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
  if [ ! -f "$table_name" ]; then
    echo "Table '$table_name' does not exist."
    return
  fi

  # Read the header and display the column names
  header=$(head -1 "$table_name")
  IFS='|' read -ra columns <<< "$header"
  echo "Available columns: ${columns[*]}"

  read -p "Do you want to filter the results? (y/n): " filter
  if [ "$filter" == "y" ]; then
    read -p "Enter column name to filter by: " col_name
    read -p "Enter value to filter by: " col_value

    # Get the index of the column to filter by
    col_index=-1
    for i in "${!columns[@]}"; do
      if [ "${columns[$i]}" == "$col_name" ]; then
        col_index=$i
        break
      fi
    done

    if [ $col_index -eq -1 ]; then
      echo "Column '$col_name' does not exist."
      return
    fi

    echo "Filtering by column '${columns[$col_index]}' (Index: $col_index), looking for value '$col_value'."

    # Display the filtered results
    awk -v col_index=$((col_index + 1)) -v col_value="$col_value" -F '|' '
      NR==1 {print; next}  # Always print the header
      $col_index == col_value {print}' "$table_name"
  else
    # Display the entire table
    cat "$table_name"
  fi
}


# Function to delete data from a table  ##checked
delete_from_table() {
    dbname=$1
    echo -n "Enter the name of the table to delete from: "
    read tablename
    if [ -f "databases/$dbname/$tablename" ]; then
        echo -n "Enter data to delete: "
        read data
        sed -i "/$data/d" "databases/$dbname/$tablename"
        echo "Data deleted from table '$tablename'."



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