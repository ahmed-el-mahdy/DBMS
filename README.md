<h1 align="center">📊 Database Management System (DBMS) 📊</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Language-Bash-blue?style=flat&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Status-Development-yellowgreen?style=flat" alt="Status">
  <img src="https://img.shields.io/badge/Version-1.0-blue?style=flat" alt="Version">
</p>

---

## 📋 Overview

This **Database Management System** is a simple yet powerful command-line tool built with a Bash script. It allows users to create, manage, and manipulate databases efficiently. The project utilizes regular expressions for input validation and provides a user-friendly interface.

---

## 🚀 Features

- **Create Databases**: Easily create new databases with valid names.
- **List Databases**: View all available databases at a glance.
- **Connect to Databases**: Seamlessly connect to existing databases to perform operations.
- **CRUD Operations**: Perform Create, Read, Update, and Delete operations on tables.
- **Table Management**: Create, list, drop, and modify tables within databases.

---

## 📂 Project Structure

```bash
DBMS/
├── databases/                    # Directory containing created databases
│   ├── db1/                      # Example database
│   │   ├── table1                # Example table within db1
│   │   ├── ...
│   ├── ...
│
├── dbms.sh                       # Main Bash script for DBMS functionality
└── README.md                     # Project documentation
