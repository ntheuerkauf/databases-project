# databases-project
Here are instructions to access our project. It is designed to run on a github codespace. If this is not being accessed on github, the github is https://github.com/ntheuerkauf/databases-project. In order to start the codespace, click on the green 'Code' button. Then, click on the green button to create a codespace on main. This should open a new window. In the terminal of the codespace enter the following lines individually to install the required packages:
```
  sudo apt update  
  sudo apt install mysql-server  #This one will prompt you with [Y/N], hit y and then enter
  pip install flask  
  pip install mysql-connector-python  
```
  
The follwing lines will activate the server:
```
  sudo service mysql start  

  sudo mysql -u root -e "
  ALTER USER 'root'@'localhost'
  IDENTIFIED WITH mysql_native_password BY 'root';
  FLUSH PRIVILEGES;
  "  
```
  
Then you must move into the GasStationHQ directory: 
```
  cd GasStationHQ/
```
  
The following like will prompt you for a password, type in 'root' and then hit enter:
```
  mysql -h 127.0.0.1 -u root -p < "cs4400 Deliverable 5.sql"  
```

The final line will startup the website, there should be a little pop up in the bottom right corner, click on the blue button to open it in a new tab:
```
  python app.py
```

If you make changes to the database on the website and want to see if they are reflected in the MySQL database, the first step is to go back to the terminal in the codepsace and hit CTRL + C to close the wbesite. Then, enter `sudo mysql -u root -e -p "YOUR SQL CODE HERE"`. You will then be prompted to enter the password, which is still root. This will cause SQL statments within the quotation markes to be executed. For example, wanted to see the store table you would enter:
```
  sudo mysql -u root -p -e " use GasStationHQ; select * from Store;"
```
If you open the website back up with `python app.py` you will see that any changes you have made are still present.
