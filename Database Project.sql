-- creating tables
CREATE TABLE INVENTORY_CATEGORY (
    ID          NUMBER(19, 0)    NOT NULL PRIMARY KEY,
    NAME        NVARCHAR2(100),
    DESCRIPTION NCLOB
);

CREATE TABLE INVENTORY_SUPPLIER (
    ID               NUMBER(19, 0)    NOT NULL PRIMARY KEY,
    NAME             NVARCHAR2(150),
    CONTACT_PERSON   NVARCHAR2(100),
    PHONE            NVARCHAR2(20   ),
    EMAIL            NVARCHAR2(254),
    ADDRESS          NCLOB
);

CREATE TABLE INVENTORY_PRODUCT (
    ID           NUMBER(19, 0)    NOT NULL PRIMARY KEY,
    NAME         NVARCHAR2(100),
    SKU          NVARCHAR2(50),
    QUANTITY     NUMBER(11, 0)    NOT NULL,
    PRICE        NUMBER(10, 2)    NOT NULL,
    CATEGORY_ID  NUMBER(19, 0),
    SUPPLIER_ID  NUMBER(19, 0),
    CONSTRAINT fk_product_category FOREIGN KEY (CATEGORY_ID) REFERENCES INVENTORY_CATEGORY(ID),
    CONSTRAINT fk_product_supplier FOREIGN KEY (SUPPLIER_ID) REFERENCES INVENTORY_SUPPLIER(ID)
);

CREATE TABLE INVENTORY_PURCHASE (
    ID           NUMBER(19, 0)    NOT NULL PRIMARY KEY,
    QUANTITY     NUMBER(11, 0)    NOT NULL,
    PRICE        NUMBER(10, 2)    NOT NULL,
    CREATED_AT   TIMESTAMP(6)     NOT NULL,
    PRODUCT_ID   NUMBER(19, 0)    NOT NULL,
    CONSTRAINT fk_purchase_product FOREIGN KEY (PRODUCT_ID) REFERENCES INVENTORY_PRODUCT(ID)
);

CREATE TABLE INVENTORY_SALE (
    ID           NUMBER(19, 0)    NOT NULL PRIMARY KEY,
    QUANTITY     NUMBER(11, 0)    NOT NULL,
    PRICE        NUMBER(10, 2)    NOT NULL,
    CREATED_AT   TIMESTAMP(6)     NOT NULL,
    PRODUCT_ID   NUMBER(19, 0)    NOT NULL,
    CONSTRAINT fk_sale_product FOREIGN KEY (PRODUCT_ID) REFERENCES INVENTORY_PRODUCT(ID)
);



-- View all data 
SELECT * FROM INVENTORY_CATEGORY;
SELECT * FROM INVENTORY_PRODUCT;
SELECT * FROM INVENTORY_PURCHASE;
SELECT * FROM INVENTORY_SALE;
SELECT * FROM INVENTORY_SUPPLIER;






-- Advanced SQL Queries 



-- 1. Total Inventory Value / total value of the stock
SELECT 
    SUM(p.QUANTITY * p.PRICE) AS TOTAL_INVENTORY_VALUE
FROM INVENTORY_PRODUCT p;


-- 2. Stock Value per Category
SELECT 
    c.NAME AS CATEGORY_NAME,
    SUM(p.QUANTITY * p.PRICE) AS CATEGORY_VALUE
FROM INVENTORY_PRODUCT p
JOIN INVENTORY_CATEGORY c ON p.CATEGORY_ID = c.ID
GROUP BY c.NAME
ORDER BY CATEGORY_VALUE DESC;


-- 3. Top 5 Best-Selling Products
SELECT 
    p.NAME AS PRODUCT_NAME,
    SUM(s.QUANTITY) AS TOTAL_SOLD,
    SUM(s.PRICE * s.QUANTITY) AS TOTAL_REVENUE
FROM INVENTORY_SALE s
JOIN INVENTORY_PRODUCT p ON s.PRODUCT_ID = p.ID
GROUP BY p.NAME
ORDER BY TOTAL_SOLD DESC
FETCH FIRST 5 ROWS ONLY;


-- 4. Monthly Sales Trend
SELECT 
    TO_CHAR(s.CREATED_AT, 'YYYY-MM') AS MONTH,
    SUM(s.QUANTITY) AS TOTAL_UNITS,
    SUM(s.PRICE * s.QUANTITY) AS TOTAL_REVENUE
