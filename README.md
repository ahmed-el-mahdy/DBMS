# Database Management System

Welcome to the Database Management System (DBMS) built with a Bash script that incorporates condition matching and regex inputs. I am excited to share this project and welcome your reviews and feedback on trying this script on your devices.

## Features

The DBMS includes the following main functionalities:

### Main Menu

Upon running the script, you will be greeted with the main menu, offering the following options:


### Database Menu

After connecting to a database, you can access the database menu, which provides additional options:


## How to Use

1. **Create a Database**: Enter the name for your new database (must start with a letter).
2. **List Databases**: View all existing databases.
3. **Connect to Database**: Choose a database to interact with.
4. **Drop Database**: Remove a database by name.
5. **Exit**: Exit the application.

### Database Menu Options

- **Create Table**: Define a new table by entering its name and columns.
- **List Tables**: View all tables within the connected database.
- **Drop Table**: Remove a table from the database.
- **Insert into Table**: Add new records to a specified table.
- **Select From Table**: Retrieve specific data from a table based on conditions.
- **Delete From Table**: Remove specific records from a table.
- **Update Table**: Modify existing records in a table.
- **Exit to Main Menu**: Return to the main menu.

## Enjoy Trying This Application for Free!

## Script Overview

Below is a summary of the Bash script's functionality:

```bash
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

# Other functions for database operations...
