import mysql.connector

def get_connection():
    return mysql.connector.connect(
        host="localhost",
        port=3306,
        user="root",          # replace with your MySQL username
        password="Fargalaxy#15",  # replace with your MySQL password
        database="GasStationHQ"
    )