FROM INVENTORY_SALE s
GROUP BY TO_CHAR(s.CREATED_AT, 'YYYY-MM')
ORDER BY MONTH;


-- 5. Low Stock Alert
SELECT 
    p.NAME AS PRODUCT_NAME,
    p.QUANTITY,
    c.NAME AS CATEGORY_NAME,
    sup.NAME AS SUPPLIER_NAME
FROM INVENTORY_PRODUCT p
JOIN INVENTORY_CATEGORY c ON p.CATEGORY_ID = c.ID
JOIN INVENTORY_SUPPLIER sup ON p.SUPPLIER_ID = sup.ID
WHERE p.QUANTITY < 10
ORDER BY p.QUANTITY ASC;


-- 6. Supplier Contribution to Stock
SELECT 
    sup.NAME AS SUPPLIER_NAME,
    SUM(p.QUANTITY) AS TOTAL_UNITS,
    SUM(p.QUANTITY * p.PRICE) AS STOCK_VALUE
FROM INVENTORY_PRODUCT p
JOIN INVENTORY_SUPPLIER sup ON p.SUPPLIER_ID = sup.ID
GROUP BY sup.NAME
ORDER BY STOCK_VALUE DESC;


-- 7. Profit by Product
SELECT 
    p.NAME AS PRODUCT_NAME,
    NVL(SUM(s.QUANTITY * s.PRICE), 0) AS SALES_VALUE,
    NVL(SUM(pr.QUANTITY * pr.PRICE), 0) AS PURCHASE_COST,
    NVL(SUM(s.QUANTITY * s.PRICE), 0) - NVL(SUM(pr.QUANTITY * pr.PRICE), 0) AS PROFIT
FROM INVENTORY_PRODUCT p
LEFT JOIN INVENTORY_SALE s ON p.ID = s.PRODUCT_ID
LEFT JOIN INVENTORY_PURCHASE pr ON p.ID = pr.PRODUCT_ID
GROUP BY p.NAME
ORDER BY PROFIT DESC;


-- 8. Unsold Products
SELECT 
    p.ID, p.NAME
FROM INVENTORY_PRODUCT p
WHERE NOT EXISTS (
    SELECT 1 FROM INVENTORY_SALE s WHERE s.PRODUCT_ID = p.ID
);


-- 9. Most Recent Purchases per Product
SELECT 
    p.NAME AS PRODUCT_NAME,
    pr.QUANTITY,
    pr.PRICE,
    pr.CREATED_AT
FROM INVENTORY_PRODUCT p
JOIN INVENTORY_PURCHASE pr ON p.ID = pr.PRODUCT_ID
WHERE pr.CREATED_AT = (
    SELECT MAX(sub.CREATED_AT)
    FROM INVENTORY_PURCHASE sub
    WHERE sub.PRODUCT_ID = p.ID
);


-- 10. Daily Sales Summary
SELECT 
    TRUNC(s.CREATED_AT) AS SALE_DATE,
    SUM(s.QUANTITY) AS TOTAL_UNITS,
    SUM(s.PRICE * s.QUANTITY) AS TOTAL_REVENUE
FROM INVENTORY_SALE s
GROUP BY TRUNC(s.CREATED_AT)
ORDER BY SALE_DATE DESC;


-- 11. Fastest Selling Products (by average daily sales)
SELECT 
    p.NAME AS PRODUCT_NAME,
    ROUND(SUM(s.QUANTITY) / COUNT(DISTINCT TRUNC(s.CREATED_AT)), 2) AS AVG_UNITS_PER_DAY
FROM INVENTORY_SALE s
JOIN INVENTORY_PRODUCT p ON s.PRODUCT_ID = p.ID
GROUP BY p.NAME
ORDER BY AVG_UNITS_PER_DAY DESC;


-- 12. Products with Negative or Zero Stock (Error Check)
SELECT 
    p.ID,
    p.NAME,
    p.QUANTITY
FROM INVENTORY_PRODUCT p
WHERE p.QUANTITY <= 0;


-- 13. Products Never Purchased
SELECT 
    p.ID, p.NAME
FROM INVENTORY_PRODUCT p
WHERE NOT EXISTS (
    SELECT 1 FROM INVENTORY_PURCHASE pr WHERE pr.PRODUCT_ID = p.ID
);


-- 14. Highest Priced Product in Each Category
SELECT 
    c.NAME AS CATEGORY_NAME,
    p.NAME AS PRODUCT_NAME,
    p.PRICE
