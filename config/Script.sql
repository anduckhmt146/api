SET GLOBAL log_bin_trust_function_creators = 1;
SET SESSION SQL_MODE='ALLOW_INVALID_DATES';
DROP DATABASE IF EXISTS bkzone_2022;
CREATE DATABASE bkzone_2022;
USE bkzone_2022;
DROP TABLE IF EXISTS `OrderDetail`;
DROP TABLE IF EXISTS `Orders`;
DROP TABLE IF EXISTS `Comment`;
DROP TABLE IF EXISTS `News`;
DROP TABLE IF EXISTS `Product`;
DROP TABLE IF EXISTS `Admin`;
DROP TABLE IF EXISTS `Address`;
DROP TABLE IF EXISTS `Customer`;
CREATE TABLE `Customer` (
  `id` int AUTO_INCREMENT,
  `first_name` varchar(255),
  `last_name` varchar(255),
  `phone` varchar(255),
  `email` varchar(255),
  `birthday` timestamp,
  `username` varchar(255),
  `password` varchar(255),
  `address` varchar(255),
  PRIMARY KEY (id)
);
CREATE TABLE `Product` (
  `id` int AUTO_INCREMENT,
  `name` varchar(255),
  `thumbnail` varchar(255),
  `price` integer,
  `quantity` integer,
  `brand` varchar(255),
  `cpu` varchar(255),
  `gpu` varchar(255),
  `ram` varchar(255),
  `disk` varchar(255),
  `screen_size` varchar(255),
  `screen_tech` varchar(255),
  `weight` integer,
  `os` varchar(255),
  `overall_rating` float,
  `num_rates` integer,
  `description` varchar(255),
  PRIMARY KEY (id)
);
CREATE TABLE `Orders` (
  `id` int AUTO_INCREMENT,
  `customer_id` int,
  `address` varchar(255),
  `receiverName` varchar(255),
  `phoneNumber`  varchar(255),
  `paymentMethod` varchar(255),
  `create_at` Datetime,
  `last_update` timestamp,
  `status` varchar(255),
  `total_product` integer DEFAULT 0,
  `total_order_money` integer DEFAULT 0,
   PRIMARY KEY(id)
);
CREATE TABLE `OrderDetail` (
  `order_id` int,
  `product_id` int,
  `quantity` integer DEFAULT 0,
  `total_money` integer  DEFAULT 0,
  PRIMARY KEY (`order_id`, `product_id`)
);
CREATE TABLE `Comment` (
  `id` int AUTO_INCREMENT,
  `product_id` int,
  `customer_id` int,
  `admin_id` int,
  `comment` varchar(255),
  `updated_at` timestamp,
  `num_rate` int,
  `status` varchar(255),
  PRIMARY KEY (id)
);
CREATE TABLE `Admin` (
  `id` int AUTO_INCREMENT,
  `first_name` varchar(255),
  `last_name` varchar(255),
  `phone` varchar(255),
  `email` varchar(255),
  `username` varchar(255),
  `password` varchar(255),
  PRIMARY KEY (id)
);
CREATE TABLE `News` (
  `id` int AUTO_INCREMENT,
  `admin_id` int,
  `title` varchar(255),
  `thumbnail` varchar(255),
  `content` longtext,
  PRIMARY KEY(id)
);

CREATE TABLE `Address` (
	`id` int AUTO_INCREMENT, 
	`user_id` int , 
	`city` varchar(255), 
	`district` varchar(255) , 
	`ward` varchar(255), 
	`specificAddress` varchar(255), 
	`phoneNumber` varchar(255) , 
	`receiverName` varchar(255) , 
	`type` BIT,

	PRIMARY KEY(id)

);
CREATE TABLE `Resource` (
  `id` int not null auto_increment,
  `name` varchar(255),
  `data` longtext,
  PRIMARY KEY(id)
);

CREATE TABLE Cart(
	`id` int AUTO_INCREMENT, 
	`user_id` int, 
	`quantity` int DEFAULT  0, 
	`total` int DEFAULT  0,

	PRIMARY KEY(id)
);

CREATE TABLE Cart_item(
	`cart_id` int, 
	`product_id` int, 
	`quantity` int, 
	`total` int,
  `isSelected` int DEFAULT 0,

	PRIMARY KEY(cart_id, product_id)
);


ALTER TABLE `Cart` ADD FOREIGN KEY (`user_id`) REFERENCES `Customer` (`id`) ON DELETE CASCADE;

ALTER TABLE `Cart_item` ADD FOREIGN KEY (`cart_id`) REFERENCES `Cart` (`id`) ON DELETE CASCADE;

ALTER TABLE `Cart_item` ADD FOREIGN KEY (`product_id`) REFERENCES `Product` (`id`) ON DELETE CASCADE;

ALTER TABLE `Orders` ADD FOREIGN KEY (`customer_id`) REFERENCES `Customer` (`id`) ON DELETE CASCADE;

ALTER TABLE `OrderDetail` ADD FOREIGN KEY (`order_id`) REFERENCES `Orders` (`id`) ON DELETE CASCADE;

ALTER TABLE `OrderDetail` ADD FOREIGN KEY (`product_id`) REFERENCES `Product` (`id`) ON DELETE CASCADE;

ALTER TABLE `Comment` ADD FOREIGN KEY (`product_id`) REFERENCES `Product` (`id`) ON DELETE CASCADE;

ALTER TABLE `Comment` ADD FOREIGN KEY (`customer_id`) REFERENCES `Customer` (`id`) ON DELETE CASCADE;

ALTER TABLE `Comment` ADD FOREIGN KEY (`admin_id`) REFERENCES `Admin` (`id`) ON DELETE CASCADE;

ALTER TABLE `News` ADD FOREIGN KEY (`admin_id`) REFERENCES `Admin` (`id`) ON DELETE CASCADE;

ALTER TABLE `Address` ADD FOREIGN KEY (`user_id`) REFERENCES `Customer` (`id`) ON DELETE CASCADE;

-- Trigger M???i l???n t???o 1 t??i kho???n m???i th?? s??? t??? t???o 1 gi??? h??ng 
DROP TRIGGER IF EXISTS `tri_create_cart_after_signup`;
DELIMITER $$
CREATE TRIGGER tri_create_cart_after_signup
    AFTER INSERT
    ON Customer FOR EACH ROW
BEGIN
    INSERT INTO Cart(user_id) VALUES (New.id) ;
END$$
DELIMITER ;

-- trigger c???p nh???t l???i s??? l?????ng s???n ph???m trong gi??? h??ng m???i khi insert v??o gi??? h??ng
DROP TRIGGER IF EXISTS `tri_cart_item_insert`;
DELIMITER $$
CREATE TRIGGER tri_cart_item_insert
    BEFORE INSERT
    ON Cart_item FOR EACH ROW
BEGIN
	  SET New.total = New.quantity * (select Product.price FROM Product WHERE NEW.product_id = Product.id); 
    UPDATE Cart Set Cart.quantity = Cart.quantity + New.quantity, Cart.total = Cart.total + New.total WHERE New.cart_id = Cart.id ;
END$$
DELIMITER ;


-- trigger c???p nh???t l???i s??? l?????ng s???n ph???m trong gi??? h??ng m???i khi insert v??o gi??? h??ng
DROP TRIGGER IF EXISTS `tri_cart_item_delete`;
DELIMITER $$
CREATE TRIGGER tri_cart_item_delete
    AFTER DELETE
    ON Cart_item FOR EACH ROW
BEGIN
    UPDATE Cart Set Cart.quantity = Cart.quantity - OLD.quantity, Cart.total = Cart.total - OLD.total WHERE OLD.cart_id = Cart.id ;
END$$
DELIMITER ;


-- trigger c???p nh???t l???i t???ng s??? l?????ng s???n ph???m, t???ng ti???n m???i khi c???p nh???t gi??? h??ng
DROP TRIGGER IF EXISTS `tri_cart_item_update`;
DELIMITER $$

CREATE TRIGGER tri_cart_item_update
    BEFORE UPDATE
    ON Cart_item FOR EACH ROW
BEGIN
    IF OLD.quantity <> new.quantity THEN
	    Set new.total = new.quantity * (select Product.price FROM Product WHERE new.product_id = Product.id); 
    END IF ;
END$$
DELIMITER ;


-- trigger c???p nh???t t???ng s??? l?????ng s???n ph???m, t???ng ti???n m???i khi ?????t h??ng
DROP TRIGGER IF EXISTS `tri_order_update`;
DELIMITER $$

CREATE TRIGGER tri_order_update
    BEFORE INSERT
    ON OrderDetail FOR EACH ROW
BEGIN
      SET New.total_money = New.quantity * (select Product.price FROM Product WHERE New.product_id = Product.id); 
	    UPDATE Orders set Orders.total_product = Orders.total_product + NEW.quantity, Orders.total_order_money = Orders.total_order_money + NEW.total_money WHERE Orders.id = NEW.order_id;
END$$
DELIMITER ;




INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Pro','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',24279787,22,'Apple','Intel Core i5 3.1GHz','Intel Iris Plus Graphics 650','8GB','256GB SSD','13.3','IPS Panel Retina Display 2560x1600',1.37,'macOS',1,795);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire 3','https://anphat.com.vn/media/product/39134_35206_1.png',29843996,25,'Acer','AMD A9-Series 9420 3GHz','AMD Radeon R5','4GB','500GB HDD','15.6','1366x768',2.1,'Windows',5,312);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Pro','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',31172929,20,'Apple','Intel Core i7 2.2GHz','Intel Iris Pro Graphics','16GB','256GB Flash Storage','15.4','IPS Panel Retina Display 2880x1800',2.04,'Mac OS',2,758);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook Macbook Air','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',29012085,13,'Apple','Intel Core i5 1.8GHz','Intel HD Graphics 6000','8GB','256GB Flash Storage','13.3','1440x900',1.34,'macOS',2,915);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Ultrabook ZenBook UX430UN','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',46780635,14,'Asus','Intel Core i7 8550U 1.8GHz','Nvidia GeForce MX150','16GB','512GB SSD','14','Full HD 1920x1080',1.3,'Windows',1,172);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Ultrabook Swift 3','https://anphat.com.vn/media/product/39134_35206_1.png',47378628,16,'Acer','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','8GB','256GB SSD','14','IPS Panel Full HD 1920x1080',1.6,'Windows',0,704);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 250 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',48274972,10,'HP','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','4GB','500GB HDD','15.6','1366x768',1.86,'No OS',4,54);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 250 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',41290194,13,'HP','Intel Core i3 6006U 2GHz','Intel HD Graphics 520','4GB','500GB HDD','15.6','Full HD 1920x1080',1.86,'No OS',1,540);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Pro','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',36356939,10,'Apple','Intel Core i7 2.8GHz','AMD Radeon Pro 555','16GB','256GB SSD','15.4','IPS Panel Retina Display 2880x1800',1.83,'macOS',1,949);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3567','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',46044776,21,'Dell','Intel Core i3 6006U 2GHz','AMD Radeon R5 M430','4GB','256GB SSD','15.6','Full HD 1920x1080',2.2,'Windows',1,239);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook 12"','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',22021377,6,'Apple','Intel Core M m3 1.2GHz','Intel HD Graphics 615','8GB','256GB SSD','12','IPS Panel Retina Display 2304x1440',0.92,'macOS',2,261);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Pro','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',28475687,26,'Apple','Intel Core i5 2.3GHz','Intel Iris Plus Graphics 640','8GB','256GB SSD','13.3','IPS Panel Retina Display 2560x1600',1.37,'macOS',4,791);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3567','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',39812301,14,'Dell','Intel Core i7 7500U 2.7GHz','AMD Radeon R5 M430','8GB','256GB SSD','15.6"','Full HD 1920x1080',2.2,'Windows',1,32);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Pro','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',47586012,10,'Apple','Intel Core i7 2.9GHz','AMD Radeon Pro 560','16GB','512GB SSD','15.4"','IPS Panel Retina Display 2880x1800',1.83,'macOS',5,115);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Notebook IdeaPad 320-15IKB','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',34465581,27,'Lenovo','Intel Core i3 7100U 2.4GHz','Nvidia GeForce 940MX','8GB','1TB HDD','15.6"','Full HD 1920x1080',2.2,'No OS',1,539);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Ultrabook XPS 13','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',27432627,21,'Dell','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','8GB','128GB SSD','13.3"','IPS Panel Full HD / Touchscreen 1920x1080',1.22,'Windows',3,217);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Netbook Vivobook E200HA','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',42040436,20,'Asus','Intel Atom x5-Z8350 1.44GHz','Intel HD Graphics 400','2GB','32GB Flash Storage','11.6"','1366x768',0.98,'Windows',5,106);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Gaming Legion Y520-15IKBN','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',37186008,20,'Lenovo','Intel Core i5 7300HQ 2.5GHz','Nvidia GeForce GTX 1050','8GB','128GB SSD + 1TB HDD','15.6"','IPS Panel Full HD 1920x1080',2.5,'Windows',1,811);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 255 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',49932005,6,'HP','AMD E-Series E2-9000e 1.5GHz','AMD Radeon R2','4GB','500GB HDD','15.6"','1366x768',1.86,'No OS',2,749);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell 2 in 1 Convertible Inspiron 5379','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',23879508,16,'Dell','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','8GB','256GB SSD','13.3"','Full HD / Touchscreen 1920x1080',1.62,'Windows',4,973);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Ultrabook 15-BS101nv (i7-8550U/8GB/256GB/FHD/W10)','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',24243017,8,'HP','Intel Core i7 8550U 1.8GHz','Intel HD Graphics 620','8GB','256GB SSD','15.6"','Full HD 1920x1080',1.91,'Windows',3,882);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3567','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',43834134,25,'Dell','Intel Core i3 6006U 2GHz','Intel HD Graphics 520','4GB','1TB HDD','15.6"','1366x768',2.3,'Windows',4,462);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Air','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',43786919,28,'Apple','Intel Core i5 1.6GHz','Intel HD Graphics 6000','8GB','128GB Flash Storage','13.3"','1440x900',1.35,'Mac OS',5,263);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 5570','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',28313252,23,'Dell','Intel Core i5 8250U 1.6GHz','AMD Radeon 530','8GB','256GB SSD','15.6"','Full HD 1920x1080',2.2,'Windows',5,587);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Ultrabook Latitude 5590','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',42968995,23,'Dell','Intel Core i7 8650U 1.9GHz','Intel UHD Graphics 620','8GB','256GB SSD + 256GB SSD','15.6"','Full HD 1920x1080',1.88,'Windows',3,89);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook ProBook 470','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',44767118,8,'HP','Intel Core i5 8250U 1.6GHz','Nvidia GeForce 930MX','8GB','1TB HDD','17.3"','Full HD 1920x1080',2.5,'Windows',1,14);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Chuwi Notebook LapBook 15.6"','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',44664915,25,'Chuwi','Intel Atom x5-Z8300 1.44GHz','Intel HD Graphics','4GB','64GB Flash Storage','15.6"','Full HD 1920x1080',1.89,'Windows',5,799);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook E402WA-GA010T (E2-6110/2GB/32GB/W10)','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',39988801,5,'Asus','AMD E-Series E2-6110 1.5GHz','AMD Radeon R2','2GB','32GB Flash Storage','14.0"','1366x768',1.65,'Windows',1,120);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 17-ak001nv (A6-9220/4GB/500GB/Radeon','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',24062620,29,'HP','AMD A6-Series 9220 2.5GHz','AMD Radeon 530','4GB','500GB HDD','17.3"','Full HD 1920x1080',2.71,'Windows',0,769);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Ultrabook XPS 13','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',42506906,13,'Dell','Intel Core i7 8550U 1.8GHz','Intel UHD Graphics 620','16GB','512GB SSD','13.3"','Touchscreen / Quad HD+ 3200x1800',1.2,'Windows',0,118);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Air','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',48138234,23,'Apple','Intel Core i5 1.6GHz','Intel HD Graphics 6000','8GB','256GB Flash Storage','13.3"','1440x900',1.35,'Mac OS',3,143);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Notebook IdeaPad 120S-14IAP','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',32045046,11,'Lenovo','Intel Celeron Dual Core N3350 1.1GHz','Intel HD Graphics 500','4GB','64GB Flash Storage','14.0"','1366x768',1.44,'Windows',5,270);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire 3','https://anphat.com.vn/media/product/39134_35206_1.png',47139700,22,'Acer','Intel Core i3 7130U 2.7GHz','Intel HD Graphics 620','4GB','1TB HDD','15.6"','1366x768',2.1,'Linux',1,369);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 5770','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',39615468,7,'Dell','Intel Core i5 8250U 1.6GHz','AMD Radeon 530','8GB','128GB SSD + 1TB HDD','17.3"','IPS Panel Full HD 1920x1080',2.8,'Windows',4,899);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 250 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',33407263,17,'HP','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','4GB','1TB HDD','15.6"','1366x768',1.86,'Windows',3,128);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook ProBook 450','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',37869526,8,'HP','Intel Core i5 8250U 1.6GHz','Nvidia GeForce 930MX','8GB','256GB SSD','15.6"','Full HD 1920x1080',2.1,'Windows',0,609);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook X540UA-DM186 (i3-6006U/4GB/1TB/FHD/Linux)','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',32064837,29,'Asus','Intel Core i3 6006U 2GHz','Intel HD Graphics 620','4GB','1TB HDD','15.6"','Full HD 1920x1080',2,'Linux',5,99);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Gaming Inspiron 7577','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',48799281,5,'Dell','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1060','16GB','256GB SSD + 1TB HDD','15.6"','IPS Panel Full HD 1920x1080',2.65,'Windows',3,989);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook X542UQ-GO005 (i5-7200U/8GB/1TB/GeForce','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',41043128,5,'Asus','Intel Core i5 7200U 2.5GHz','Nvidia GeForce 940MX','8GB','1TB HDD','15.6"','1366x768',2.3,'Linux',3,383);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire A515-51G','https://anphat.com.vn/media/product/39134_35206_1.png',46707463,14,'Acer','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','4GB','256GB SSD','15.6"','IPS Panel Full HD 1920x1080',2.2,'Windows',2,531);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell 2 in 1 Convertible Inspiron 7773','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',34076703,6,'Dell','Intel Core i5 8250U 1.6GHz','Nvidia GeForce 150MX','12GB','1TB HDD','17.3"','Full HD / Touchscreen 1920x1080',2.77,'Windows',2,546);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook Pro','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',42017075,18,'Apple','Intel Core i5 2.0GHz','Intel Iris Graphics 540','8GB','256GB SSD','13.3"','IPS Panel Retina Display 2560x1600',1.37,'macOS',4,949);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Notebook IdeaPad 320-15ISK','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',27107572,22,'Lenovo','Intel Core i3 6006U 2GHz','Intel HD Graphics 520','4GB','128GB SSD','15.6"','1366x768',2.2,'No OS',4,94);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Gaming Rog Strix','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',44837743,22,'Asus','AMD Ryzen 1700 3GHz','AMD Radeon RX 580','8GB','256GB SSD + 1TB HDD','17.3"','Full HD 1920x1080',3.2,'Windows',5,258);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3567','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',29522368,22,'Dell','Intel Core i5 7200U 2.5GHz','AMD Radeon R5 M430','4GB','256GB SSD','15.6"','Full HD 1920x1080',2.3,'Windows',4,472);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook X751NV-TY001T (N4200/4GB/1TB/GeForce','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',34098579,8,'Asus','Intel Pentium Quad Core N4200 1.1GHz','Nvidia GeForce 920MX','4GB','1TB HDD','17.3"','1366x768',2.8,'Windows',0,573);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo 2 in 1 Convertible Yoga Book','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',40967303,6,'Lenovo','Intel Atom x5-Z8550 1.44GHz','Intel HD Graphics 400','4GB','64GB Flash Storage','10.1"','IPS Panel Touchscreen 1920x1200',0.69,'Android',4,721);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire A515-51G','https://anphat.com.vn/media/product/39134_35206_1.png',36236075,26,'Acer','Intel Core i7 8550U 1.8GHz','Nvidia GeForce MX150','8GB','256GB SSD','15.6"','IPS Panel Full HD 1920x1080',2.2,'Windows',0,406);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 255 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',39352807,25,'HP','AMD A6-Series 9220 2.5GHz','AMD Radeon R4 Graphics','4GB','256GB SSD','15.6"','Full HD 1920x1080',1.86,'Windows',3,61);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook ProBook 430','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',38078778,10,'HP','Intel Core i7 8550U 1.8GHz','Intel UHD Graphics 620','8GB','512GB SSD','13.3"','Full HD 1920x1080',1.49,'Windows',4,491);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire 3','https://anphat.com.vn/media/product/39134_35206_1.png',33447230,17,'Acer','Intel Core i3 7100U 2.4GHz','Intel HD Graphics 620','4GB','1TB HDD','15.6"','1366x768',2.4,'Windows',3,331);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3576','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',33276384,18,'Dell','Intel Core i7 8550U 1.8GHz','AMD Radeon 520','8GB','256GB SSD','15.6"','Full HD 1920x1080',2.13,'Windows',0,764);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 15-bs002nv (i3-6006U/4GB/128GB/FHD/W10)','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',21859239,8,'HP','Intel Core i3 6006U 2GHz','Intel HD Graphics 520','4GB','128GB SSD','15.6"','Full HD 1920x1080',1.91,'Windows',5,841);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook VivoBook Max','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',36201633,11,'Asus','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','4GB','256GB SSD','15.6"','1366x768',2,'Windows',0,593);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('MSI Gaming GS73VR 7RG','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',45768410,17,'MSI','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1070','16GB','256GB SSD + 2TB HDD','17.3"','Full HD 1920x1080',2.43,'Windows',4,406);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook X541UA-DM1897 (i3-6006U/4GB/256GB/FHD/Linux)','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',29107227,29,'Asus','Intel Core i3 6006U 2GHz','Intel HD Graphics 520','4GB','256GB SSD','15.6"','Full HD 1920x1080',2,'Linux',4,286);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 5770','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',33630584,8,'Dell','Intel Core i7 8550U 1.8GHz','AMD Radeon 530','16GB','256GB SSD + 2TB HDD','17.3"','Full HD 1920x1080',2.8,'Windows',2,550);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Ultrabook Vostro 5471','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',40780604,7,'Dell','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','8GB','256GB SSD','14.0"','Full HD 1920x1080',1.7,'Windows',1,85);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Notebook IdeaPad 520S-14IKB','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',26601516,17,'Lenovo','Intel Core i3 7130U 2.7GHz','Intel HD Graphics 620','8GB','256GB SSD','14.0"','IPS Panel Full HD 1920x1080',1.7,'No OS',0,29);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook UX410UA-GV350T (i5-8250U/8GB/256GB/FHD/W10)','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',26223059,7,'Asus','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','8GB','256GB SSD','14.0"','Full HD 1920x1080',1.4,'Windows',5,837);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 250 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',21699828,10,'HP','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','8GB','256GB SSD','15.6"','Full HD 1920x1080',1.86,'Windows',2,531);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Ultrabook ZenBook Pro','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',26579662,26,'Asus','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1050 Ti','16GB','512GB SSD','15.6"','Full HD 1920x1080',1.8,'Windows',2,154);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 250 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',34146136,7,'HP','Intel Core i3 6006U 2GHz','AMD Radeon 520','4GB','500GB HDD','15.6"','1366x768',1.86,'Windows',4,300);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook Stream 14-AX040wm','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',35789412,8,'HP','Intel Celeron Dual Core N3060 1.6GHz','Intel HD Graphics 400','4GB','32GB SSD','14.0"','1366x768',1.44,'Windows',4,386);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Notebook V310-15ISK (i5-7200U/4GB/1TB/FHD/W10)','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',34739275,30,'Lenovo','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','4GB','1TB HDD','15.6"','Full HD 1920x1080',1.9,'Windows',4,53);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Gaming FX753VE-GC093 (i7-7700HQ/12GB/1TB/GeForce','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',40327989,9,'Asus','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1050 Ti','12GB','1TB HDD','17.3"','Full HD 1920x1080',3,'Linux',0,239);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Microsoft Ultrabook Surface Laptop','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',43193227,22,'Microsoft','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','4GB','128GB SSD','13.5"','Touchscreen 2256x1504',1.252,'Windows',2,901);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Ultrabook Inspiron 5370','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',33927995,27,'Dell','Intel Core i7 8550U 1.8GHz','AMD Radeon 530','8GB','256GB SSD','13.3"','IPS Panel Full HD 1920x1080',1.4,'Windows',0,395);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 5570','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',49050226,30,'Dell','Intel Core i7 8550U 1.8GHz','AMD Radeon 530','8GB','256GB SSD','15.6"','Full HD 1920x1080',2.2,'Windows',5,42);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('MSI Gaming GL72M 7RDX','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',40301451,18,'MSI','Intel Core i5 7300HQ 2.5GHz','Nvidia GeForce GTX 1050','8GB','128GB SSD + 1TB HDD','17.3"','Full HD 1920x1080',2.7,'Windows',0,223);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire E5-475','https://anphat.com.vn/media/product/39134_35206_1.png',31227683,21,'Acer','Intel Core i3 6006U 2GHz','Intel HD Graphics 520','8GB','1TB HDD','14.0"','1366x768',2.1,'Windows',1,178);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Gaming FX503VD-E4022T (i7-7700HQ/8GB/1TB/GeForce','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',46598879,6,'Asus','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1050','8GB','1TB HDD','15.6"','Full HD 1920x1080',2.2,'Windows',1,603);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Notebook IdeaPad 320-15IKBN','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',25217523,8,'Lenovo','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','8GB','2TB HDD','15.6"','Full HD 1920x1080',2.2,'No OS',2,300);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 5570','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',35781853,8,'Dell','Intel Core i7 8550U 1.8GHz','Intel UHD Graphics 620','8GB','128GB SSD + 1TB HDD','15.6"','Full HD 1920x1080',2.02,'Windows',1,627);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire A515-51G-32MX','https://anphat.com.vn/media/product/39134_35206_1.png',47913469,22,'Acer','Intel Core i3 7130U 2.7GHz','Nvidia GeForce MX130','4GB','1TB HDD','15.6"','Full HD 1920x1080',2.2,'Windows',0,640);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook ProBook 470','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',31089934,22,'HP','Intel Core i5 8250U 1.6GHz','Nvidia GeForce 930MX','8GB','128GB SSD + 1TB HDD','17.3"','Full HD 1920x1080',2.5,'Windows',0,705);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Ultrabook Latitude 5590','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',30394829,28,'Dell','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','8GB','256GB SSD','15.6"','IPS Panel Full HD 1920x1080',1.88,'Windows',1,276);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Apple Ultrabook MacBook 12"','https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/Uploads/images/2015/Tin-Tuc/QuanLNH2/macbook-pro-14-4.JPG',35888765,14,'Apple','Intel Core i5 1.3GHz','Intel HD Graphics 615','8GB','512GB SSD','12.0"','IPS Panel Retina Display 2304x1440',0.92,'macOS',1,575);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook ProBook 440','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',26725770,30,'HP','Intel Core i5 8250U 1.6GHz','Intel HD Graphics 620','8GB','256GB SSD','14.0"','Full HD 1920x1080',1.63,'Windows',4,623);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Lenovo Notebook IdeaPad 320-15AST','https://media.istockphoto.com/id/171313585/photo/front-view-of-modern-laptop.jpg?s=170667a&w=0&k=20&c=Y8ECE54jJY9BJ-Rr3i4Ekn9M-1vA195AYJSfOspZHao=',48290866,8,'Lenovo','AMD A6-Series 9220 2.5GHz','AMD R4 Graphics','4GB','128GB SSD','15.6"','Full HD 1920x1080',2.2,'Windows',5,225);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire 3','https://anphat.com.vn/media/product/39134_35206_1.png',41438305,13,'Acer','AMD A9-Series 9420 3GHz','AMD Radeon R5','4GB','1TB HDD','15.6"','1366x768',2.1,'Windows',3,574);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Gaming Inspiron 7577','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',37672698,5,'Dell','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1050 Ti','16GB','128GB SSD + 1TB HDD','15.6"','IPS Panel Full HD 1920x1080',2.65,'Windows',1,579);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Ultrabook Pavilion 15-CK000nv','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',26446181,11,'HP','Intel Core i7 8550U 1.8GHz','Nvidia GeForce GTX 940MX','8GB','256GB SSD','15.6"','IPS Panel Full HD 1920x1080',1.83,'Windows',2,455);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 250 G6','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',44168368,9,'HP','Intel Core i5 7200U 2.5GHz','Intel HD Graphics 620','8GB','256GB SSD','15.6"','Full HD 1920x1080',1.96,'Windows',2,294);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Gaming FX503VM-E4007T (i7-7700HQ/16GB/1TB','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',21068678,30,'Asus','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1060','16GB','128GB SSD + 1TB HDD','15.6"','IPS Panel Full HD 1920x1080',2.2,'Windows',1,824);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Ultrabook XPS 13','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',29411889,13,'Dell','Intel Core i7 8550U 1.8GHz','Intel UHD Graphics 620','8GB','256GB SSD','13.3"','IPS Panel Full HD 1920x1080',1.21,'Windows',1,166);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Gaming FX550IK-DM018T (FX-9830P/8GB/1TB/Radeon','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',37170765,13,'Asus','AMD FX 9830P 3GHz','AMD Radeon RX 560','8GB','1TB HDD','15.6"','Full HD 1920x1080',2.45,'Windows',5,343);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer Notebook Aspire 5','https://anphat.com.vn/media/product/39134_35206_1.png',24281856,25,'Acer','Intel Core i7 8550U 1.8GHz','Nvidia GeForce MX150','8GB','1TB HDD','15.6"','Full HD 1920x1080',2.2,'Windows',5,801);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook Probook 430','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',29013790,13,'HP','Intel Core i7 8550U 1.8GHz','Intel UHD Graphics 620','16GB','512GB SSD','13.3"','Full HD 1920x1080',1.49,'Windows',4,227);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Gaming Inspiron 7577','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',21651448,14,'Dell','Intel Core i5 7300HQ 2.5GHz','Nvidia GeForce GTX 1060','8GB','256GB SSD','15.6"','Full HD 1920x1080',2.65,'Windows',0,315);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Ultrabook Zenbook UX430UA','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',29547496,21,'Asus','Intel Core i7 7500U 2.7GHz','Intel HD Graphics 620','8GB','256GB SSD','14.0"','Full HD 1920x1080',1.25,'Windows',4,873);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Acer 2 in 1 Convertible Spin 5','https://anphat.com.vn/media/product/39134_35206_1.png',45075485,29,'Acer','Intel Core i5 8250U 1.6GHz','Intel UHD Graphics 620','8GB','256GB SSD','13.3"','IPS Panel Full HD / Touchscreen 1920x1080',1.5,'Windows',0,209);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3567','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',42258463,13,'Dell','Intel Core i7 7500U 2.7GHz','AMD Radeon R5 M430','8GB','1TB HDD','15.6"','Full HD 1920x1080',2.2,'Linux',1,129);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3567','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',47740793,25,'Dell','Intel Core i3 6006U 2GHz','AMD Radeon R5 M430','4GB','256GB SSD','15.6"','Full HD 1920x1080',2.2,'Linux',2,383);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Asus Notebook X541UV-DM1439T (i3-7100U/6GB/256GB/GeForce','https://fptshop.com.vn/Uploads/Originals/2021/3/1/637502173944633590_asus-vivobook-x415-print-bac-dd.jpg',34358983,23,'Asus','Intel Core i3 7100U 2.4GHz','Nvidia GeForce 920M','6GB','256GB SSD','15.6"','Full HD 1920x1080',2,'Windows',4,860);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Gaming Omen 15-ce007nv','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',28334041,19,'HP','Intel Core i7 7700HQ 2.8GHz','Nvidia GeForce GTX 1050','12GB','128GB SSD + 1TB HDD','15.6"','IPS Panel Full HD 1920x1080',2.62,'Windows',2,517);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 15-bs017nv (i7-7500U/8GB/256GB/Radeon','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',48475354,16,'HP','Intel Core i7 7500U 2.7GHz','AMD Radeon 530','8GB','256GB SSD','15.6"','Full HD 1920x1080',1.91,'Windows',1,416);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Notebook 15-bw000nv (E2-9000e/4GB/500GB/Radeon','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',46203266,8,'HP','AMD E-Series E2-9000e 1.5GHz','AMD Radeon R2','4GB','500GB HDD','15.6"','Full HD 1920x1080',2.1,'Windows',2,267);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('Dell Notebook Inspiron 3576','https://cdn.ankhang.vn/media/product/20971_laptop_dell_latitude_3520_1.jpg',36210912,12,'Dell','Intel Core i5 8250U 1.6GHz','AMD Radeon 520','8GB','1TB HDD','15.6"','Full HD 1920x1080',2.2,'Linux',2,694);
INSERT INTO Product (name, thumbnail, price, quantity, brand, cpu, gpu, ram,disk, screen_size, screen_tech, weight, os, overall_rating, num_rates) VALUES ('HP Ultrabook Envy 13-ad009n','https://cdn.tgdd.vn/Products/Images/44/284190/hp-15s-fq2662tu-i3-6k795pa-020722-020019-600x600.jpg',33584414,8,'HP','Intel Core i7 7500U 2.7GHz','Nvidia GeForce MX150','8GB','256GB SSD','13.3"','IPS Panel Full HD 1920x1080',1.38,'Windows',5,235);

INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'James',
    'Butt',
    '504-845-1427',
    'jbutt@gmail.com',
    '1973-04-06',
    'jamesbutt',
    'jamesbutt26760',
    '6649 N Blue Gum St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Josephine',
    'Darakjy',
    '810-374-9840',
    'josephine_darakjy@darakjy.org',
    '2009-03-06',
    'josephinedarakjy',
    'josephinedarakjy39878',
    '4 B Blue Ridge Blvd'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Art',
    'Venere',
    '856-264-4130',
    'art@venere.org',
    '1971-12-16',
    'artvenere',
    'artvenere26283',
    '8 W Cerritos Ave #54'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Lenna',
    'Paprocki',
    '907-921-2010',
    'lpaprocki@hotmail.com',
    '2008-09-14',
    'lennapaprocki',
    'lennapaprocki39705',
    '639 Main St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Donette',
    'Foller',
    '513-549-4561',
    'donette.foller@cox.net',
    '1970-05-08',
    'donettefoller',
    'donettefoller25696',
    '34 Center St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Simona',
    'Morasca',
    '419-800-6759',
    'simona@morasca.com',
    '1970-08-03',
    'simonamorasca',
    'simonamorasca24322',
    '3 Mcauley Dr'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Mitsue',
    'Tollner',
    '773-924-8565',
    'mitsue_tollner@yahoo.com',
    '1974-05-09',
    'mitsuetollner',
    'mitsuetollner27158',
    '7 Eads St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Leota',
    'Dilliard',
    '408-813-1105',
    'leota@hotmail.com',
    '2010-07-21',
    'leotadilliard',
    'leotadilliard40380',
    '7 W Jackson Blvd'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Sage',
    'Wieser',
    '605-794-4895',
    'sage_wieser@cox.net',
    '1984-03-19',
    'sagewieser',
    'sagewieser30760',
    '5 Boston Ave #88'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Kris',
    'Marrier',
    '410-804-4694',
    'kris@gmail.com',
    '2010-08-05',
    'krismarrier',
    'krismarrier40395',
    '228 Runamuck Pl #2808'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Minna',
    'Amigon',
    '215-422-8694',
    'minna_amigon@yahoo.com',
    '1998-04-03',
    'minnaamigon',
    'minnaamigon35888',
    '2371 Jerrold Ave'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Abel',
    'Maclead',
    '631-677-3675',
    'amaclead@gmail.com',
    '1981-12-09',
    'abelmaclead',
    'abelmaclead29929',
    '37275 St  Rt 17m M'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Kiley',
    'Caldarera',
    '310-254-3084',
    'kiley.caldarera@aol.com',
    '1987-06-01',
    'kileycaldarera',
    'kileycaldarera31929',
    '25 E 75th St #69'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Graciela',
    'Ruta',
    '440-579-7763',
    'gruta@cox.net',
    '1990-02-12',
    'gracielaruta',
    'gracielaruta20132',
    '98 Connecticut Ave Nw'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Cammy',
    'Albares',
    '956-841-7216',
    'calbares@gmail.com',
    '1990-04-29',
    'cammyalbares',
    'cammyalbares19478',
    '56 E Morehead St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Mattie',
    'Poquette',
    '602-953-6360',
    'mattie@aol.com',
    '1990-08-07',
    'mattiepoquette',
    'mattiepoquette20308',
    '73 State Road 434 E'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Meaghan',
    'Garufi',
    '931-235-7959',
    'meaghan@hotmail.com',
    '2004-11-12',
    'meaghangarufi',
    'meaghangarufi38303',
    '69734 E Carrillo St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Gladys',
    'Rim',
    '414-377-2880',
    'gladys.rim@rim.org',
    '1983-01-05',
    'gladysrim',
    'gladysrim30321',
    '322 New Horizon Blvd'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Yuki',
    'Whobrey',
    '313-341-4470',
    'yuki_whobrey@aol.com',
    '2005-11-13',
    'yukiwhobrey',
    'yukiwhobrey38669',
    '1 State Route 27'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Fletcher',
    'Flosi',
    '815-426-5657',
    'fletcher.flosi@yahoo.com',
    '2010-11-29',
    'fletcherflosi',
    'fletcherflosi40511',
    '394 Manchester Blvd'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Bette',
    'Nicka',
    '610-492-4643',
    'bette_nicka@cox.net',
    '1990-09-04',
    'bettenicka',
    'bettenicka25085',
    '6 S 33rd St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Veronika',
    'Inouye',
    '408-813-4592',
    'vinouye@aol.com',
    '1990-06-05',
    'veronikainouye',
    'veronikainouye24628',
    '6 Greenleaf Ave'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Willard',
    'Kolmetz',
    '972-896-4882',
    'willard@hotmail.com',
    '1990-01-16',
    'willardkolmetz',
    'willardkolmetz32889',
    '618 W Yakima Ave'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Maryann',
    'Royster',
    '518-448-8982',
    'mroyster@royster.com',
    '2002-05-17',
    'maryannroyster',
    'maryannroyster37393',
    '74 S Westgate St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Alisha',
    'Slusarski',
    '732-635-3453',
    'alisha@slusarski.com',
    '1993-01-30',
    'alishaslusarski',
    'alishaslusarski33999',
    '3273 State St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Allene',
    'Iturbide',
    '715-530-9863',
    'allene_iturbide@cox.net',
    '2009-01-19',
    'alleneiturbide',
    'alleneiturbide39832',
    '1 Central Ave'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Chanel',
    'Caudy',
    '913-899-1103',
    'chanel.caudy@caudy.org',
    '1990-07-29',
    'chanelcaudy',
    'chanelcaudy28700',
    '86 Nw 66th St #8673'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Ezekiel',
    'Chui',
    '410-235-8738',
    'ezekiel@chui.com',
    '2005-05-22',
    'ezekielchui',
    'ezekielchui38494',
    '2 Cedar Ave #84'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Willow',
    'Kusko',
    '212-934-5167',
    'wkusko@yahoo.com',
    '1994-05-09',
    'willowkusko',
    'willowkusko34463',
    '90991 Thorburn Ave'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Bernardo',
    'Figeroa',
    '936-597-3614',
    'bfigeroa@aol.com',
    '2003-04-22',
    'bernardofigeroa',
    'bernardofigeroa37733',
    '386 9th Ave N'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Ammie',
    'Corrio',
    '614-648-3265',
    'ammie@corrio.com',
    '1981-07-02',
    'ammiecorrio',
    'ammiecorrio29769',
    '74874 Atlantic Ave'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Francine',
    'Vocelka',
    '505-335-5293',
    'francine_vocelka@vocelka.com',
    '1990-09-11',
    'francinevocelka',
    'francinevocelka23631',
    '366 South Dr'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Ernie',
    'Stenseth',
    '201-387-9093',
    'ernie_stenseth@aol.com',
    '1971-01-13',
    'erniestenseth',
    'erniestenseth25946',
    '45 E Liberty St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Albina',
    'Glick',
    '732-782-6701',
    'albina@glick.com',
    '1990-07-24',
    'albinaglick',
    'albinaglick18833',
    '4 Ralph Ct'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Alishia',
    'Sergi',
    '212-753-2740',
    'asergi@gmail.com',
    '1990-07-12',
    'alishiasergi',
    'alishiasergi33066',
    '2742 Distribution Way'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Solange',
    'Shinko',
    '504-265-8174',
    'solange@shinko.com',
    '1992-04-20',
    'solangeshinko',
    'solangeshinko33714',
    '426 Wolf St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Jose',
    'Stockham',
    '212-569-4233',
    'jose@yahoo.com',
    '1993-07-03',
    'josestockham',
    'josestockham34153',
    '128 Bransten Rd'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Rozella',
    'Ostrosky',
    '805-609-1531',
    'rozella.ostrosky@ostrosky.com',
    '1996-04-07',
    'rozellaostrosky',
    'rozellaostrosky35162',
    '17 Morena Blvd'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Valentine',
    'Gillian',
    '210-300-6244',
    'valentine_gillian@gmail.com',
    '1990-03-26',
    'valentinegillian',
    'valentinegillian23827',
    '775 W 17th St'
  );
INSERT INTO Customer (
    first_name,
    last_name,
    phone,
    email,
    birthday,
    username,
    password,
    address
  ) VALUE(
    'Kati',
    'Rulapaugh',
    '785-219-7724',
    'kati.rulapaugh@hotmail.com',
    '1990-01-06',
    'katirulapaugh',
    'katirulapaugh18634',
    '6980 Dorsett Rd'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Youlanda',
    'Schemmer',
    '541-993-2611',
    'youlanda@aol.com',
    'youlandaschemmer',
    'youlandaschemmer35703'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Dyan',
    'Oldroyd',
    '913-645-8918',
    'doldroyd@aol.com',
    'dyanoldroyd',
    'dyanoldroyd30339'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Roxane',
    'Campain',
    '907-335-6568',
    'roxane@hotmail.com',
    'roxanecampain',
    'roxanecampain23189'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Lavera',
    'Perin',
    '305-995-2078',
    'lperin@perin.org',
    'laveraperin',
    'laveraperin21825'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Erick',
    'Ferencz',
    '907-227-6777',
    'erick.ferencz@aol.com',
    'erickferencz',
    'erickferencz26161'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Fatima',
    'Saylors',
    '952-479-2375',
    'fsaylors@saylors.org',
    'fatimasaylors',
    'fatimasaylors35924'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Jina',
    'Briddick',
    '617-997-5771',
    'jina_briddick@briddick.com',
    'jinabriddick',
    'jinabriddick18485'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Kanisha',
    'Waycott',
    '323-315-7314',
    'kanisha_waycott@yahoo.com',
    'kanishawaycott',
    'kanishawaycott36054'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Emerson',
    'Bowley',
    '608-658-7940',
    'emerson.bowley@bowley.org',
    'emersonbowley',
    'emersonbowley33818'
  );
INSERT INTO Admin (
    first_name,
    last_name,
    phone,
    email,
    username,
    password
  ) VALUE(
    'Blair',
    'Malet',
    '215-794-4519',
    'bmalet@yahoo.com',
    'blairmalet',
    'blairmalet29597'
  );
