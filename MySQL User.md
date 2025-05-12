# Database User Management and Sample Data Generation

## 1. Generate Random Test Data

This section creates a sample e-commerce database with customers, products, orders, and related tables.

```sql
-- Create and use database
CREATE DATABASE IF NOT EXISTS test_store;
USE test_store;

-- Table definitions
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50),
    description TEXT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    stock_quantity INT,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    status ENUM('pending', 'processing', 'shipped', 'delivered'),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample data generation
-- Categories and Products
INSERT INTO product_categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications'),
('Home & Kitchen', 'Home and kitchen items');

INSERT INTO products (category_id, product_name, price, stock_quantity) VALUES
(1, 'Smartphone X', ROUND(RAND() * (999-299) + 299, 2), FLOOR(RAND() * 100)),
(1, 'Laptop Pro', ROUND(RAND() * (1999-799) + 799, 2), FLOOR(RAND() * 50)),
(2, 'Cotton T-Shirt', ROUND(RAND() * (39-19) + 19, 2), FLOOR(RAND() * 200)),
(2, 'Jeans', ROUND(RAND() * (89-49) + 49, 2), FLOOR(RAND() * 150)),
(3, 'Programming Guide', ROUND(RAND() * (59-29) + 29, 2), FLOOR(RAND() * 75)),
(3, 'Science Fiction Novel', ROUND(RAND() * (29-9) + 9, 2), FLOOR(RAND() * 100)),
(4, 'Coffee Maker', ROUND(RAND() * (199-79) + 79, 2), FLOOR(RAND() * 30)),
(4, 'Cooking Set', ROUND(RAND() * (299-149) + 149, 2), FLOOR(RAND() * 40));

-- Customer generation procedure
DELIMITER //
CREATE PROCEDURE generate_customers(IN num_customers INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < num_customers DO
        INSERT INTO customers (first_name, last_name, email, phone) 
        VALUES (
            CONCAT('FirstName', i),
            CONCAT('LastName', i),
            CONCAT('user', i, '@example.com'),
            CONCAT('555-', LPAD(FLOOR(RAND() * 10000), 4, '0'))
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Order generation procedure
DELIMITER //
CREATE PROCEDURE generate_orders(IN num_orders INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < num_orders DO
        -- Insert order
        INSERT INTO orders (customer_id, total_amount, status)
        VALUES (
            FLOOR(RAND() * 50) + 1,
            0,
            ELT(FLOOR(RAND() * 4) + 1, 'pending', 'processing', 'shipped', 'delivered')
        );
        
        -- Insert 1-5 order items for this order
        SET @order_id = LAST_INSERT_ID();
        SET @num_items = FLOOR(RAND() * 5) + 1;
        SET @j = 0;
        
        WHILE @j < @num_items DO
            SET @product_id = FLOOR(RAND() * 8) + 1;
            SET @quantity = FLOOR(RAND() * 5) + 1;
            
            SELECT price INTO @price FROM products WHERE product_id = @product_id;
            
            INSERT INTO order_items (order_id, product_id, quantity, unit_price)
            VALUES (@order_id, @product_id, @quantity, @price);
            
            SET @j = @j + 1;
        END WHILE;
        
        -- Update order total
        UPDATE orders 
        SET total_amount = (
            SELECT SUM(quantity * unit_price)
            FROM order_items
            WHERE order_id = @order_id
        )
        WHERE order_id = @order_id;
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate sample data
CALL generate_customers(50);
CALL generate_orders(100);

-- Cleanup
DROP PROCEDURE generate_customers;
DROP PROCEDURE generate_orders;
```

## 2. Read-Only User Creation

Create a user with only SELECT permissions for data analysis purposes.

```sql
-- Create read-only user
CREATE USER 'readonly_user'@'%' IDENTIFIED BY 'password';
GRANT SELECT ON *.* TO 'readonly_user'@'%';
GRANT SHOW DATABASES ON *.* TO 'readonly_user'@'%';
FLUSH PRIVILEGES;
```

## 3. Limited Permission User Creation

Create a user with basic CRUD operations but restricted to specific databases.

```sql
-- Create limited access user
CREATE USER 'limited_user'@'%' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE, DELETE ON `database_name`.* TO 'limited_user'@'%';
FLUSH PRIVILEGES;
```

> Note: Replace 'password', 'database_name' with appropriate values for your environment.

## 4. Admin-Like User Creation

Create a user with admin-like privileges (all privileges on all databases except GRANT OPTION).

```sql
-- Create admin-like user
CREATE USER 'admin_user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

> Note: Replace 'password' with a secure password for your environment.

---

### RDS Access Denied Error

**Note for AWS RDS users:**  
If you see an error like:

```
Query 1: Access denied for user 'admin'@'%' (using password: YES)
```

- AWS RDS does **not** allow creation of users named `admin` or granting full root privileges.
- The `admin` user is reserved and managed by AWS.
- You must use the master user created during RDS setup, and you cannot grant yourself SUPER or certain global privileges.
- For admin-like access, create a user with a different name (not `admin` or `root`) and grant the highest privileges allowed by RDS, but some privileges will still be restricted.

Refer to [AWS RDS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.MasterAccounts.html) for details.