FROM INVENTORY_PRODUCT p
JOIN INVENTORY_CATEGORY c ON p.CATEGORY_ID = c.ID
WHERE p.PRICE = (
    SELECT MAX(p2.PRICE)
    FROM INVENTORY_PRODUCT p2
    WHERE p2.CATEGORY_ID = c.ID
);


-- 15. Supplier with Maximum Unique Products
SELECT 
    sup.NAME AS SUPPLIER_NAME,
    COUNT(DISTINCT p.ID) AS UNIQUE_PRODUCTS
FROM INVENTORY_PRODUCT p
JOIN INVENTORY_SUPPLIER sup ON p.SUPPLIER_ID = sup.ID
GROUP BY sup.NAME
ORDER BY UNIQUE_PRODUCTS DESC
FETCH FIRST 1 ROW ONLY;


-- 16. Cumulative Sales Over Time (Running Total)
SELECT 
    TRUNC(s.CREATED_AT) AS SALE_DATE,
    SUM(s.QUANTITY * s.PRICE) AS DAILY_SALES,
    SUM(SUM(s.QUANTITY * s.PRICE)) 
        OVER (ORDER BY TRUNC(s.CREATED_AT)) AS CUMULATIVE_SALES
FROM INVENTORY_SALE s
GROUP BY TRUNC(s.CREATED_AT)
ORDER BY SALE_DATE;


-- 17. Top 3 Products per Category by Sales
SELECT *
FROM (
    SELECT 
        c.NAME AS CATEGORY_NAME,
        p.NAME AS PRODUCT_NAME,
        SUM(s.QUANTITY) AS TOTAL_SOLD,
        RANK() OVER (PARTITION BY c.NAME ORDER BY SUM(s.QUANTITY) DESC) AS RANK_IN_CATEGORY
    FROM INVENTORY_SALE s
    JOIN INVENTORY_PRODUCT p ON s.PRODUCT_ID = p.ID
    JOIN INVENTORY_CATEGORY c ON p.CATEGORY_ID = c.ID
    GROUP BY c.NAME, p.NAME
)
WHERE RANK_IN_CATEGORY <= 3;


-- 18. Average Purchase Price vs Sale Price per Product
SELECT 
    p.NAME AS PRODUCT_NAME,
    ROUND(AVG(DISTINCT pr.PRICE), 2) AS AVG_PURCHASE_PRICE,
    ROUND(AVG(DISTINCT s.PRICE), 2) AS AVG_SALE_PRICE
FROM INVENTORY_PRODUCT p
LEFT JOIN INVENTORY_PURCHASE pr ON p.ID = pr.PRODUCT_ID
LEFT JOIN INVENTORY_SALE s ON p.ID = s.PRODUCT_ID
GROUP BY p.NAME;


-- 19. Most Recently Sold Product
SELECT 
    p.NAME AS PRODUCT_NAME,
    s.QUANTITY,
    s.PRICE,
    s.CREATED_AT
FROM INVENTORY_SALE s
JOIN INVENTORY_PRODUCT p ON s.PRODUCT_ID = p.ID
WHERE s.CREATED_AT = (SELECT MAX(CREATED_AT) FROM INVENTORY_SALE);


-- 20. Supplier with the Highest Sales Revenue
SELECT 
    sup.NAME AS SUPPLIER_NAME,
    SUM(s.QUANTITY * s.PRICE) AS TOTAL_REVENUE
FROM INVENTORY_SALE s
JOIN INVENTORY_PRODUCT p ON s.PRODUCT_ID = p.ID
JOIN INVENTORY_SUPPLIER sup ON p.SUPPLIER_ID = sup.ID
GROUP BY sup.NAME
ORDER BY TOTAL_REVENUE DESC
FETCH FIRST 1 ROW ONLY;


-- 21. Products with Above-Average Sales
SELECT 
    p.NAME AS PRODUCT_NAME,
    SUM(s.QUANTITY) AS TOTAL_SOLD
FROM INVENTORY_PRODUCT p
JOIN INVENTORY_SALE s ON p.ID = s.PRODUCT_ID
GROUP BY p.NAME
HAVING SUM(s.QUANTITY) > (
    SELECT AVG(SUM(s2.QUANTITY))
    FROM INVENTORY_SALE s2
    GROUP BY s2.PRODUCT_ID
);


-- 22. Products with No Supplier Assigned
SELECT 
    p.ID, p.NAME
FROM INVENTORY_PRODUCT p
WHERE p.SUPPLIER_ID IS NULL;


