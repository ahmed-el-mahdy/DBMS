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

# Function to list the database     ##checked
list_databases() {
  echo "Databases:"
  ls -d databases/*/ 2>/dev/null || echo "No databases found."
}

# Function to connect to a database  ##checked
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

# Function to drop a database   ##checked
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
}
################################################################################

# Function to insert data into a table
insert_into_table() {
    dbname=$1
    echo -n "Enter the name of the table to insert into: "
    read tablename
    tablefile="databases/$dbname/$tablename"

    if [ ! -f "$tablefile" ]; then
        echo "Table '$tablename' does not exist in database '$dbname'."
        return 1
    fi 

    # Read the columns from the table file
    columns=$(head -n 1 "$tablefile")
    IFS=' ' read -r -a column_array <<< "$columns"

    # Prompt for data
    data=()
    for col in "${column_array[@]}"; do
        column_name=${col%%:*}
        data_type=${col##*:}

        echo -n "Enter data for column '$column_name' ($data_type): "
        read value

        # Validate data type
        if [[ "$data_type" == "int" && ! "$value" =~ ^-?[0-9]+$ ]]; then
            echo "Invalid data type for column '$column_name'. Expected integer."
            return 1
        elif [[ "$data_type" == "text" && ! "$value" =~ ^[a-zA-Z]+$ ]]; then
            echo "Invalid data type for column '$column_name'. Expected text."
            return 1
        fi

        data+=("$value")
    done

    # Create data string with ':' separator
    data_string=$(IFS=':'; echo "${data[*]}")

    # Insert data into the table
    echo "$data_string" >> "$tablefile"
    echo "Data inserted into table '$tablename' in database '$dbname' successfully."
}


select_from_table() {                      ##checked     
    dbname=$1
    echo -n "Enter the name of the table to select from: "
    read tablename
    tablefile="databases/$dbname/$tablename"

    if [ ! -f "$tablefile" ]; then
        echo "Table '$tablename' does not exist in database '$dbname'."
        return 1
    fi

    # Read the columns from the table file
    columns=$(head -n 1 "$tablefile")
    IFS=' ' read -r -a column_array <<< "$columns"
    
    # Extract column names for output
    column_names=$(printf "%s\n" "${column_array[@]}" | sed 's/:.*//')
    
    echo "Available columns: ${column_names[*]}"

    # Prompt for column selection
    echo -n "Enter the columns to select (comma-separated, or * for all columns): "
    read selected_columns

    if [ "$selected_columns" == "*" ]; then
        selected_columns=$(printf "%s\n" "${column_names[@]}")
    fi
    IFS=',' read -r -a selected_column_array <<< "$selected_columns"

    echo -n "Enter the condition for selection (e.g., column_name=value), or press enter to skip: "
    read condition

    # Display the selected columns header
    echo "Selected columns: ${selected_column_array[*]}"

    # Read and display the data
    while IFS= read -r line; do
        # Skip the first line (column definitions)
        if [[ "$line" == "$columns" ]]; then
            continue
        fi

        IFS=':' read -r -a data_array <<< "$line"

        # Apply condition if specified
        if [ -n "$condition" ]; then
            condition_column=${condition%%=*}
            condition_value=${condition##*=}
            condition_column_index=-1
            for i in "${!column_array[@]}"; do
                if [[ "${column_array[$i]}" == "$condition_column:"* ]]; then
                    condition_column_index=$i
                    break
                fi
            done
            if [ $condition_column_index -eq -1 ] || [ "${data_array[$condition_column_index]}" != "$condition_value" ]; then
                continue
            fi
        fi

        # Output the selected columns
        output=()
        for col in "${selected_column_array[@]}"; do
            for i in "${!column_array[@]}"; do
                if [[ "${column_array[$i]}" == "$col:"* ]]; then
                    output+=("${data_array[$i]}")
                    break
                fi
            done
        done

        # Print only the selected columns
        echo "${output[*]}"
    done < "$tablefile"
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
    else
        echo "Table '$tablename' does not exist."
    fi
}

# Function to update data in a table    ##checked
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

# Main program loop     ##checked
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