-- News
INSERT INTO News (`id`, `admin_id`,`title`, `thumbnail`, `content`)
VALUES (
    1,
    1,
    'Tr??n tay SSD SAMSUNG 990 PRO  - Chi???n binh m???i trong d??ng Flagship 2022',
    'https://bizweb.sapocdn.net/thumb/large/100/329/122/articles/ss-990-pro-bia.jpg?v=1669969576323',
    '<div class=\"article-details\">	<h1 class=\"article-title\">		<a href=\"/tren-tay-ssd-samsung-990-pro-chien-binh-moi-trong-dong-flagship-2022\">Tr??n tay SSD SAMSUNG 990 PRO  - Chi???n binh m???i trong d??ng Flagship 2022</a> </h1> <div class=\"date\">		 Th??? Fri,										<div class=\"news_home_content_short_time\">									02/12/2022								</div> <div class=\"post-time\">											????ng b???i 			Hu???nh Ng???c		</div> </div> <div class=\"article-content\">		<div class=\"rte\">			<p> </p> <p style=\"text-align: justify;\">								<em>B??n c???nh SanDisk, Samsung l?? m???t trong nh???ng c??i t??n k??? c???u trong l??ng s???n xu???t ??? c???ng SSD.V?? m???i ????y Samsung l???i ti???p t???c cho ra m???t s???n ph???m m???i mang t??n 					<strong>SSD Samsung 990 Pro</strong>. N???u b???n ??ang t?? m?? hay c?? ?? ?????nh mua s???n ph???m th?? h??y ?????c ngay b??i vi???t d?????i ????y c???a MemoryZone ????? c?? c??i nh??n tr???c quan nh???t v??? s???n ph???m n??y n??o!				</em> </p> <h2>1. L???ch s??? ph??t tri???n c???a ??? c???ng SSD Samsung 990 Pro</h2> <p style=\"text-align: justify;\">				<strong>??? c???ng SSD</strong> ?????u ti??n ???????c s???n xu???t b???i Samsung ???????c ra m???t l???n ?????u ti??n v??o th??ng 4 / 2008, ???? l?? chi???c SSD Samsung SLC SATA II 64GB l???n ?????u ???????c ra m???t v???i gi?? kh???i ??i???m l?? ??? 1130$ ????-la! D???n theo th???i gian, th??? gi???i ???? ch???ng ki???n s??? ph??t tri???n d???n c???a c??ng ngh??? flash NAND, t??? SLC sang TLC r???i ?????n QLC. T??? ???? ch??ng ta c?? th??? nh???n ?????nh r???ng, c??ng ngh??? n??i chung v?? SSD n??i ri??ng ??ang t???ng ng??y, t???ng ng??y ??ang ph??t tri???n kh??ng ng???ng, m???t c??ch th???n t???c, v???i m???t c??i ???gi????? ph???i tr??? l?? mang ?????n hi???u su???t t???i ??u nh???t cho ng?????i d??ng.			</p> <p> </p><div class=\"se-component se-image-container __se__float- __se__float-none\" contenteditable=\"false\"><figure style=\"margin: 0px;\"><img data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/ss-990-pro-1.jpg?v=1669967926135\" data-origin=\"100,800\" alt=\"\" data-proportion=\"true\" data-size=\"1070px,800px\" data-align=\"\" data-file-name=\"ss-990-pro-1.jpg?v=1669967926135\" data-file-size=\"0\" origin-size=\"800,800\" style=\"width: 1070px; height: 800px;\" data-index=\"0\"></figure></div><p><br></p> <p> </p><p style=\"text-align: center;\">				<em>SSD SAMSUNG 990 PRO ??? S??? ho??n h???o tuy???t ?????i!</em> </p> <p style=\"text-align: justify;\">V?? 				<strong>SSD Samsung 990 Pro</strong> l?? s???n ph???m h???i t??? nh???ng c??ng ngh??? m???i, nh???ng ??i???u tinh hoa nh???t m?? Samsung mu???n g???i ?????n cho ng?????i d??ng. ???????c xem l?? 1 ???ng???a chi???n??? m???i c???a nh?? Samsung trong d??ng flagship SSD. H??y c??ng MemoryZone ????nh gi?? th???c t??? t??? h??nh ???nh, hi???u n??ng v?? so s??nh v???i c??c s???n ph???m ti???n nhi???m t??? A-Z nh??!			</p> <h2 style=\"text-align: justify;\">2. ????nh gi?? nhanh SSD Samsung 990 Pro</h2> <p style=\"text-align: justify;\">				<strong>SSD Samsung 990 Pro</strong> l?? s???n ph???m flagship m???i nh???t c???a ???ng?????i kh???ng l?????? ?????n t??? H??n Qu???c ??? Samsung, ???????c ra m???t k??m theo l???i h???a ???t???c ????? tia ch???p - hi???u su???t v?????t tr???i???. V???i l???i th??? v??? b??? ??i???u khi???n ?????c quy???n v?? V-NAND c???a ri??ng m??nh, Samsung tuy??n b??? s???n ph???m ???? ???????c \"t???i ??u gaming ??? chinh ph???c t??c v??? n???ng\".			</p> <p> <strong>??u ??i???m</strong> </p> <ul><li>T???c ????? ?????c, ghi ???kh???ng??? nh???t th??? gi???i.</li><li>????? b???n cao, hi???u n??ng ???n ?????nh, b???o h??nh 5 n??m.</li><li>Ph???n m???m ??i k??m Samsung Magician xu???t s???c .</li></ul> <p> <strong>Nh?????c ??i???m</strong> </p> <ul><li>Gi?? th??nh ch??a t???t</li><li>T???c ghi ng???u nhi??n 4K ch??a ?????t nh?? k??? v???ng.</li></ul> <h2>3. Thi???t k??? - t??nh n??ng v?? c??c c??ng ngh??? ??i k??m</h2> <p>Phi??n b???n				<strong> SSD Samsung 990 Pro</strong> n??m nay v???n th??n thi???n v???i ng?????i d??ng v???i ti??u ch?? thi???t k??? ti??u chu???n ???qu???c d??n??? PCIe 4.0 x4 NVMe 2.0, form-factor M.2 2280. Ngo??i ra, phi??n b???n 				<strong>990 Pro</strong> n??m nay s??? l?? ??? SSD ?????u ti??n ???????c trang b??? c??ng ngh??? m???i nh???t l?? TLC V-NAND th??? h??? th??? 7.			</p> <p> <strong>N??m nay SSD Samsung 990 Pro </strong>s??? c?? hai phi??n b???n:			</p> <ul><li> <strong>SSD Samsung 990 Pro</strong> c?? heatsink: Ph?? h???p cho h??? console nh?? PS5 ????? gia t??ng kh??? n??ng gi???i nhi???t.				</li><li> <strong>SSD Samsung 990 Pro </strong>kh??ng heatsink: Ph?? h???p v???i nhi???u ?????i t?????ng h??n, d??nh cho nh???ng b???n c???n hi???u n??ng t???t m?? v???n mu???n ti???t ki???m ???????c ng??n s??ch				</li></ul> <h2>4. Hi???u su???t v?????t tr???i, ????ng kinh ng???c SSD Samsung 990 Pro</h2> <p>V??? hi???u su???t ???????c c??ng b???, 				<strong>SSD Samsung 990 Pro</strong> c?? t???c ????? ?????c (Read) 7450MB/s v?? t???c ????? ghi (Write) 6900MB/s - g???n ?????t t???c ????? t???i ??a theo l?? thuy???t t???t nh???t c???a PCIe 4.0 l?? 8000MB/s. ????y l?? m???t c???i ti???n ????ng kinh ng???c so ng?????i ti???n nhi???m 				<strong>SSD Samsung 980 Pro</strong> ???ch?????? v???i t???c ????? ?????c (Read) 7000MB/s v?? ghi (Write) 5000MB/s.			</p> <p> </p><div class=\"se-component se-image-container __se__float- __se__float-none\" contenteditable=\"false\"><figure style=\"margin: 0px;\"><img data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/ss-990-pro-2.jpg?v=1669968517071\" data-origin=\"100,802\" alt=\"\" data-proportion=\"true\" data-size=\"1070px,802px\" data-align=\"\" data-file-name=\"ss-990-pro-2.jpg?v=1669968517071\" data-file-size=\"0\" origin-size=\"802,802\" style=\"width: 1070px; height: 802px;\" data-index=\"1\"></figure></div><p><br></p> <p> </p><p style=\"text-align: justify;\">T???c ????? ?????c v?? ghi ng???u nhi??n (Random 4K ??? IOPS), 				<strong>SSD Samsung 990 Pro</strong> d??? ki???n ??????s??? ?????t m???c cao nh???t l?? kho???ng 1.400 ngh??n l?????t ?????c v?? 1.550 ngh??n l?????t ghi IOPS, t???c c???i thi???n l???n l?????t 40% v?? 55% hi???u su???t so v???i 				<strong>SSD Samsung 980 Pro</strong>. V?? t???t nhi??n, 				<strong>SSD Samsung 990 Pro</strong> s??? r???t ph?? h???p ????? c??c game th??? ???hardcore??? bay cao h??n trong cu???c ch??i, ????p ???ng m???t-c??ch-t???i-??u-nh???t cho content creator v?? ph??n t??ch d??? li???u hi???u qu??? h??n.			</p> <p style=\"text-align: justify;\">				<strong>SSD Samsung 990 Pro </strong>???????c ph??? th??m m???t l???p niken tr??n b??? controller ????? c???i thi???n kh??? n??ng gi???i nhi???t t???ng th???, k??m theo ???? l?? c??ng ngh??? Dynamic Thermal Guard c???a ch??nh Samsung, gi??p SSD t???i ??u c??c t??c v??? n???ng m?? kh??ng gi???m hi???u su???t.</p> <p style=\"text-align: justify;\">			</p><h2 style=\"text-align: justify;\">5. Review hi???u n??ng th???c t??? c???a SSD Samsung 990 Pro Test tr??n c???u h??nh:</h2> <ul><li style=\"text-align: justify;\">Mainboard MSI PRO Z690-A WIFI DDR4</li><li style=\"text-align: justify;\">CPU Intel Core i9-13900K</li><li style=\"text-align: justify;\">Ram Kingston HyperX Predator 32GB 3200MHz D4 (x2)</li><li style=\"text-align: justify;\">					<strong>SSD Samsung 990 Pro</strong> PCIe Gen 4.0 x4 NVMe V-NAND M.2 2280 1TB				</li><li style=\"text-align: justify;\">Windows 11 Pro 64-bit</li></ul> <p style=\"text-align: justify;\">Link tham kh???o c???u h??nh t????ng t???: 				<a href=\"https://memoryzone.com.vn/pc-st-neptune-i9k-g13\" target=\"_blank\">T???I ????Y</a> </p> <p style=\"text-align: justify;\">????? ki???m tra hi???u n??ng th???c t???, MemoryZone s??? d???ng c??c ph???n m???m sau ????y:<span style=\"font-weight: var(--bs-body-font-weight);\">???</span></p><ul><li style=\"text-align: justify;\">Anvil Benchmark</li><li style=\"text-align: justify;\">AS SSD Benchmark</li><li style=\"text-align: justify;\">Crystal Disk Info</li><li style=\"text-align: justify;\">Crystal Disk Mark</li></ul> <p style=\"text-align: justify;\">V?? ????y l?? k???t qu??? test nhanh:</p> <p style=\"text-align: center;\">								</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\" style=\"width: 100%; min-width: 100%;\"><figure style=\"margin: auto; width: 100%;\"><img src=\"https://lh3.googleusercontent.com/O09JHYi4rdHQFqh5RLW3BPFC8_kMBM-ZESlkSjumDqJUJ-imaBCYkO2MyVSz2x-uUEq1_7kZdD9k-hHU4nL9mAiWbIFOmnuj-8iBYAMzO99qVI1rf01WzLeEifJNEVV5CS6htAmoBu6-2-qLXVF7vCyQtwmsAOuXOVtqQPWFxZ3xOjbowjLm0j_wAzKOLA\" data-origin=\"100,\" alt=\"\" data-proportion=\"true\" data-align=\"center\" data-size=\"100%,\" data-file-name=\"O09JHYi4rdHQFqh5RLW3BPFC8_kMBM-ZESlkSjumDqJUJ-imaBCYkO2MyVSz2x-uUEq1_7kZdD9k-hHU4nL9mAiWbIFOmnuj-8iBYAMzO99qVI1rf01WzLeEifJNEVV5CS6htAmoBu6-2-qLXVF7vCyQtwmsAOuXOVtqQPWFxZ3xOjbowjLm0j_wAzKOLA\" data-file-size=\"0\" origin-size=\"1279,882\" style=\"width: 100%;\" data-rotate=\"\" data-rotatex=\"\" data-rotatey=\"\" data-percentage=\"100,\" data-index=\"9\"></figure></div><p style=\"text-align: center;\"><strong>									</strong></p> <p style=\"text-align: center;\"> </p><p style=\"text-align: center;\">				<em>Anvil Benchmark</em> </p> <p style=\"text-align: center;\">								</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\" style=\"width: 100%; min-width: 100%;\"><figure style=\"margin: auto; width: 100%;\"><img src=\"https://lh6.googleusercontent.com/4okRGHqdo9OIXsV9rV-kTKzQXP7Ziu59YC6gSduqv7FVR46zHj8HelZp8behd9mva806-L-mI7WFZ_2z4Keyede-43Vhi0YyEEWcDvEt-27Xbj6HASP7F6kuND2l5BcD9O4COn_Byf7ECYCHPvXv9Ej8V0pMdR3lwbIcQTVBkNuHC3wPLIh4LOn_fFemUQ\" data-origin=\"100,\" alt=\"\" data-proportion=\"true\" data-align=\"center\" data-size=\"100%,\" data-file-name=\"4okRGHqdo9OIXsV9rV-kTKzQXP7Ziu59YC6gSduqv7FVR46zHj8HelZp8behd9mva806-L-mI7WFZ_2z4Keyede-43Vhi0YyEEWcDvEt-27Xbj6HASP7F6kuND2l5BcD9O4COn_Byf7ECYCHPvXv9Ej8V0pMdR3lwbIcQTVBkNuHC3wPLIh4LOn_fFemUQ\" data-file-size=\"0\" origin-size=\"1432,805\" style=\"width: 100%;\" data-index=\"5\" data-rotate=\"\" data-rotatex=\"\" data-rotatey=\"\" data-percentage=\"100,\"></figure></div><p style=\"text-align: center;\"><strong>									</strong></p> <p style=\"text-align: center;\"> </p><p style=\"text-align: center;\">				<em>AS SSD Benchmark</em> </p> <p style=\"text-align: center;\">								</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\" style=\"width: 100%; min-width: 100%;\"><figure style=\"margin: auto; width: 100%;\"><img src=\"https://lh3.googleusercontent.com/KPCDueAUh790hqvtib8SGJF0sczPQt-ksXapRh_bOGQCGlOlWZG7E9usmEGLlvggegSgZMqhDvpQANpidNHVDy340mU8kyWZRoU2uLj28GTdr2nQ2hp24dlDldMqHvvyZdXdpLXzQ2KTtSvnEE0sByMKrfeJsOOhQhPTbgCSlWFiNilojNVES8oLEPcg9Q\" data-origin=\"100,\" alt=\"\" data-proportion=\"true\" data-align=\"center\" data-size=\"100%,\" data-file-name=\"KPCDueAUh790hqvtib8SGJF0sczPQt-ksXapRh_bOGQCGlOlWZG7E9usmEGLlvggegSgZMqhDvpQANpidNHVDy340mU8kyWZRoU2uLj28GTdr2nQ2hp24dlDldMqHvvyZdXdpLXzQ2KTtSvnEE0sByMKrfeJsOOhQhPTbgCSlWFiNilojNVES8oLEPcg9Q\" data-file-size=\"0\" origin-size=\"1432,805\" style=\"width: 100%;\" data-index=\"6\" data-rotate=\"\" data-rotatex=\"\" data-rotatey=\"\" data-percentage=\"100,\"></figure></div><p style=\"text-align: center;\"><em>					<strong>											</strong>Crystal Disk Mark &amp; Crystal Disk Info				</em></p> <p style=\"text-align: center;\"> </p><h2>6. So s??nh nhanh line s???n ph???m SSD Samsung 990 Pro</h2> <p> </p> <table> <tbody> <tr> <td> <p style=\"text-align: center;\">								<strong>S???n ph???m</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>1TB</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>2TB</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>4TB</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>Gi?? d??? ki???n</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>$169.99 | $189.99</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>$289.99 | $309.99</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>N/A</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>Form Factor</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>M.2 2280</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>M.2 2280</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>M.2 2280</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>Giao th???c</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>PCIe 4.0 x4</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>PCIe 4.0 x4</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>PCIe 4.0 x4</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>Controller</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Samsung Pascal</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Samsung Pascal</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Samsung Pascal</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>DRAM</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>LPDDR4</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>LPDDR4</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>LPDDR4</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>Flash Memory</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>176-Layer V-NAND TLC</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>176-Layer V-NAND TLC</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>176-Layer V-NAND TLC</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>T???c ????? ?????c</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>7,450 MB/s</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>7,450 MB/s</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>7,450 MB/s</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>T???c ????? ghi</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>6,900 MB/s</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>6,900 MB/s</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>6,900 MB/s</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>T???c ????? ?????c ng???u nhi??n</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Up to 1.2M</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Up to 1.4M</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Up to 1.4M</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>T???c ????? ghi ng???u nhi??n</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Up to 1.55M</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Up to 1.55M</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>Up to 1.55M</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>B???o m???t</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>TCG/Opal 2.0</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>TCG/Opal 2.0</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>TCG/Opal 2.0</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>????? b???n (TBW)</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>600TB</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>1200TB</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>2400TB</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>Part Number</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>MZ-V9P1T0BW | MZ-V9P1T0CW</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>MZ-V9P2T0BW | MZ-V9P2T0CW</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>MZ-V9P4T0BW | MZ-V9P4T0CW</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>K??ch th?????c</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>2.30mm | 8.20mm</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>2.30mm | 8.20mm</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>2.30mm | 8.20mm</strong> </p> </td> </tr> <tr> <td> <p style=\"text-align: center;\">								<strong>B???o h??nh</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>5-N??m</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>5-N??m</strong> </p> </td> <td> <p style=\"text-align: center;\">								<strong>5-N??m</strong> </p> </td> </tr> </tbody> </table> <h2>7. K???t lu???n v??? Samsung 990 Pro</h2> <p> </p><div class=\"se-component se-image-container __se__float- __se__float-none\" contenteditable=\"false\"><figure style=\"margin: 0px;\"><img data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/ss-990-pro-4.jpg?v=1669969379375\" data-origin=\"100,800\" alt=\"\" data-proportion=\"true\" data-size=\"1070px,800px\" data-align=\"\" data-file-name=\"ss-990-pro-4.jpg?v=1669969379375\" data-file-size=\"0\" origin-size=\"800,800\" style=\"width: 1070px; height: 800px;\" data-index=\"7\"></figure></div><p><br></p> <p> </p><p style=\"text-align: justify;\">C?? th??? n??i trong v?? v??n c??c s??? l???a ch???n ??? c???ng SSD hi???n nay, th?? 				<strong>SSD Samsung 990 Pro</strong> ???????c xem l?? s??? l???a ch???n t???t nh???t d??nh cho game th??? c??? v??? gi?? v?? hi???u n??ng ho???t ?????ng ???????c kh???ng ?????nh v?? ????nh gi?? chi ti???t b???i c??c t???p ch?? c??ng ngh??? h??ng ?????u th??? gi???i nh?? Cnet, thessdreview, the PC World. TweakTown... V???i hi???u su???t c???c kh???ng, 				<strong>SSD Samsung 990 Pro</strong> h???a h???n s??? l?? s???n ph???m h??? tr??? cho c??c game th??? ch??i t???t h??n m???i t???a game c??ng nh?? s???p x???p h???p l?? c??c lu???ng d??? li???u cho ????? h???a, ???????c ??i k??m theo c??ng ngh??? TurboWrite th??ng minh, ng?????i d??ng s??? kh??ng ng???n ng???i g?? s??? h???u ngay m???t chi???c t???i Memoryzone, v?? t???t nhi??n l?? c?? s???n h??ng tr??n k???!			</p> <p style=\"text-align: justify;\">				<strong>SSD Samsung 990 Pro</strong> b???n 1TB: 				<a href=\"https://go.mmz.vn/ssd-samsung-990-pro-1tb\" target=\"_blank\">T???I ????Y</a> </p> <p style=\"text-align: justify;\">				<strong>SSD Samsung 990 Pro </strong>b???n 2TB: 				<a href=\"https://go.mmz.vn/ssd-samsung-990-pro-2tb\" target=\"_blank\">T???I ????Y</a> </p> <h2 style=\"text-align: justify;\">8. T???ng k???t</h2> <p style=\"text-align: justify;\">Tr??n ????y l?? nh???ng ????nh gi?? chi ti???t v?? chia s??? v??? ??? c???ng SSD 				<strong>Samsung 990 Pro</strong> ??ang l??m m??a l??m gi?? nh???ng ng??y g???n ????y c???a Memoryzone. Hy v???ng b??i vi???t h??m nay ???? mang ?????n cho b???n nh???ng th??ng tin h???u ??ch. C???m ??n b???n ???? theo d??i b??i vi???t v?? Memoryzone s??? ti???p t???c c???p nh???t cho b???n nh???ng th??ng tin c??ng ngh??? m???i nh???t hi???n nay. H??y theo d??i website memoryzone.vn ????? kh??ng b??? l??? nh???ng b??i vi???t b??? ??ch v?? c??c ch????ng tr??nh khuy???n m??i c???c hot t??? Memoryzone nh??!			</p> </div> </div></div><p>undefinedundefined</p><div class=\"col-xs-12\"><div class=\"row row-noGutter tag-share\">	<div class=\"col-xs-12 col-sm-6 tag_article \">		<strong>Tags:</strong> <a href=\"/blogs/all/tagged/o-cung-samsung\">??? c???ng samsung</a>, 																					<a href=\"/blogs/all/tagged/o-cung-ssd\">??? c???ng ssd</a> </div> <div class=\"col-xs-12 col-sm-6\">		<div class=\"social-sharing f-right\">			<div class=\"addthis_inline_share_toolbox share_add\">							</div> </div> </div></div>undefined</div>'
  );
