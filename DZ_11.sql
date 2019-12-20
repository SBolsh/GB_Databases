-- ������� 1.


CREATE TABLE Logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    created_at datetime DEFAULT CURRENT_TIMESTAMP,
    table_name varchar(50) NOT NULL,
    row_id INT UNSIGNED NOT NULL,
    row_name varchar(255)
) ENGINE = Archive;

CREATE TRIGGER prod_insert AFTER INSERT ON products
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "products", NEW.id, NEW.name);
END;

CREATE TRIGGER users_insert AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "users", NEW.id, NEW.name);
END;

CREATE TRIGGER cat_insert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "catalogs", NEW.id, NEW.name);
END;

-- ������� 2.

CREATE DATABASE million;

USE million;

CREATE TABLE samples (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT '��� ����������',
  birthday_at DATE COMMENT '���� ��������',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = '����������';

INSERT INTO samples (name, birthday_at) VALUES
  ('��������', '1990-10-05'),
  ('�������', '1984-11-12'),
  ('���������', '1985-05-20'),
  ('������', '1988-02-14'),
  ('����', '1998-01-12'),
  ('�����', '1992-08-29'),
  ('�������', '1994-03-17'),
  ('�����', '1981-07-10'),
  ('��������', '1988-06-12'),
  ('���������', '1992-09-20');
 
SELECT * FROM samples;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT '��� ����������',
  birthday_at DATE COMMENT '���� ��������',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = '����������';


INSERT INTO users SELECT * FROM
  samples AS fst,
  samples AS snd,
  samples AS thd,
  samples AS fth,
  samples AS fif,
  samples AS sth;
 
-- ������� 3

HINCRBY addresses '192.168.0.1' 1
HGETALL addresses

HINCRBY addresses '192.168.0.2' 1
HGETALL addresses

HGET addresses '192.168.0.1'
  
-- ������� 4

HSET emails 'max' 'max@gmail.com'
HSET emails 'leo' 'leo@gmail.com'
HSET emails 'ron' 'ron@gmail.com'

HGET emails 'leo'

HSET users 'max@gmail.com' 'max'
HSET users 'leo@gmail.com' 'leo'
HSET users 'ron@gmail.com' 'ron'

HGET users 'ron@gmail.com'

-- ������� 5

use shop

db.createCollection('catalogs')
db.createCollection('products')

db.catalogs.insert({name: '����������'})
db.catalogs.insert({name: '���.�����'})
db.catalogs.insert({name: '����������'})

db.products.insert(
  {
    name: 'Intel Core i3-8100',
    description: '��������� ��� ���������� ������������ �����������, ���������� �� ��������� Intel.',
    price: 7890.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'Intel Core i5-7400',
    description: '��������� ��� ���������� ������������ �����������, ���������� �� ��������� Intel.',
    price: 12700.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'ASUS ROG MAXIMUS X HERO',
    description: '����������� ����� ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX',
    price: 19310.00,
    catalog_id: new ObjectId("5b56c74788f700498cbdc56c")
  }
);

db.products.find()

db.products.find({catalog_id: ObjectId("5b56c73f88f700498cbdc56bdb")})