-- 23. Most Popular Category by Sales Revenue
SELECT 
    c.NAME AS CATEGORY_NAME,
    SUM(s.QUANTITY * s.PRICE) AS TOTAL_REVENUE
FROM INVENTORY_SALE s
JOIN INVENTORY_PRODUCT p ON s.PRODUCT_ID = p.ID
JOIN INVENTORY_CATEGORY c ON p.CATEGORY_ID = c.ID
GROUP BY c.NAME
ORDER BY TOTAL_REVENUE DESC
FETCH FIRST 1 ROW ONLY;


-- 24. Daily Sales Growth (Difference from Previous Day)
SELECT 
    SALE_DATE,
    DAILY_SALES,
    DAILY_SALES - LAG(DAILY_SALES) OVER (ORDER BY SALE_DATE) AS GROWTH
FROM (
    SELECT 
        TRUNC(s.CREATED_AT) AS SALE_DATE,
        SUM(s.QUANTITY * s.PRICE) AS DAILY_SALES
    FROM INVENTORY_SALE s
    GROUP BY TRUNC(s.CREATED_AT)
)
ORDER BY SALE_DATE;






-- PL/SQL PROCEDURES


--1
CREATE OR REPLACE PROCEDURE add_category (
    p_id          IN NUMBER,
    p_name        IN NVARCHAR2,
    p_description IN NCLOB
) AS
BEGIN
    INSERT INTO INVENTORY_CATEGORY (ID, NAME, DESCRIPTION)
    VALUES (p_id, p_name, p_description);

    DBMS_OUTPUT.PUT_LINE('Category added successfully: ' || p_name);
END;
/
SET SERVEROUTPUT ON;
EXEC add_category(1, 'Toys', 'Toys for babies');



--2
CREATE OR REPLACE PROCEDURE add_supplier (
    p_id            IN NUMBER,
    p_name          IN NVARCHAR2,
    p_contact       IN NVARCHAR2,
    p_phone         IN NVARCHAR2,
    p_email         IN NVARCHAR2,
    p_address       IN NCLOB
) AS
BEGIN
    INSERT INTO INVENTORY_SUPPLIER (ID, NAME, CONTACT_PERSON, PHONE, EMAIL, ADDRESS)
    VALUES (p_id, p_name, p_contact, p_phone, p_email, p_address);

    DBMS_OUTPUT.PUT_LINE('Supplier added successfully: ' || p_name);
END;
/
EXEC add_supplier(1, 'ABC Electronics', 'John Doe', '1234567890', 'abc@shop.com', 'Dhaka, Bangladesh');



--3
CREATE OR REPLACE PROCEDURE add_product (
    p_id         IN NUMBER,
    p_name       IN NVARCHAR2,
    p_sku        IN NVARCHAR2,
    p_quantity   IN NUMBER,
    p_price      IN NUMBER,
    p_category   IN NUMBER,
    p_supplier   IN NUMBER
) AS
BEGIN
    INSERT INTO INVENTORY_PRODUCT (ID, NAME, SKU, QUANTITY, PRICE, CATEGORY_ID, SUPPLIER_ID)
    VALUES (p_id, p_name, p_sku, p_quantity, p_price, p_category, p_supplier);

    DBMS_OUTPUT.PUT_LINE('Product added successfully: ' || p_name);
END;
/
EXEC add_product(1, 'Laptop', 'SKU-101', 10, 800.00, 1, 1);



-- 4
CREATE OR REPLACE PROCEDURE record_purchase (
    p_id        IN NUMBER,
    p_quantity  IN NUMBER,
    p_price     IN NUMBER,
    p_product   IN NUMBER
) AS
BEGIN
    INSERT INTO INVENTORY_PURCHASE (ID, QUANTITY, PRICE, CREATED_AT, PRODUCT_ID)
    VALUES (p_id, p_quantity, p_price, SYSTIMESTAMP, p_product);

    UPDATE INVENTORY_PRODUCT
    SET QUANTITY = QUANTITY + p_quantity
    WHERE ID = p_product;

    DBMS_OUTPUT.PUT_LINE('Purchase recorded. Stock increased by ' || p_quantity);
END;
/
EXEC record_purchase(1, 5, 750.00, 1);  -- stock increases to 15



-- 5
CREATE OR REPLACE PROCEDURE record_sale (
    p_id        IN NUMBER,
    p_quantity  IN NUMBER,
    p_price     IN NUMBER,
    p_product   IN NUMBER
) AS
    v_current_stock NUMBER;