INSERT INTO News (`id`, `admin_id`,`title`, `thumbnail`, `content`)
VALUES (
    2,
    2,
    'Mainboard l?? g??? C???u t???o, ch???c n??ng v?? ti??u ch?? ch???n mainboard ph?? h???p cho b???n',
    'https://bizweb.sapocdn.net/thumb/large/100/329/122/articles/mainboard-la-gi.jpg?v=1669869401500',
    '<div class=\"article-details\">	<h1 class=\"article-title\">		<a href=\"/mainboard-la-gi\">Mainboard l?? g??? C???u t???o, ch???c n??ng v?? ti??u ch?? ch???n mainboard ph?? h???p cho b???n</a> </h1> <div class=\"date\">		 Th??? Thu,										<div class=\"news_home_content_short_time\">									01/12/2022								</div> <div class=\"post-time\">											????ng b???i 			L??m H???i		</div> </div> <div class=\"article-content\">		<div class=\"rte\">			<p> <em>N???u nh?? CPU ???????c bi???t ?????n l?? b??? n??o x??? l?? tr??n 					<a href=\"https://memoryzone.com.vn/pc-st\" target=\"_blank\">m??y t??nh</a>, 					<a href=\"https://memoryzone.com.vn/laptop\" target=\"_blank\">laptop</a> th?? Mainboard s??? l?? x????ng s???ng gi??p thi???t b??? ho???t ?????ng hi???u qu???. V???y th???c ch???t Mainboard l?? g??? C???u t???o v?? ch???c n??ng c???a Mainboard nh?? th??? n??o? M???i b???n tham kh???o b??i vi???t d?????i ????y nh??!				</em> </p> <p> </p> <h2>1. Mainboard l?? g??? Bo m???ch ch??? l?? g???</h2> <blockquote>				<p>Mainboard l?? g??? Mainboard c?? th??? g???i t???t l?? Mobo/ Main hay ?????ng th???i l?? Bo m???ch ch???. Mainboard l?? b???ng m???ch in c?? vai tr?? li??n k???t c??c thi???t b??? v???i nhau th??ng qua ?????u c???m hay d??y d???n ph?? h???p. Nh??? v??o Mainboard m?? c??c linh ki???n c?? th??? ph??t huy ???????c kh??? n??ng ho???t ?????ng v???i c??ng su???t t???i ??a nh?? nh???ng g?? m?? ng?????i d??ng mong mu???n tr??n m???t chi???c m??y t??nh.</p> </blockquote> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 640px;\"><img alt=\"Bo m???ch ch??? l?? g??\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/bo-mach-chu-la-gi-1.jpg?v=1669867849663\" data-origin=\"640,357\" data-proportion=\"true\" data-align=\"center\" data-size=\"640px,357px\" data-file-name=\"bo-mach-chu-la-gi-1.jpg?v=1669867849663\" data-file-size=\"0\" origin-size=\"640,357\" style=\"width: 640px; height: 357px;\" data-index=\"0\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">			</p><p style=\"text-align: center;\">								<em>Mainboard l?? g???</em> </p> <p>Tr??n th???c t???, 				<a href=\"https://memoryzone.com.vn/mainboard-pc\" target=\"_blank\">Mainboard</a> l?? trung t??m ??i???u ph???i c??c ho???t ?????ng ch??nh tr??n PC v?? vi???c k???t n???i, ??i???u khi???n s??? ???????c th???c hi???n b???i chip c???u B???c v?? chip c???u Nam.			</p> <p> <strong>Tham kh???o th??m c??c d??ng m??y t??nh - PC ch??i game, h???c t???p:</strong> </p> <ul style=\"margin-left: 40px;\"><li> <a href=\"https://memoryzone.com.vn/pc-mercury-series\" target=\"_blank\">PC Mercury Series</a> </li><li> <a href=\"https://memoryzone.com.vn/pc-tron-bo-homework\" target=\"_blank\">PC tr???n b??? Homework</a> </li><li> <a href=\"https://memoryzone.com.vn/pc-titan-series\" target=\"_blank\">PC Titan Series</a> </li><li> <a href=\"https://memoryzone.com.vn/pc-moonator-series\" target=\"_blank\">PC Moonator Series</a> </li></ul> <h2>2. C???u t???o chi ti???t c???a mainboard</h2> <p>C???u t???o c???a bo m???ch ch??? g???m c??c th??nh ph???n ch??nh nh?? sau:</p> <h3>2.1. ????? c???m CPU</h3> <p style=\"margin-left: 40px;\">????? c???m 				<a href=\"https://memoryzone.com.vn/cpu-may-tinh\" target=\"_blank\">CPU</a> chay c??n g???i l?? ch??n Socket. B??? ph???n ???????c l???p ?????t c??? ?????nh chip v??o bo m???ch ch???. T??y v??o lo???i bo m???ch ch??? kh??c nhau m?? s??? c?? chip t????ng ???ng. S??? ????? c???m CPU c??ng l???n s??? d??nh cho nh???ng d??ng chip hi???n ?????i h??n v?? ng?????c l???i chip c?? s??? t????ng th??ch v???i s??? Socket nh???.			</p> <h3>2.2. Chip c???u B???c - Nam</h3> <p style=\"margin-left: 40px;\">Chip c???u B???c v?? chip c???u Nam s??? ?????m nhi???m vi???c ??i???u ph???i ho???t ?????ng c???a CPU v?? c??c linh ki???n kh??c trong m??y t??nh. Chip c???u B???c s??? c?? t??n g???i l?? Memory Controller Hub (MCH). MCH s??? ??i???u khi???n tr???c ti???p c??c th??nh ph???n c?? t???c ????? nhanh nh??: 				<a href=\"https://memoryzone.com.vn/ram\" target=\"_blank\">RAM</a>, CPU, card ????? h???a.			</p> <p style=\"margin-left: 40px;\">?????ng th???i, chip c???u B???c c??n th???c hi???n trao ?????i d??? li???u v???i chip c???u Nam. Chip c???u B???c l?? th??nh ph???n quan tr???ng nh???t ?????i v???i Bo m???ch ch??? v?? l?? y???u t??? d??ng ????? quy???t ?????nh ch???t l?????ng ho???t ?????ng c??ng nh?? gi?? th??nh c???a Bo m???ch ch???.</p> <p style=\"margin-left: 40px;\">Chip c???u Nam c?? t??n l?? I/O Controller Hub (ICH), chip s??? ??i???u khi???n c??c thi???t b??? c?? t???c ????? ch???m h??n nh??: 				<a href=\"https://memoryzone.com.vn/usb\" target=\"_blank\">USB</a>, 				<a href=\"https://memoryzone.com.vn/o-cung-di-dong\" target=\"_blank\">??? c???ng</a>,??? Chip c???u Nam th??ng qua chip c???u B???c ????? k???t n???i v???i CPU m?? th???c hi???n k???t n???i tr???c ti???p.			</p> <p style=\"margin-left: 40px;\">				<strong>Xem th??m:</strong> <a href=\"https://memoryzone.com.vn/cpu-viet-tat-cua-tu-gi\" target=\"_blank\">CPU vi???t t???t c???a t??? g??? C???u t???o, vai tr?? v?? c??c thu???t ng??? li??n quan v??? CPU</a> </p> <h3>2.3. Khe c???m m??? r???ng</h3> <p style=\"margin-left: 40px;\">Tr??n Mainboard s??? g???m nhi???u khe c???m m??? r???ng ????? k???t n???i v???i c??c thi???t b??? ph???n c???ng nh?? card r???i, card ????? h???a,...</p> <h3>2.4. Card ????? h???a</h3> <p style=\"margin-left: 40px;\">				<a href=\"https://memoryzone.com.vn/vga\" target=\"_blank\">Card m??n h??nh</a>(card ????? h???a) c??ng l?? th??nh ph???n c?? trong Mainboard v?? tr??? n??n c???n thi???t v???i nh???ng ng?????i d??ng c?? nhu c???u v??? thi???t k??? ????? h???a hay ch??i game.			</p> <h3>2.5.Card ??m thanh</h3> <p style=\"margin-left: 40px;\">Card ??m thanh c?? vai tr?? gi??p cho bo m???ch ch??? t??ch h???p ???????c c??c ??m thanh m???t c??ch chu???n x??c nh???t.</p> <h2>3. Ch???c n??ng c???a mainboard - bo m???ch ch???</h2> <p>B???n ch???t c???a Mainboard l?? b???n m???ch v?? c???u n???i gi???a c??c linh ki???n v?? thi???t b??? ngo???i vi v???i nhau ????? t???o th??nh b??? m??y t??nh nh???t. V???y n??n ch???c n??ng ch??nh c???a Mainboard s??? ??i???u khi???n ???????ng truy???n v?? t???c ????? c???a d??? li???u.</p> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 640px;\"><img alt=\"Mainboard l?? b???n m???ch v?? c???u n???i gi???a c??c linh ki???n\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/mainboard-la-ban-mach-va-cau-noi-giua-cac-linh-kien.jpg?v=1669868016969\" data-origin=\"640,360\" data-proportion=\"true\" data-align=\"center\" data-size=\"640px,360px\" data-file-name=\"mainboard-la-ban-mach-va-cau-noi-giua-cac-linh-kien.jpg?v=1669868016969\" data-file-size=\"0\" origin-size=\"640,360\" style=\"width: 640px; height: 360px;\" data-index=\"1\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">				<br>								<em>Mainboard l?? b???n m???ch v?? c???u n???i gi???a c??c linh ki???n</em> </p><p>H??n n???a, Mainboard c??n ph??n ph???i l?????ng ??i???n ??p ph?? h???p cho t???ng thi???t b??? hay linh ki???n, ??i???u n??y gi??p h??? th???ng ???????c ho???t ?????ng m???t c??ch ???n ?????nh. B??n c???nh ????, Mainboard c??n gi??? ch???c n??ng n??ng c???p v?? quy???t ?????nh ?????n tu???i th??? c???a m??y. V???y n??n, c???n b???o v??? Mainboard theo ????ng khuy???n ngh??? t??? nh?? s???n xu???t ????? m??y ho???t ?????ng t???t h??n b???n nh??!</p> <p> <strong>Xem th??m:</strong> <a href=\"https://memoryzone.com.vn/ram-may-tinh-la-gi\" target=\"_blank\">RAM m??y t??nh l?? g??? M??y t??nh v?? laptop c???n dung l?????ng RAM bao nhi??u l?? ??????</a> </p> <h2>4. Mainboard - bo m???ch ch??? ho???t ?????ng nh?? th??? n??o?</h2> <p>Mainboard ???????c ho???t ?????ng d???a v??o t???c ????? truy???n (bus). Nh?? ???? t??m hi???u Mainboard g???m hai chip c???u B???c v?? c???u Nam. Nhi???m v??? c???a hai chip l?? k???t n???i th??nh ph???n v???i nhau, n???i CPU - RAM hay CPU - VGA Card, RAM v???i c??c khe c???m m??? r???ng.</p> <h2>5. T???ng h???p c??c th????ng hi???u s???n xu???t mainboard n???i ti???ng th??? gi???i</h2> <h3>5.1. 				<a href=\"https://memoryzone.com.vn/mainboard-asus\" target=\"_blank\">Mainboard Asus</a> </h3> <p style=\"margin-left: 40px;\">Asus l?? m???t trong nh???ng th????ng hi???u s???n xu???t mainboard t???t nh???t tr??n th??? tr?????ng. Th????ng hi???u kh??ng ch??? chi???m ??u th??? v??? vi???c cung c???p c??c d??ng s???n ph???m m??y t??nh, laptop m?? c??n ph??t tri???n m???nh m??? v??? s???n xu???t Mainboard. Nh???ng chi???c Mainboard c???a Asus g??y ???n t?????ng v???i ng?????i d??ng khi c?? ngo???i h??nh ???c???c ch???t??? v?? kh??? n??ng v???n h??nh ch???t l?????ng.</p> <p style=\"margin-left: 40px;\">				<strong>Tham kh???o th??m c??c s???n ph???m n???i b???t t??? nh??Asus:</strong> </p> <ul style=\"margin-left: 40px;\"><li> <a href=\"https://memoryzone.com.vn/mainboard-pc-asus-prime-h510m-k\" target=\"_blank\">Mainboard PC ASUS PRIME H510M-K</a> </li><li> <a href=\"https://memoryzone.com.vn/mainboard-pc-asus-tuf-gaming-b660m-plus-d4\" target=\"_blank\">Mainboard PC ASUS TUF GAMING B660M-PLUS D4</a> </li><li> <a href=\"https://memoryzone.com.vn/mainboard-pc-asus-rog-strix-b660-a-gaming-wifi-d4\" target=\"_blank\">Mainboard PC ASUS ROG STRIX B660-A GAMING WIFI D4</a> </li><li> <a href=\"https://memoryzone.com.vn/mainboard-pc-asus-tuf-gaming-z690-plus\" target=\"_blank\">Mainboard PC ASUS TUF GAMING Z690-PLUS (DDR5)</a> </li></ul> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 400px;\"><img alt=\"Mainboard Asus\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/mainboard-asus.png?v=1669868149157\" data-origin=\"400,400\" data-proportion=\"true\" data-align=\"center\" data-size=\"400px,400px\" data-file-name=\"mainboard-asus.png?v=1669868149157\" data-file-size=\"0\" origin-size=\"400,400\" style=\"width: 400px; height: 400px;\" data-index=\"2\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">			</p><p style=\"text-align: center;\">								<em>Mainboard Asus</em> </p> <h3>5.2. 				<a href=\"https://memoryzone.com.vn/mainboard-gigabyte\" target=\"_blank\">Mainboard Gigabyte</a> </h3> <p style=\"margin-left: 40px;\">Gigabyte ???????c bi???t ?????n l?? th????ng hi???u n???i b???t v???i c??c d??ng laptop gaming ????nh ????m. B??n c???nh ????, Gigabyte c??n l?? ????n v??? cung c???p c??c s???n ph???m Mainboard ch???t l?????ng v?? ng??y c??ng c?? b?????c ph??t tri???n ?????t ph??. Th????ng hi???u t???p trung ph??t tri???n Mainboard ??? ph??n kh??c t???m trung v?? li??n t???c c???i ti???n ????? n??ng cao tr???i nghi???m kh??ch h??ng.</p> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 640px;\"><img alt=\"Mainboard Gigabyte\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/mainboard-gigabyte.jpg?v=1669868160124\" data-origin=\"640,360\" data-proportion=\"true\" data-align=\"center\" data-size=\"640px,360px\" data-file-name=\"mainboard-gigabyte.jpg?v=1669868160124\" data-file-size=\"0\" origin-size=\"640,360\" style=\"width: 640px; height: 360px;\" data-index=\"3\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">			</p><p style=\"text-align: center;\">								<em>Mainboard Gigabyte</em> </p> <h3>5.3. 				<a href=\"https://memoryzone.com.vn/mainboard-msi\" target=\"_blank\">Mainboard MSI</a> </h3> <p style=\"margin-left: 40px;\">B??n c???nh hai c??i t??n n???i b???t v??? s???n xu???t Mainboard l?? Asus v?? Gigabyte th?? Mainboard MSI c??ng l?? c??i t??n ????ng ???????c vinh danh. Mainboard MSI c?? khuynh h?????ng ph??t tri???n ri??ng d??nh cho m??y t??nh gaming. Ngo??i vi???c mang ?????n nh???ng ?????u t?? ????ng gi?? v??? ch???t l?????ng th?? Mainboard MSI c??n ???????c ????nh gi?? cao v??? t??nh th???m m???.</p> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 500px;\"><img alt=\"Mainboard MSI\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/mainboard-msi.png?v=1669868171468\" data-origin=\"500,400\" data-proportion=\"true\" data-align=\"center\" data-size=\"500px,400px\" data-file-name=\"mainboard-msi.png?v=1669868171468\" data-file-size=\"0\" origin-size=\"500,400\" style=\"width: 500px; height: 400px;\" data-index=\"4\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">			</p><p style=\"text-align: center;\">								<em>Mainboard MSI</em> </p> <h3>54. 				<a href=\"https://memoryzone.com.vn/mainboard-asrock\" target=\"_blank\">Mainboard Asrock</a> </h3> <p style=\"margin-left: 40px;\">Mainboard Asrock s??? l?? g???i ?? l?? t?????ng cho b???n khi t??m ki???m d??ng bo m???ch ch??? d??nh cho v??n ph??ng ?????ng b???. S???n ph???m mang ?????n ????? b???n cao v?? h??n c??? mong ?????i khi d??ng cho c??c t??c v??? m??y t??nh ph??ng v???. Tuy nhi??n, Mainboard Asrock c??ng g???p m???t v??i h???n ch??? nh?? c???p th???p,???????ng t??? l???i,...</p> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 600px;\"><img alt=\"Mainboard Asrock\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/mainboard-asrock-1-jpeg.jpg?v=1669868304057\" data-origin=\"600,400\" data-proportion=\"true\" data-align=\"center\" data-size=\"600px,400px\" data-file-name=\"mainboard-asrock-1-jpeg.jpg?v=1669868304057\" data-file-size=\"0\" origin-size=\"600,400\" style=\"width: 600px; height: 400px;\" data-index=\"5\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">			</p><p style=\"text-align: center;\">								<em>Mainboard Asrock</em> </p> <h2>6. C??c ti??u ch?? l???a mua bo m???ch ch??? ph?? h???p v???i m??y t??nh</h2> <h3>6.1. Ch???n k??ch th?????c bo m???ch ch??? ph?? h???p</h3> <p style=\"margin-left: 40px;\">Khi ???? n???m ???????c Mainboard l?? g??, ng?????i mua c???n n???m v???ng c??c ti??u ch?? ????? l???a ch???n phu h???p. Ti??u ch?? ?????u ti??n khi ch???n mua c??c lo???i bo m???ch ch??? ph?? h???p l?? k??ch th?????c. Tr??n th??? tr?????ng, c??c d??ng bo m???ch ch??? s??? c?? c??c k??ch th?????c:</p> <ul style=\"margin-left: 40px;\"><li> <p> <strong>E-ATX:</strong> Mainboard n??y c?? k??ch th?????c l???n nh???t, r??i v??o kho???ng 30.5cm x 33cm, h??? tr??? nhi???u khe c???m m??? r???ng v?? c?? th??? ch???y song song 2 CPU.					</p> </li><li> <p> <strong>ATX:</strong> Mainboard n??y c?? k??ch th?????c l???n nh???t g???m nhi???u khe c???m v?? c???ng k???t n???i.					</p> </li><li> <p> <strong>Micro ATX:</strong> C?? k??ch th?????c nh??? h??n ATX 2.4 inch, c??c khe c???m m??? r???ng c??ng ??t h??n.					</p> </li><li> <p> <strong>Mini ITX:</strong> ????y l?? Mainboard c?? k??ch th?????c nh??? nh???t v?? ch??? c?? 1 khe c???m card ?????u n???i c??ng h???n ch???.					</p> </li></ul> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 640px;\"><img alt=\"C??c k??ch th?????c bo m???ch ch???\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/cac-kich-thuoc-bo-mach-chu.jpg?v=1669868318280\" data-origin=\"640,321\" data-proportion=\"true\" data-align=\"center\" data-size=\"640px,321px\" data-file-name=\"cac-kich-thuoc-bo-mach-chu.jpg?v=1669868318280\" data-file-size=\"0\" origin-size=\"640,321\" style=\"width: 640px; height: 321px;\" data-index=\"6\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">			</p><p style=\"text-align: center;\">								<em>C??c k??ch th?????c bo m???ch ch???</em> </p> <p style=\"margin-left: 40px;\">				T??y v??o nhu c???u s??? d???ng m?? b???n c?? th??? ch???n cho m??nh bo m???ch ch??? ph?? h???p v?? t???i thi???u chi ph??.							</p> <p style=\"margin-left: 40px;\">				<strong>Xem th??m:</strong> <a href=\"https://memoryzone.com.vn/vram-la-gi-bao-nhieu-gb-vram-la-du\" target=\"_blank\">VRAM l?? g??? Bao nhi??u GB VRAM l?? ????? d??ng? Ph??n bi???t gi???a VRAM v?? RAM b???n n??n bi???t</a> </p> <h3>6.2. Ch???n socket mainboard ph?? h???p v???i CPU</h3> <p style=\"margin-left: 40px;\">L??u ?? khi l???a ch???n bo m???ch ch??? c???n ?????m b???o ????? t????ng th??ch v???i CPU, ????y l?? ??i???u v?? c??ng quan tr???ng. B??n c???nh ????, Socket Mainboard ch??? c?? th??? ho???t ?????ng t???i ??a c??ng xu???t khi k???t h???p v???i d??ng chip m?? n?? h??? tr???. V???y n??n n???u Socket Mainboard c???a b???n kh??ng ph?? h???p v???i CPU th?? s??? kh??ng th??? ho???t ?????ng.</p> <p style=\"text-align: center;\">				</p><div class=\"se-component se-image-container __se__float-center\" contenteditable=\"false\"><figure style=\"margin: auto; width: 640px;\"><img alt=\"N??n l???a ch???n socket mainboard ph?? h???p v???i CPU\" data-thumb=\"original\" src=\"//bizweb.dktcdn.net/100/329/122/files/nen-lua-chon-socket-mainboard-phu-hop-voi-cpu.jpg?v=1669868333687\" data-origin=\"640,360\" data-proportion=\"true\" data-align=\"center\" data-size=\"640px,360px\" data-file-name=\"nen-lua-chon-socket-mainboard-phu-hop-voi-cpu.jpg?v=1669868333687\" data-file-size=\"0\" origin-size=\"640,360\" style=\"width: 640px; height: 360px;\" data-index=\"7\"></figure></div><p style=\"text-align: center;\"><br></p> <p style=\"text-align: center;\">			</p><p style=\"text-align: center;\">								<em>N??n l???a ch???n socket mainboard ph?? h???p v???i CPU ????? ho???t ?????ng t???t h??n</em> </p> <h3>6.3. L???a ch???n mainboard theo ng??n s??ch hi???n c?? c???a b???n</h3> <p style=\"margin-left: 40px;\">Ngo??i hai ti??u ch?? tr??n th?? ng??n s??ch chi tr??? cho Mainboard c??ng l?? ??i???u ho??n to??n c???n thi???t. H??y ??u ti??n c??c bo m???ch ch??? c?? h??? tr??? card wifi, c??c c???ng k???t n???i ??a d???ng, t???c ????? truy???n t???i cao nh?? Thunderbolt 3, USB 3.1 Gen 2,... ????? c?? th??? ????p ???ng t???t c??c nhu c???u v??? h??? t???p, c??ng vi???c hay gi???i tr??.</p> <p style=\"margin-left: 40px;\">				<strong>Xem th??m:</strong> <a href=\"https://memoryzone.com.vn/card-do-hoa-laptop-la-gi\" target=\"_blank\">Card ????? h???a laptop l?? g??? C??ch ch???n card ????? h???a r???i laptop ph?? h???p nhu c???u</a> </p> <p style=\"margin-left: 40px;\">Nh???ng lo???i bo m???ch ch??? gi?? r??? &lt;100$ c?? th??? ho???t ?????ng kh?? ???n ?????nh nh??ng ????? b???n kh??ng cao. C??ng v???i ????, Mainboard kho???ng 100$ s??? ???n ?????nh h??n nh??ng s??? h???n ch??? v??? c??c c???ng k???t n???i. V???y n??n, t???t nh???t b???n n??n ch???n c??c Mainboard c?? gi?? th??nh r??i v??o kho???ng 150$ ????? s??? d???ng ???????c l??u d??i v?? mang ?????n nh???ng tr???i nghi???m t???t h??n.</p> <h2>7. T???ng k???t</h2> <p>Ph??a tr??n l?? nh???ng chia s??? c???a 				<a href=\"https://memoryzone.com.vn/\" target=\"_blank\">Memoryzone</a> v??? c??ch th???c ho???t ?????ng, c???u t???o v?? ch???c n??ng c???a Mainboard. ?????ng th???i c??n gi??p b???n ?????c tr??? l???i ???????c c??u h???i Mainboard l?? g??? Song, vi???c l???a ch???n Mainboard ph?? h???p l?? v?? c??ng c???n thi???t, v???y n??n b???n c???n n???m r?? nh???ng ti??u ch?? tr??n nh??!			</p> <p>C???m ??n b???n ???? theo d??i b??i vi???t v?? n???u c??n b???t k??? th???c m???c n??o, b???n c?? th??? li??n h??? v???i ch??ng t??i ????? ???????c gi???i ????p. ?????ng qu??n c???p nh???t c??c 				<a href=\"https://memoryzone.com.vn/tin-tuc\" target=\"_blank\">tin t???c v??? ki???n th???c c??ng ngh???</a>, b??i vi???t h???u ??ch v?? h??ng ngh??n khuy???n m??i h???p d???n t???i website v?? 				<a href=\"https://www.facebook.com/memoryzonevietnam\" target=\"_blank\">FanpageMemoryzone</a> b???n nh??.			</p> <p> <strong>B??i vi???t li??n quan:</strong> </p> <ul style=\"margin-left: 40px;\"><li> <a href=\"https://memoryzone.com.vn/cach-bat-bluetooth-tren-laptop-va-may-tinh-win-10\" target=\"_blank\">H?????ng d???n c??ch b???t bluetooth tr??n laptop v?? m??y t??nh Win 10 ????n gi???n v?? nhanh g???n 2022</a> </li><li> <a href=\"https://memoryzone.com.vn/top-4-cach-bat-mic-laptop-may-tinh\" target=\"_blank\">Top 4+ C??ch b???t mic laptop, m??y t??nh trong t??ch t???c v?? ????n gi???n nh???t</a> </li><li> <a href=\"https://memoryzone.com.vn/bat-mi-cach-doi-mat-khau-may-tinh-win-10-win-11\" target=\"_blank\">???B???t m????? c??ch ?????i m???t kh???u m??y t??nh Win 10, Win 11</a> </li><li> <a href=\"https://memoryzone.com.vn/cach-ket-noi-wifi-cho-may-tinh-ban\" target=\"_blank\" class=\"on\">C??ch k???t n???i wifi cho m??y t??nh b??n ch??? trong t??ch t???c v?? d??? thao t??c</a></li></ul></div></div></div><div class=\"col-xs-12\"><div class=\"row row-noGutter tag-share\">	<div class=\"col-xs-12 col-sm-6 tag_article \">		<strong>Tags:</strong> <a href=\"/blogs/all/tagged/bo-mach-chu-la-gi\">Bo m???ch ch??? l?? g??</a>, 																					<a href=\"/blogs/all/tagged/card-man-hinh\">card m??n h??nh</a>, 																					<a href=\"/blogs/all/tagged/laptop\">laptop</a>, 																					<a href=\"/blogs/all/tagged/mainboard\">Mainboard</a>, 																					<a href=\"/blogs/all/tagged/mainboard-la-gi\">Mainboard l?? g??</a>, 																					<a href=\"/blogs/all/tagged/may-tinh\">m??y t??nh</a>, 																					<a href=\"/blogs/all/tagged/pc\">PC</a>, 																					<a href=\"/blogs/all/tagged/ram\">RAM</a>, 																					<a href=\"/blogs/all/tagged/ram-may-tinh\">RAM m??y t??nh</a> </div> <div class=\"col-xs-12 col-sm-6\">		<div class=\"social-sharing f-right\">			<div class=\"addthis_inline_share_toolbox share_add\">							</div> </div> </div></div></div>'
  );
