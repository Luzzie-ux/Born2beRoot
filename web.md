*This document is part of an guide on how to install, manage and effeciently usewordpress, lighttpd, mariaDB, php and Apache2*

| Website   | 		| 			Link 			|
|-----------|-------|---------------------------| 
| LightTPD  | 		| https://www.lighttpd.net/ | 
| PHP 	    | 		| https://www.php.net/ 		| 
| MariaDB   | 		| https://mariadb.org/ 		| 
| Litespeed | 		| https://openlitespeed.org/| 
| Wordpress | 		| https://wordpress.org/ 	| 

## Light TPD

header

end
## PHP

header

end
## MariaDB

MariaDB is a database server originaly made by the developer of MySQL, it is a open source software used for multiple purposes.

```bash
sudo apt install mariadb-server
sudo mariadb_secure_installation

# When prompted read the question and answer with these:
# Switch to unix_socket autentication? → N 
# Change the root password? → N
# Remove anonymous users? → Y 
# Disallow root login remotely? → Y 
# Remove test database and access to it? → Y 
# Reload privilege tables now? → Y
```

We dont switch to unix socket auth because we already have protected root
We dont change the root password because its not really root, since we need to give it amdin perms
We allow remove anon users because it was only for debuging purposes just like the database named `test`
We allow the root login not being able to be done remotely to prevent anyone to connect by guessing the password
We reload privilege tables to reload the SQL permissions tables, changing them to the secure settings

### Create a database

Once everythin is setup to use MariaDB we will run the following command to bring the mariadb terminal up:
`mariadb`

Now to make a database for our wordpress server we will type:
```mariadb
CREATE DATABASE "wp_database_name";
```
Remember that all commands in mariadb finish with a semicolon, if you forget it the terminal will show a new column of arrows waiting for the semicolon

Next we will make a user inside the database, and add it to the Wordpress database:
```mariadb
CREATE USER 'username'@'localhost' IDENTIFIED BY '12345';

GRANT ALL PRIVILEGES ON "wp_database_name.*" TO 'username'@'localhost';
```

Now we update the permissions so the changes we make take effect:
```mariadb
FLUSH PRIVILEGES
```

Once everything is completed just type `exit` to leave the mariadb terminal :D

If you wish to the databases run the following command:
```mariadb
SHOW DATABASES;
```

## Apache2

header

end
## Wordpress

header

end
