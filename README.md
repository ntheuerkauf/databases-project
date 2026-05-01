# databases-project
sudo apt update  
sudo apt install mysql-server  
pip install flask  
pip install mysql-connector-python  


sudo service mysql start

sudo mysql -u root -e "
ALTER USER 'root'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
"
cd GasStationHQ/

mysql -h 127.0.0.1 -u root -p < "cs4400 Deliverable 5.sql"

python app.py