BEGIN
    SELECT QUANTITY INTO v_current_stock
    FROM INVENTORY_PRODUCT
    WHERE ID = p_product;

    IF v_current_stock < p_quantity THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enough stock for this sale!');
    ELSE
        INSERT INTO INVENTORY_SALE (ID, QUANTITY, PRICE, CREATED_AT, PRODUCT_ID)
        VALUES (p_id, p_quantity, p_price, SYSTIMESTAMP, p_product);

        UPDATE INVENTORY_PRODUCT
        SET QUANTITY = QUANTITY - p_quantity
        WHERE ID = p_product;

        DBMS_OUTPUT.PUT_LINE('Sale recorded. Stock decreased by ' || p_quantity);
    END IF;
END;
/
EXEC record_sale(1, 3, 850.00, 1);  -- stock decreases to 12







-- Functions 


-- Get Current Stock of a Product with their primary key id
CREATE OR REPLACE FUNCTION get_stock (
    p_product_id IN NUMBER
) RETURN NUMBER IS
    v_stock NUMBER;
BEGIN
    SELECT QUANTITY INTO v_stock
    FROM INVENTORY_PRODUCT
    WHERE ID = p_product_id;

    RETURN v_stock;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;  -- product not found
END;
/

SELECT get_stock(28) AS stock FROM dual;




-- Get Total Purchases for a Product

CREATE OR REPLACE FUNCTION get_total_purchases (
    p_product_id IN NUMBER
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(QUANTITY), 0)
    INTO v_total
    FROM INVENTORY_PURCHASE
    WHERE PRODUCT_ID = p_product_id;

    RETURN v_total;
END;
/

SELECT get_total_purchases(1) AS total_purchased FROM dual;



-- Get Total Sales for a Product

CREATE OR REPLACE FUNCTION get_total_sales (
    p_product_id IN NUMBER
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(QUANTITY), 0)
    INTO v_total
    FROM INVENTORY_SALE
    WHERE PRODUCT_ID = p_product_id;

    RETURN v_total;
END;
/

SELECT get_total_sales(1) AS total_sold FROM dual;




-- Get Product Value in Stock (Quantity × Price) 

CREATE OR REPLACE FUNCTION get_product_value (
    p_product_id IN NUMBER
) RETURN NUMBER IS
    v_value NUMBER;
BEGIN
    SELECT QUANTITY * PRICE
    INTO v_value
    FROM INVENTORY_PRODUCT
    WHERE ID = p_product_id;

    RETURN v_value;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

SELECT get_product_value(1) AS stock_value FROM dual;



-- Get Supplier Name for a Product

CREATE OR REPLACE FUNCTION get_supplier_name (
    p_product_id IN NUMBER
) RETURN NVARCHAR2 IS
    v_supplier NVARCHAR2(150);
BEGIN
    SELECT S.NAME
    INTO v_supplier
    FROM INVENTORY_PRODUCT P
    JOIN INVENTORY_SUPPLIER S ON P.SUPPLIER_ID = S.ID
    WHERE P.ID = p_product_id;

    RETURN v_supplier;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'No Supplier';
END;
/

SELECT get_supplier_name(1) AS supplier FROM dual;





-- cursor  

-- List all products with stock
DECLARE
    CURSOR c_products IS
        SELECT ID, NAME, QUANTITY, PRICE FROM INVENTORY_PRODUCT;

    v_id        INVENTORY_PRODUCT.ID%TYPE;
    v_name      INVENTORY_PRODUCT.NAME%TYPE;
    v_quantity  INVENTORY_PRODUCT.QUANTITY%TYPE;
    v_price     INVENTORY_PRODUCT.PRICE%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Product List ---');
    OPEN c_products;
    LOOP
        FETCH c_products INTO v_id, v_name, v_quantity, v_price;
        EXIT WHEN c_products%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Name: ' || v_name ||
                             ', Stock: ' || v_quantity || ', Price: ' || v_price);
    END LOOP;
    CLOSE c_products;
END;
/

-- Show sales report for each product
DECLARE
    CURSOR c_sales IS
        SELECT P.NAME, NVL(SUM(S.QUANTITY), 0) AS TOTAL_SOLD
        FROM INVENTORY_PRODUCT P
        LEFT JOIN INVENTORY_SALE S ON P.ID = S.PRODUCT_ID
        GROUP BY P.NAME;

    v_name  INVENTORY_PRODUCT.NAME%TYPE;
    v_total NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Sales Report ---');
    OPEN c_sales;
    LOOP
        FETCH c_sales INTO v_name, v_total;
        EXIT WHEN c_sales%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Product: ' || v_name || ' | Total Sold: ' || v_total);
    END LOOP;
    CLOSE c_sales;
