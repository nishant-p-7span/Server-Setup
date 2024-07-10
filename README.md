# MYSQL Setup.
- Install mysql-server on EC2.
  ```
  sudo apt install mysql-server
  ```
- Secure installation.
  ```
  sudo mysql_secure_installation
  ```
> This print some configurations, you have to set it according to the your need. like paassword security, root login.
- Edit mysql configuration file to allow remote access directly from anywhere.
  - edit following file:
    ```
    sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
    ```
  - Change `bind-address = 127.0.0.1` to `bind-address = 0.0.0.0` so anyone can access server from anywhere.

  - Create mysql user.
    - log in to root `mysql` user.
      ```
      sudo mysql
      ```
    - Regular password user:
      ```
      CREATE USER 'your_user'@'%' IDENTIFIED BY 'your_password';
      ```
    - Native password user(used for directus):
      ```
      CREATE USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
      ```
    - Give all permissions:
      ```
      GRANT ALL PRIVILEGES ON *.* TO 'your_user'@'%' WITH GRANT OPTION;
      FLUSH PRIVILEGES;
      EXIT;
      ```
  ## mysql basic commands.
  - status of mysql service.
    ```
    systemctl status mysql.service
    ```
  - restart service. (Run this after changing bind-addresses)
    ```
    sudo service mysql restart
    ```
  ## Import MySQL dump using CLI:
  - add .sql dump using cli.
    ```
    mysql -u username -p database_name < file.sql
    ```
  - Other trick is import it from Tableplus.
