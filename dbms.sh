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
	@@ -25,7 +25,7 @@ display_db_menu() {
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
	@@ -58,7 +58,7 @@ list_databases() {
  ls -d databases/*/ 2>/dev/null || echo "No databases found."
}

# Function to connect to a database  ##check
connect_database() {
    echo -n "Enter the name of the database to connect to: "
    read dbname
	@@ -96,20 +96,79 @@ drop_database() {
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

            echo -n "Enter data for column '$column_name' ($data_type): "
            read value

            if [[ "$data_type" == "int" && ! "$value" =~ ^-?[0-9]+$ ]]; then
                echo "Invalid data type for column '$column_name'. Expected integer."
                return 1
            elif [[ "$data_type" == "text" && ! "$value" =~ ^[a-zA-Z]+$ ]]; then
                echo "Invalid data type for column '$column_name'. Expected text."
                return 1
            fi

            data+=("$value")
        done

        # Insert data into the table
        echo "${data[*]}" >> "$tablefile"
        echo "Data inserted into table '$tablename'."
    else
        echo "Invalid action. Please choose 'column' or 'row'."
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