INSERT INTO News (`id`, `admin_id`,`title`, `thumbnail`, `content`)
VALUES (
    3,
    3,
    'CPU vi???t t???t c???a t??? g??? C???u t???o, vai tr?? v?? c??c thu???t ng??? li??n quan v??? CPU',
    'https://bizweb.sapocdn.net/thumb/large/100/329/122/articles/cpu-viet-tat-cua-tu-gi.jpg?v=1669807467773',
    '<div class=\"article-details\"><h1 class=\"article-title\"><a href=\"/cpu-viet-tat-cua-tu-gi\">CPU vi???t t???t c???a t??? g??? C???u t???o, vai tr?? v?? c??c thu???t ng??? li??n quan v??? CPU</a></h1> <div class=\"date\"> <i class=\"fa fa-clock-o\"></i> Th??? Wed, <div class=\"news_home_content_short_time\"> 30/11/2022 </div> <div class=\"post-time\"> <i class=\"fa fa-user\" aria-hidden=\"true\"></i> ????ng b???i <span>L??m H???i</span></div></div><div class=\"article-content\"> <div class=\"rte\"> <p><em>CPU vi???t t???t c???a t??? g??? CPU l?? thu???t ng??? quen thu???c ?????i v???i ng?????i d??ng c??ng ngh??? v?? ????y l?? b??? ph???n trong th??? thi???u khi x??? l?? c??c ho???t ?????ng c???a h??? th???ng. V???y c???u t???o, vai tr?? c???a CPU l?? g??? H??y c??ng <a href=\"https://memoryzone.com.vn/\" target=\"_blank\">Memoryzone</a> gi???i ????p trong b??i vi???t sau ????y b???n nh??!</em></p> <p><meta charset=\"utf-8\" /></p> <h2 dir=\"ltr\">1. CPU vi???t t???t c???a t??? g??? Vai tr?? c???a CPU tr??n m??y t??nh</h2> <p dir=\"ltr\"><a href=\"https://memoryzone.com.vn/cpu-may-tinh\" target=\"_blank\">CPU</a> vi???t t???t c???a t??? g??? D??nh cho nh???ng b???n ch??a bi???t th?? CPU c?? t??n ?????y ????? l?? Central Processing Unit v?? ????y l?? b??? x??? l?? trung t??m khi nh???c ?????n c??c thi???t b??? laptop hay m??y t??nh.</p> <p dir=\"ltr\">CPU ???????c xem ph???n kh??ng th??? thi???u c???a m??y t??nh, n?? ???????c v?? nh?? n??o b??? v?? l?? n??i ti???p nh???n, x??? l?? v?? ??i???u khi???n m???i ho???t ?????ng c???a m??y t??nh, laptop. H??n n???a, CPU c??n c?? th??? x??? l?? nhanh ch??ng c??c c??u l???nh, c??c ph??p t??nh s??? h???c si??u ???hack n??o???.</p> <p dir=\"ltr\"><strong>Xem th??m:</strong><a href=\"https://memoryzone.com.vn/cach-kiem-tra-nhiet-do-cpu-may-tinh-ban-va-laptop\" target=\"_blank\">C??ch ki???m tra nhi???t ????? CPU m??y t??nh b??n v?? laptop nhanh ch??ng v?? hi???u qu???</a></p> <p dir=\"ltr\">Ngo??i ra, CPU c??n l?? n??i ti???p nh???n th??ng tin t??? c??c thi???t b??? ngo???i vi nh?? <a href=\"https://memoryzone.com.vn/chuot-gaming-van-phong\" target=\"_blank\">chu???t m??y t??nh</a>, <a href=\"https://memoryzone.com.vn/ban-phim-gaming-van-phong\" target=\"_blank\">b??n ph??m</a>, m??y in,... v?? tr??? v??? k???t qu??? cho ng?????i d??ng qua m??n h??nh ch??nh.</p> <p dir=\"ltr\" style=\"text-align: center;\"><img alt=\"CPU c?? nhi???m v??? ti???p nh???n v?? x??? l?? c??c th??ng tin\" data-thumb=\"original\" original-height=\"400\" original-width=\"600\" src=\"//bizweb.dktcdn.net/100/329/122/files/cpu-co-nhiem-vu-tiep-nhan-va-xu-ly-cac-thong-tin.jpg?v=1669807403153\" /></p> <p dir=\"ltr\" style=\"text-align: center;\"><meta charset=\"utf-8\" /><em>CPU c?? nhi???m v??? ti???p nh???n v?? x??? l?? c??c th??ng tin</em><meta charset=\"utf-8\" /></p> <h2 dir=\"ltr\">2. C???u t???o b??n trong c???a CPU m??y t??nh g???m nh???ng g???</h2> <p dir=\"ltr\">Sau khi ???? t??m hi???u r?? v??? CPU vi???t t???t c???a t??? g??, ng?????i d??ng c??n th???c m???c c???u t???o b??n trong c???a CPU l?? g?? m?? c?? th??? x??? l?? v?? v??n y??u c???u ?????n nh?? v???y?</p> <p dir=\"ltr\">M???t CPU s??? ch???a h??ng t??? c??c b??ng d???n, ch??ng ???????c s???p x???p tr??n nh???ng b???ng m???ch nh??? v?? th???c hi???n c??c ph??p t??nh ????? kh???i ch???y ch????ng tr??nh ???????c l??u tr??? trong b??? nh??? h??? th???ng. CPU s??? bao g???m hai kh???i ch??nh: Kh???i t??nh to??n ALU (Arithmetic Logic Unit) v?? Kh???i ??i???u khi???n CU (Control Unit).</p> <ul style=\"margin-left: 40px;\"> <li aria-level=\"1\" dir=\"ltr\"> <p dir=\"ltr\" role=\"presentation\">Kh???i ??i???u khi???n CU (Control Unit): CU c?? nhi???m v??? l?? phi??n d???ch c??c l???nh ch????ng tr??nh v?? ??i???u khi???n c??c xung nh???p h??? th???ng. CU l?? ph???n c???t l??i c???a b??? x??? l?? g???m c??c m???ch logic.</p></li> <li aria-level=\"1\" dir=\"ltr\"> <p dir=\"ltr\" role=\"presentation\">Kh???i t??nh to??n ALU (Arithmetic Logic Unit): S??? d???ng h??m ????? th???c hi???n c??c y??u c???u v??? ph??p to??n s??? h???c v?? logic.</p></li></ul> <p dir=\"ltr\" role=\"presentation\" style=\"text-align: center;\"><img alt=\"CPU g???m hai kh???i ch??nh l?? ALU v?? CU\" data-thumb=\"original\" original-height=\"400\" original-width=\"534\" src=\"//bizweb.dktcdn.net/100/329/122/files/cpu-gom-hai-khoi-chinh-la-alu-va-cu-jpeg-940c4304-12ba-4dcf-8afc-980c6b272e73.jpg?v=1669807291383\" /></p> <p dir=\"ltr\" role=\"presentation\" style=\"text-align: center;\"><meta charset=\"utf-8\" /><em>CPU g???m hai kh???i ch??nh l?? ALU v?? CU</em><meta charset=\"utf-8\" /></p> <p dir=\"ltr\">Ngo??i hai kh???i tr??n, th?? b??n trong CPU c??n c?? c??c thanh ghi (Registers), Opcode, Ph???n ??i???u khi???n:</p> <ul style=\"margin-left: 40px;\"> <li aria-level=\"1\" dir=\"ltr\"> <p dir=\"ltr\" role=\"presentation\"><strong>Thanh ghi (Registers)</strong>: ???????c xem l?? b??? nh??? c?? dung l?????ng kh?? nh??? nh??ng l???i mang t???c ????? x??? l?? cao. C??c thanh ghi n???m trong CPU ???????c d??ng ????? l??u tr??? t???m c??c to??n h???ng, k???t qu??? c??c ph??p t??nh to??n, ?? nh??? hay ti???p nh???n c??c th??ng tin t??? ALU. Tr??n thanh ghi th?? b??? ?????m ch????ng tr??nh s??? l?? ph???n quan tr???ng nh???t b???i n?? s??? tr??? ?????n c??c l???nh c???n th???c thi ti???p theo.</p></li> <li aria-level=\"1\" dir=\"ltr\"> <p dir=\"ltr\" role=\"presentation\"><strong>Opcode:</strong> Opcode s??? l?? m???t ph???n b??? nh??? d??ng ????? ch???a m?? m??y CPU v?? c?? th??? d??? d??ng th???c hi???n c??c l???nh.</p></li> <li aria-level=\"1\" dir=\"ltr\"> <p dir=\"ltr\" role=\"presentation\"><strong>Ph???n ??i???u khi???n:</strong> C?? nhi???m v??? ??i???u khi???n t???n s??? xung nh???p v?? c??c kh???i. C??c m???ch xung nh???p tr??n h??? th???ng c?? ch???c n??ng ?????ng b??? c??c ho???t ?????ng x??? l?? b??n trong/ ngo??i c???a CPU. Th???i gian gi???a hai xung nh???p g???i l?? chu k??? xung nh???p. C??c xung nh???p h??? th???ng t???o ra c??c xung t??n hi???u c?? th???i gian chu???n s??? ???????c ??o b???ng ????n v??? MHz.</p></li></ul> <p dir=\"ltr\" role=\"presentation\"><strong>Xem th??m:</strong><a href=\"https://memoryzone.com.vn/ram-may-tinh-la-gi\" target=\"_blank\">RAM m??y t??nh l?? g??? M??y t??nh v?? laptop c???n dung l?????ng RAM bao nhi??u l?? ??????</a></p> <h2 dir=\"ltr\">3. T???ng h???p th????ng hi???u CPU ph??? bi???n hi???n nay</h2> <h3 dir=\"ltr\">3.1. Th????ng hi???u CPU Intel</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">Intel l?? h??ng cung c???p CPU cho <a href=\"https://memoryzone.com.vn/laptop\" target=\"_blank\">laptop</a>, m??y t??nh l???n nh???t hi???n nay v???i h??n 50 n??m kinh nghi???m trong l??nh v???c s???n xu???t. C??c chip CPU Intel ???????c ???ng d???ng nhi???u c??ng ngh??? hi???n ?????i v???i c???u h??nh m???nh m??? v?? ch???t l?????ng h??ng ?????u.</p> <p dir=\"ltr\" style=\"margin-left: 40px;\">R???t d??? nh???n th???y 3 d??ng CPU Intel ???????c s??? d???ng r???ng r??i tr??n c??c thi???t b??? laptop PC l???n l?????t l?? <a href=\"https://memoryzone.com.vn/cpu-intel\" target=\"_blank\">Intel Core i</a>, Intel Celeron v?? Intel Pentium.</p> <p dir=\"ltr\" style=\"text-align: center;\"><img alt=\"Intel v?? AMD l?? hai h??ng s???n xu???t CPU n???i ti???ng\" data-thumb=\"original\" original-height=\"360\" original-width=\"640\" src=\"//bizweb.dktcdn.net/100/329/122/files/intel-va-amd-la-hai-hang-san-xuat-cpu-noi-tieng-277a7da8-0577-4d11-8a59-4fd63c079dc3.jpg?v=1669807306958\" /></p> <p dir=\"ltr\" style=\"text-align: center;\"><meta charset=\"utf-8\" /><em>Intel v?? AMD l?? hai h??ng s???n xu???t CPU n???i ti???ng</em><meta charset=\"utf-8\" /></p> <h3 dir=\"ltr\"> 3.2. Th????ng hi???u CPU AMD</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">C??ng v???i ???? l?? CPU ?????n t??? AMD (Advanced Micro Devices). AMD ???????c bi???t ?????n l?? th????ng hi???u s???n xu???t CPU sau Intel v?? d?????ng nh?? c??c s???n ph???m c???a AMD ??ang c?? s??? ????????i ?????u??? v???i CPU Intel. C??? th???: n???u nh?? CPU Intel mang ?????n c??c s???n ph???m Core i3,i5, i7, i9 th?? AMD kh??ng k??m c???nh khi c?? <a href=\"https://memoryzone.com.vn/cpu-amd\" target=\"_blank\">CPU AMD</a> Ryzen 3, Ryzen 5, Ryzen 7, Ryzen 9.</p> <p dir=\"ltr\" style=\"margin-left: 40px;\">S??? c???nh tranh kh???c li???t gi???a Intel v?? AMD s??? mang ?????n cho ng?????i d??ng nhi???u c?? h???i l???a ch???n v?? c??c s???n ph???m CPU s??? ng??y c??ng ??a d???ng, ch???t l?????ng h??n.</p> <p dir=\"ltr\" style=\"margin-left: 40px;\"><strong>Xem th??m:</strong><a href=\"https://memoryzone.com.vn/vram-la-gi-bao-nhieu-gb-vram-la-du\" target=\"_blank\">VRAM l?? g??? Bao nhi??u GB VRAM l?? ????? d??ng? Ph??n bi???t gi???a VRAM v?? RAM b???n n??n bi???t</a></p> <h2 dir=\"ltr\">4. C??c thu???t ng??? li??n quan ?????n CPU m??y t??nh</h2> <h3 dir=\"ltr\">4.1. T???c ????? CPU</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">T???c ????? CPU hay c??n g???i l?? t???c ????? xung nh???p CPU. Thu???t ng??? n??y ???????c hi???u l?? c??c ch??? s??? bi???u th??? s??? chu k??? ho???t ?????ng m?? CPU c?? th??? x??? l?? trong v??ng 1 gi??y, ????n v??? t??nh l?? Gigahertz (GHz). V?? d??? th???c t??? nh??: CPU Intel c?? t???c ????? xung nh???p l?? 3.5 GHz/s th?? CPU ???? c?? th??? th???c hi???n 3.5 t??? chu k??? xoay.</p> <h3 dir=\"ltr\">4.2. ??p xung CPU</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">??i ????i v???i thu???t ng??? t???c ????? xung nh???p CPU s??? l?? ??p xung CPU. V???y thu???t ng??? ??p xung CPU ???????c hi???u nh?? th??? n??o? ??p xung CPU l?? c??ch th??c ?????y v?? gi??p t??ng t???c ????? CPU h??n m???c b??nh th?????ng. ??i???u n??y ???????c hi???u l?? khi ??p xung CPU m??y t??nh s??? ho???t ?????ng m???t c??ch m???nh m??? h??n, t??ng n??ng su???t v?? t???c ????? x??? l?? c??c y??u c???u t??? ng?????i d??ng.</p> <h3 dir=\"ltr\">4.3. CPU usage</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">CPU Usage l?? thu???t ng??? ???????c d??ng ????? n??i v??? dung l?????ng s??? d???ng CPU (vi???t d?????i d???ng %). Ch??? s??? CPU Usage th??? hi???n t???c ????? x??? l?? tr??n m??y l?? m???nh hay y???u, n???u CPU Usage c??ng cao th?? m??y ??ang ho???t ?????ng k??m hi???u qu??? v?? ng?????c l???i. Ch??? khi n??o ch??? s??? CPU Usage gi???m xu???ng th?? t???c ????? v?? c??ng su???t m??y t??nh m???i ???????c c???i thi???n.</p> <p dir=\"ltr\" style=\"text-align: center;\"><img alt=\"T??m hi???u c??c thu???t ng??? xoay quanh CPU\" data-thumb=\"original\" original-height=\"400\" original-width=\"626\" src=\"//bizweb.dktcdn.net/100/329/122/files/tim-hieu-cac-thuat-ngu-xoay-quanh-cpu-1-1.jpg?v=1669807212527\" /></p> <p dir=\"ltr\" style=\"text-align: center;\"><meta charset=\"utf-8\" /><em>T??m hi???u c??c thu???t ng??? xoay quanh CPU</em><meta charset=\"utf-8\" /></p> <h3 dir=\"ltr\"> 4.4. Socket CPU</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">Ch??n Socket l?? t??n g???i kh??c c???a Socket CPU ????y l?? b??? ph???n c?? nhi???m v??? k???t n???i chip CPU v?? b??? ph???n bo m???ch ch???. Socket CPU s??? gi??? cho CPU ???????c c??? ?????nh t???i m???t ch???, kh??ng b??? x?? d???ch hay va ch???m v???i c??c b??? ph???n kh??c khi ng?????i d??ng di chuy???n CPU. Kh??ng ph???i ch??n Socket n??o c??ng c?? th??? ??i c??ng CPU b???t k??? m?? m???i lo???i s??? c?? ch??n Socket ri??ng. V???y n??n b???n c???n l???a ch???n ch??n Socket ph?? h???p v???i CPU c???a m??nh.</p> <p dir=\"ltr\" style=\"margin-left: 40px;\"><strong>Xem th??m:</strong><a href=\"https://memoryzone.com.vn/card-do-hoa-laptop-la-gi\" target=\"_blank\">Card ????? h???a laptop l?? g??? C??ch ch???n card ????? h???a r???i laptop ph?? h???p nhu c???u</a></p> <h3 dir=\"ltr\">4.5. CPU Tray</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">CPU Tray l?? g??? Thu???t ng??? n??y ch???c h???n kh??ng c??n m???i m??? g?? v???i d??n c??ng ngh??? nh??ng c?? th??? v???i nh???ng b???n m???i ti???p x??c th?? kh?? m?? bi???t ?????n. CPU Tray hay c??n ???????c g???i l?? CPU h??ng Tray d??ng ????? n??i v??? m???t CPU kh??ng k??m qu???t v?? kh??ng c?? h???p ?????ng ri??ng. Kh??c v???i CPU Tray, CPU h??ng box s??? bao g???m c??? qu???t v?? h???p ?????ng.</p> <p dir=\"ltr\" style=\"margin-left: 40px;\">S??? d?? CPU Tray kh??c v???i CPU box l?? v?? ????y l?? nh???ng s???n ph???m ???????c b??n v???i s??? l?????ng l???n cho c??c nh?? s???n xu???t ph??? t??ng g???c. B???i h??? s??? l???p ?????t tr???c ti???p CPU ???? v??o laptop hay <a href=\"https://memoryzone.com.vn/pc-st\" target=\"_blank\">PC m??y t??nh b??n</a>n??n s??? kh??ng bao g???m h???p ?????ng b??y b???n. C??ng v???i ????, CPU kh??ng bao g???m qu???t l?? v?? b??n mua s??? t??y bi???n v?? l???a ch???n h??? th???ng t???n nhi???t cho ph?? h???p v???i c???u h??nh m??y m?? h??? mong mu???n.</p> <p dir=\"ltr\" style=\"margin-left: 40px;\"><strong>Tham kh???o th??m:</strong></p> <ul dir=\"ltr\" style=\"margin-left: 80px;\"> <li><a href=\"https://memoryzone.com.vn/pc-mercury-series\" target=\"_blank\">PC Mercury Series</a></li> <li><a href=\"https://memoryzone.com.vn/pc-venus-series\" target=\"_blank\">PC Venus Series</a></li> <li><a href=\"https://memoryzone.com.vn/pc-titan-series\" target=\"_blank\">PC Titan Series</a></li> <li><a href=\"https://memoryzone.com.vn/pc-moonator-series\" target=\"_blank\">PC Moonator Series</a></li> <li><a href=\"https://memoryzone.com.vn/pc-neptune-series\" target=\"_blank\">PC Neptune Series</a></li></ul> <h2 dir=\"ltr\">5. C??u h???i th?????ng g???p</h2> <h3 dir=\"ltr\">5.1. CPU c?? t???c ????? x??? l?? ra sao?</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">T???c ????? x??? l?? CPU tr??n t???ng m??y s??? c?? s??? kh??c nhau. ??i???u n??y ph??? thu???c v??o t???c ????? xung nh???p CPU, ???????c t??nh b???ng bi???u th??? chu k??? ho???t ?????ng m?? CPU c?? th??? x??? l?? trong v??ng 1 gi??y. Nh??? v??o t???c ????? xung nh???p ???? m?? ng?????i d??ng c?? th??? t??nh to??n ???????c l?? CPU x??? l?? nhanh hay ch???m.</p> <h3 dir=\"ltr\">5.2. Chip v???i CPU c?? ph???i l?? m???t?</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">????? tr??? l???i ???????c c??u h???i n??y, tr?????c ti??n b???n c???n bi???t v??? ?????nh ngh??a c???a chip. Chip (hay g???i l?? vi m???ch) g???m c??c m???ch ??i???n ch???a linh ki???n b??n d???n v?? linh ki???n ??i???n t??? th??? ?????ng, ch??ng k???t n???i v???i nhau v?? c??ng th???c hi???n m???t ch???c n??ng n??o ????.</p> <p dir=\"ltr\" style=\"margin-left: 40px;\">C??n v???i CPU, nh?? ???? t??m hi???u ??? tr??n v???CPU vi???t t???t c???a t??? g?? v?? ?????nh ngh??a th??CPU s??? ch???a h??ng t??? c??c b??ng d???n, ch??ng ???????c s???p x???p tr??n nh???ng b???ng m???ch nh??? v???i ch???c n??ng l?? x??? l?? th??ng tin. V???y n??n c?? th??? xem chip v?? CPU l?? m???t.</p> <h3 dir=\"ltr\">5.3. Chipset so v???i chip kh??c nhau th??? n??o?</h3> <p dir=\"ltr\" style=\"margin-left: 40px;\">Chipset ??? ????y ???????c hi???u l?? m???t t???p h???p chip, ngh??a l?? nhi???u chip ??i v???i nhau v?? c??ng l??m m???t nhi???m v???. Chipset th?????ng ???????c nh???c ?????n khi ????? c???p ?????n m???t chip ?????c bi???t tr??n mainboard hay c??c card m??? r???ng.</p> <h2 dir=\"ltr\">6. T???ng k???t</h2> <p dir=\"ltr\"><a href=\"https://memoryzone.com.vn/\" target=\"_blank\">Memoryzone</a> hy v???ng r???ng qua b??i vi???t tr??n b???n ?????c ???? hi???u r?? v??? CPU v?? tr??? l???i ???????c c??u h???i ???CPU vi???t t???t c???a t??? g????? hay nh???ng thu???t ng??? li??n quan ?????n CPU. Li??n h??? v???i ch??ng t??i ????? ???????c gi???i ????p c??c th???c m???c n???u c?? v?? th?????ng xuy??n c???p nh???t c??c <a href=\"https://memoryzone.com.vn/tin-tuc\" target=\"_blank\">tin t???c</a>, b??i vi???t m???i nh???t t???i website Memoryzone b???n nh??!</p> <p dir=\"ltr\"><strong>B??i vi???t li??n quan:</strong></p> <ul dir=\"ltr\" style=\"margin-left: 40px;\"> <li><a href=\"https://memoryzone.com.vn/bat-mi-cach-bat-den-led-ban-phim-tren-may-tinh-va-laptop\">B???t m?? c??ch b???t ????n led b??n ph??m tr??n m??y t??nh v?? c??c d??ng laptop Dell, Asus, Acer</a></li> <li><a href=\"https://memoryzone.com.vn/huong-dan-tai-coc-coc-ve-may-tinh-mien-phi\">H?????ng d???n t???i C???c C???c v??? m??y t??nh mi???n ph?? v?? c??i ?????t ch??? trong 5 ph??t</a></li> <li><a href=\"https://memoryzone.com.vn/cach-ket-noi-wifi-cho-may-tinh-ban\">C??ch k???t n???i wifi cho m??y t??nh b??n ch??? trong t??ch t???c v?? d??? thao t??c</a></li> <li><a href=\"https://memoryzone.com.vn/cach-ket-noi-chuot-khong-day-voi-laptop\">C??ch k???t n???i chu???t kh??ng d??y v???i laptop trong t??ch t???c v?? ????n gi???n nh???t</a></li></ul> </div> </div> </div> <div class=\"col-xs-12\"> <div class=\"row row-noGutter tag-share\"> <div class=\"col-xs-12 col-sm-6 tag_article \"> <b>Tags:</b> <a href=\"/blogs/all/tagged/alu\">ALU</a>, <a href=\"/blogs/all/tagged/amd\">AMD</a>, <a href=\"/blogs/all/tagged/cpu\">CPU</a>, <a href=\"/blogs/all/tagged/cpu-viet-tat-cua-tu-gi\">CPU vi???t t???t c???a t??? g??</a>, <a href=\"/blogs/all/tagged/laptop\">Laptop</a> </div> <div class=\"col-xs-12 col-sm-6\"> <div class=\"social-sharing f-right\"> <div class=\"addthis_inline_share_toolbox share_add\"> <script type=\"text/javascript\" src=\"//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-58589c2252fc2da4\"></script> </div> </div> </div> </div> </div>'
  );