END;
/

-- Purchases of a given product
DECLARE
    CURSOR c_purchases (p_product_id NUMBER) IS
        SELECT ID, QUANTITY, PRICE, CREATED_AT
        FROM INVENTORY_PURCHASE
        WHERE PRODUCT_ID = p_product_id;

    v_id        INVENTORY_PURCHASE.ID%TYPE;
    v_quantity  INVENTORY_PURCHASE.QUANTITY%TYPE;
    v_price     INVENTORY_PURCHASE.PRICE%TYPE;
    v_date      INVENTORY_PURCHASE.CREATED_AT%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Purchases for Product ID 1 ---');
    OPEN c_purchases(1);
    LOOP
        FETCH c_purchases INTO v_id, v_quantity, v_price, v_date;
        EXIT WHEN c_purchases%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Purchase ID: ' || v_id || ', Qty: ' || v_quantity ||
                             ', Price: ' || v_price || ', Date: ' || v_date);
    END LOOP;
    CLOSE c_purchases;
END;
/

-- Products with low stock
DECLARE
    CURSOR c_low_stock IS
        SELECT NAME, QUANTITY FROM INVENTORY_PRODUCT WHERE QUANTITY < 5;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Low Stock Products ---');
    FOR rec IN c_low_stock LOOP
        DBMS_OUTPUT.PUT_LINE('Low Stock -> ' || rec.NAME || ': ' || rec.QUANTITY || ' units left');
    END LOOP;
END;
/

-- Product and Supplier info
DECLARE
    CURSOR c_product_supplier IS
        SELECT P.NAME AS PRODUCT_NAME, S.NAME AS SUPPLIER_NAME
        FROM INVENTORY_PRODUCT P
        JOIN INVENTORY_SUPPLIER S ON P.SUPPLIER_ID = S.ID;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Product and Supplier Info ---');
    FOR rec IN c_product_supplier LOOP
        DBMS_OUTPUT.PUT_LINE('Product: ' || rec.PRODUCT_NAME || ' | Supplier: ' || rec.SUPPLIER_NAME);
    END LOOP;
END;
/




-- TRIGGERS

-- Auto update stock on purchase
CREATE OR REPLACE TRIGGER trg_after_purchase
AFTER INSERT ON INVENTORY_PURCHASE
FOR EACH ROW
BEGIN
    UPDATE INVENTORY_PRODUCT
    SET QUANTITY = QUANTITY + :NEW.QUANTITY
    WHERE ID = :NEW.PRODUCT_ID;
END;
/

-- Auto update stock on sale
CREATE OR REPLACE TRIGGER trg_after_sale
AFTER INSERT ON INVENTORY_SALE
FOR EACH ROW
BEGIN
    UPDATE INVENTORY_PRODUCT
    SET QUANTITY = QUANTITY - :NEW.QUANTITY
    WHERE ID = :NEW.PRODUCT_ID;
END;
/

-- Prevent negative stock
CREATE OR REPLACE TRIGGER trg_check_stock
BEFORE INSERT ON INVENTORY_SALE
FOR EACH ROW
DECLARE
    v_quantity NUMBER;
BEGIN
    SELECT QUANTITY INTO v_quantity
    FROM INVENTORY_PRODUCT
    WHERE ID = :NEW.PRODUCT_ID;

    IF v_quantity < :NEW.QUANTITY THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enough stock available!');
    END IF;
END;
/

-- Default timestamp for purchase
CREATE OR REPLACE TRIGGER trg_purchase_default_time
BEFORE INSERT ON INVENTORY_PURCHASE
FOR EACH ROW
BEGIN
    IF :NEW.CREATED_AT IS NULL THEN
        :NEW.CREATED_AT := SYSTIMESTAMP;
    END IF;
END;
/

-- Default timestamp for sale
CREATE OR REPLACE TRIGGER trg_sale_default_time
BEFORE INSERT ON INVENTORY_SALE
FOR EACH ROW
BEGIN
    IF :NEW.CREATED_AT IS NULL THEN
        :NEW.CREATED_AT := SYSTIMESTAMP;
    END IF;
END;
/

