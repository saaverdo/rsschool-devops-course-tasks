## Simple app
This simple flask app is working with `mysql` and `sqlite`.  
It will show client's IP and server's hostname and write this info into sqlite or mysql database.  
Database usage depends on environment variable `FLASK_CONFIG`. By default sqlite will be used.  
To work with MySQL set config value to mysql:  
`export FLASK_CONFIG=mysql`  

## Installation:
### DB settings for MySQL
DB connection parameters could be defined with environment variables (example with default values)  

`MYSQL_USER`="admin"      
`MYSQL_PASSWORD`="Pa55WD"   
`MYSQL_DB`="flask_db"     
`MYSQL_HOST`="127.0.0.1"  

#### Install DB server for MySQL:

```
sudo apt update
sudo apt install -y mariadb-server
```

#### Create Mysql user and database

```bash
sudo mysql -e " CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'Pa55WD';
SELECT user FROM mysql.user;
create database flask_db;
grant ALL on flask_db.* to  'admin'@'%';
SHOW DATABASES;"
```

### SQLite  
SQLite is default option if `FLASK_CONFIG` env var is not defined of set to `default`.  
Database will be created automatically.  


### Install app
#### install packages required for app
Application requires Python 3.8 of above installed in system.


```
sudo apt install -y python3-pip default-libmysqlclient-dev build-essential pkg-config
```

#### install app and dependencies

```
git clone https://github.com/saaverdo/flask-alb-app -b orm

cd flask-alb-app

sudo pip install -r requirements.txt
```

### Run app

```
gunicorn -b 0.0.0.0 appy:app
```

App will be available via url `http://<instance_dns_or_ip>:8000`  

   