INSERT INTO Comment (`product_id`, `customer_id`, `admin_id`, `comment`, `updated_at`,`num_rate`, `status`) VALUES (2, 3, 1, 'S???n ph???m t???t', '2022-11-06 11:06:37', 5, 'Ch??a ph???n h???i');
INSERT INTO Comment (`product_id`, `customer_id`, `admin_id`, `comment`, `updated_at`,`num_rate`, `status`) VALUES (1, 1, 2, 'S???n ph???m t???t', '2022-11-06 11:06:37', 3, 'Ch??a ph???n h???i');
INSERT INTO Comment (`product_id`, `customer_id`, `admin_id`, `comment`, `updated_at`,`num_rate`, `status`) VALUES (3, 2, 3, 'S???n ph???m t???t', '2022-11-06 11:06:37', 4, 'Ch??a ph???n h???i');
INSERT INTO Comment (`product_id`, `customer_id`, `admin_id`, `comment`, `updated_at`,`num_rate`, `status`) VALUES (2, 4, 1, 'S???n ph???m t???t', '2022-11-06 11:06:37', 4, '???? ph???n h???i');
INSERT INTO Comment (`product_id`, `customer_id`, `admin_id`, `comment`, `updated_at`,`num_rate`, `status`) VALUES (3, 2, 2, 'S???n ph???m t???t', '2022-11-06 11:06:37', 5, '???? ph???n h???i');
INSERT INTO Comment (`product_id`, `customer_id`, `admin_id`, `comment`, `updated_at`,`num_rate`, `status`) VALUES (1, 2, 3, 'S???n ph???m t???t', '2022-11-06 11:06:37', 5, '???? ph???n h???i');

-- Resource
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (1, 'uploads/slider1.jpg', NULL);
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (2, 'uploads/slider2.jpg', NULL);
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (3, 'uploads/slider3.jpg', NULL);
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (4, 'uploads/news1.jpg', NULL);
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (5, 'uploads/news2.jpg', NULL);
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (6, 'uploads/news3.jpg', NULL);
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (7, 'uploads/logo.jpg', NULL);
INSERT INTO Resource (`id`, `name`, `data`)
VALUES (8, 'uploads/demo.mp4', NULL);
DROP FUNCTION IF EXISTS random_integer;
CREATE FUNCTION random_integer(value_minimum INT, value_maximum INT) RETURNS INT RETURN FLOOR(
  value_minimum + RAND() * (value_maximum - value_minimum + 1)
);
USE bkzone_2022;

INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (1,'59/6/12 Nguy???n ????nh Chi???u, Ph?????ng 4, Qu???n 3, Th??nh ph??? H??? Ch?? Minh',     'Minh Vuong', '039768114', 'momo',  '2022-12-1 10:24:25 10:24:25','waiting',67516694);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (2,'98 Nguy???n ????nh Chi???u Dist1, Th??nh ph??? H??? Ch?? Minh',                      'Minh Vuong', '039768114', 'cash',  '2022-12-1 10:24:25','confirmed',58139323);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (3,'98 Nguy???n ????nh Chi???u Dist1, Th??nh ph??? H??? Ch?? Minh',                      'Minh Vuong', '039768114', 'cash',  '2022-12-1 10:24:25','confirmed',78968476);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (4,'K18 Luy Ban Bich Street Tan Thoi Hoa Ph?????ng, Th??nh ph??? H??? Ch?? Minh',     'Tuan Hao',   '039768114', 'qrcode','2022-12-1 10:24:25','waiting',67516694);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (5,'18 Luy Ban Bich Street Tan Thoi Hoa Ph?????ng, Th??nh ph??? H??? Ch?? Minh',      'Quoc Thai',  '039768114', 'vnpay', '2022-12-1 10:24:25','waiting',52439323);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (6,'98 Nguy???n ????nh Chi???u, Qu???n 1, Th??nh ph??? H??? Ch?? Minh',                    'Kha Sang',   '039768114', 'momo',  '2022-12-1 10:24:25','confirmed',14344335);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (7,'298 Nguyen Trong Tuyen, Ph?????ng 1, Th??nh ph??? H??? Ch?? Minh',                'Kha Sang',   '039768114', 'momo',  '2022-12-1 10:24:25','waiting',43333344);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (8,'18 Luy Ban Bich Street Tan Thoi Hoa Ph?????ng, Th??nh ph??? H??? Ch?? Minh',      'Kha Sang',   '039768114', 'qrcode','2022-12-1 10:24:25','confirmed',78225013);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (9,'K?? t??c x?? khu A, ???????ng t??? Quang B???u, khu ph??? 6, Linh Trung, Th??? ?????c',    'Tuan Hao',   '039768114', 'qrcode','2022-12-1 10:24:25','confirmed',59821003);
INSERT INTO `Orders` (customer_id,`address`,receiverName,phoneNumber, paymentMethod, create_at, `status`,total_order_money) VALUE (10,'K18 Luy Ban Bich Street Tan Thoi Hoa Ph?????ng, Th??nh ph??? H??? Ch?? Minh',     'Tuan Hao',   '039768114', 'qrcode','2022-12-1 10:24:25','waiting',75122036);
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (1,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (1,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (2,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (2,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (3,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (3,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (4,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (4,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (5,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (5,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (6,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (6,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (7,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (7,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (8,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (8,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (9,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (9,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (10,random_integer(1,20), random_integer(1,10));
INSERT INTO `OrderDetail` (order_id,product_id, quantity) VALUE (10,random_integer(1,20), random_integer(1,10));

INSERT INTO Address (user_id, city, district, ward, specificAddress, phoneNumber, receiverName, `type`) VALUES
(1, N'B???c Giang', N'Huy???n L???c Ng???n', N'X?? Ngh??a H???', N'S??? nh?? 1', '0923236277', N'Nguy???n V??n Anh', 1),
(2, N'L??m ?????ng', N'Huy???n ????? T???h', N'X?? Qu???c Oai', N'S??? nh?? 2', '0923236277', N'Nguy???n Huy Qu???c', 0),
(3, N'H??? Ch?? Minh', N'Qu???n 3', N'Ph?????ng 11', N'S??? nh?? 3', '0923236277', N'Kh??u V??nh To??n', 1),
(4, N'H??? Ch?? Minh', N'Qu???n 3', N'Ph?????ng 01', N'S??? nh?? 4', '0923236277', N'Ch??u Ng???c Anh', 1),
(5, N'H??? Ch?? Minh', N'Th??? ?????c', N'Linh Trung', N'K?? t??c x?? khu A', '0923236277', N'Li???u Minh V????ng', 1),
(6, N'H??? Ch?? Minh', N'Qu???n 4', N'Ph?????ng 12', N'S??? nh?? 6', '0923236277', N'M???nh Gia Khi??m', 1),
(7, N'H??? Ch?? Minh', N'Qu???n 11', N'Ph?????ng 05', N'S??? nh?? 7', '0923236277', N'M??u C??ng H???u', 1),
(8, N'TPHCM', N'Th??? ?????c', N'Linh Trung', N'S??? nh?? 8', '0923236277', N'Lyly ????ng D????ng', 1),
(9, N'S??c Tr??ng', N'Huy???n Long Ph??', N'X?? Ph?? H???u', N'S??? nh?? 9', '0923236277', N'Ng???c Quang H??a', 1),
(1, N'S??c Tr??ng', N'Th??? x?? Ng?? N??m', N'X?? M??? B??nh', N'S??? nh?? 9', '0923236277', N'Mai ????nh Ph??c', 1),
(2, N'C???n Th??', N'Qu???n C??i R??ng', N'Ph?????ng Ph?? Th???', N'S??? nh?? 9', '0923236277', N'C???ng B???o Hi???n', 1),
(3, N'C???n Th??', N'C???n Th??', N'Huy???n Th???i Lai', N'S??? nh?? 9', '0923236277', N'Tr???n ????nh Nam', 1);


INSERT INTO Cart_item(cart_id, product_id, quantity) VALUES
(1, 1 ,2),
(1, 3, 2),
(1, 2, 2),
(1, 8, 2),
(1, 4, 1),
(2, 2, 2),
(2, 4, 3),
(2, 3, 2),
(3, 8, 1),
(4, 8, 1),
(5, 8, 1),
(6, 8, 1),
(7, 8, 3),
(8, 8, 2),
(9, 8, 1);







