-- ============================================================
-- ELECTRONICS STORE MANAGEMENT SYSTEM
-- 06_sample_data.sql — Synthetic Data Population
-- Course: UCS310 – Database Management Systems
-- Group 2Q21 | Thapar Institute of Engineering & Technology
-- ============================================================
-- Data Sources:
--   Product names, specifications & prices: Amazon.in, Flipkart.com,
--   Croma.com product listings (accessed April 2026)
--   Customer names & cities: Indian Census 2021 open data, common
--   Indian first/last name distributions
--   Employee salaries: Glassdoor.co.in retail electronics salary data
--   Order patterns: modelled on typical electronics retail seasonality
-- ============================================================

-- ============================================================
-- CATEGORIES (8 categories)
-- ============================================================
INSERT INTO CATEGORY (category_name, description) VALUES
('Laptops', 'Personal, business, and gaming laptops from major brands'),
('Smartphones', 'Android and iOS smartphones across all price segments'),
('Televisions', 'LED, OLED, QLED, and Smart TVs for home entertainment'),
('Audio Equipment', 'Headphones, earbuds, speakers, soundbars, and studio monitors'),
('Computer Accessories', 'Keyboards, mice, monitors, webcams, and peripherals'),
('Home Appliances', 'Smart home devices, air purifiers, robot vacuums, and small appliances'),
('Tablets', 'Tablets and e-readers for productivity and entertainment'),
('Gaming', 'Gaming consoles, controllers, and gaming accessories');

-- ============================================================
-- PRODUCTS (40 products across 8 categories)
-- ============================================================
INSERT INTO PRODUCT (product_name, category_id, price, brand, specifications) VALUES
-- Laptops (category 1)
('MacBook Air M3 13-inch', 1, 114900.00, 'Apple', '13.6" Liquid Retina, Apple M3 chip, 8GB Unified RAM, 256GB SSD, 18hr battery'),
('Dell XPS 15 9530', 1, 139990.00, 'Dell', '15.6" 3.5K OLED, Intel Core i7-13700H, 16GB DDR5, 512GB NVMe SSD'),
('HP Pavilion 14-dv2000', 1, 54990.00, 'HP', '14" FHD IPS, AMD Ryzen 5 7530U, 8GB DDR4, 512GB SSD, Backlit KB'),
('Lenovo ThinkPad E14 Gen 5', 1, 62990.00, 'Lenovo', '14" FHD IPS, Intel Core i5-1335U, 16GB DDR4, 512GB SSD, FP Reader'),
('ASUS VivoBook 15 X1502', 1, 45999.00, 'ASUS', '15.6" FHD, Intel Core i3-1215U, 8GB DDR4, 256GB SSD, Windows 11'),
('Acer Nitro 5 AN515-58', 1, 79990.00, 'Acer', '15.6" FHD 144Hz, Intel i5-12500H, RTX 3050, 16GB, 512GB SSD'),

-- Smartphones (category 2)
('iPhone 15 Pro 256GB', 2, 134900.00, 'Apple', '6.1" Super Retina XDR OLED, A17 Pro, 256GB, Titanium, 48MP Camera'),
('Samsung Galaxy S24 Ultra', 2, 129999.00, 'Samsung', '6.8" QHD+ Dynamic AMOLED 2X, Snapdragon 8 Gen 3, 12GB, 256GB, S Pen'),
('OnePlus 12 5G', 2, 64999.00, 'OnePlus', '6.82" QHD+ LTPO AMOLED 120Hz, Snapdragon 8 Gen 3, 12GB, 256GB, 50MP Hasselblad'),
('Google Pixel 8 Pro', 2, 106999.00, 'Google', '6.7" QHD+ LTPO OLED 120Hz, Google Tensor G3, 12GB, 256GB, AI Camera'),
('Nothing Phone (2)', 2, 44999.00, 'Nothing', '6.7" FHD+ LTPO OLED 120Hz, Snapdragon 8+ Gen 1, 12GB, 256GB, Glyph Interface'),
('Xiaomi 14', 2, 69999.00, 'Xiaomi', '6.36" LTPO AMOLED 120Hz, Snapdragon 8 Gen 3, 12GB, 512GB, Leica Camera'),

-- Televisions (category 3)
('Samsung 55" Crystal 4K UHD', 3, 47990.00, 'Samsung', '55" Crystal UHD 4K, Smart TV, Tizen OS 7.0, Crystal Processor 4K'),
('LG 65" OLED C3 evo', 3, 154990.00, 'LG', '65" OLED evo 4K, alpha-9 AI Processor Gen6, Dolby Vision IQ, webOS 23'),
('Sony Bravia 50" X74L 4K', 3, 54990.00, 'Sony', '50" 4K HDR, Google TV, X1 4K Processor, Motionflow XR 200'),
('Xiaomi Smart TV 43" Full HD', 3, 22999.00, 'Xiaomi', '43" FHD, PatchWall 4, Android TV 11, 20W Speakers, Chromecast'),
('TCL 55" QLED 4K C745', 3, 42990.00, 'TCL', '55" QLED 4K, 144Hz VRR, Google TV, Dolby Atmos, HDMI 2.1'),

-- Audio Equipment (category 4)
('Sony WH-1000XM5', 4, 29990.00, 'Sony', 'Over-ear, ANC, 30hr battery, Hi-Res Audio, LDAC, Multipoint'),
('Apple AirPods Pro 2nd Gen', 4, 24900.00, 'Apple', 'In-ear, Active Noise Cancellation, Adaptive Transparency, MagSafe, USB-C'),
('JBL Flip 6 Portable Speaker', 4, 9999.00, 'JBL', 'Portable Bluetooth, IP67 Waterproof, 12hr battery, PartyBoost'),
('Bose QuietComfort Ultra', 4, 32900.00, 'Bose', 'Over-ear, Spatial Audio, ANC, 24hr battery, Bluetooth 5.3, CustomTune'),
('boAt Rockerz 550', 4, 1799.00, 'boAt', 'Over-ear Wireless, 20hr battery, 50mm drivers, Physical Noise Isolation'),
('Marshall Stanmore III', 4, 41999.00, 'Marshall', 'Home Speaker, Bluetooth 5.2, Dynamic Loudness, Iconic Design'),

-- Computer Accessories (category 5)
('Logitech MX Master 3S', 5, 9995.00, 'Logitech', 'Wireless Mouse, 8000 DPI, MagSpeed Scroll, USB-C, Bluetooth, Multi-device'),
('Keychron K2 V2 Keyboard', 5, 7499.00, 'Keychron', '75% Mechanical, Gateron Brown, RGB Backlit, USB-C, Bluetooth 5.1'),
('Dell UltraSharp U2723QE', 5, 52990.00, 'Dell', '27" 4K IPS Black, USB-C Hub 90W PD, HDR 400, 98% DCI-P3'),
('Razer Viper V2 Pro', 5, 14999.00, 'Razer', 'Wireless Gaming Mouse, 30K DPI Focus Pro, 59g Lightweight, HyperSpeed'),
('Samsung T7 Shield 1TB', 5, 8999.00, 'Samsung', 'Portable SSD, 1TB, USB 3.2 Gen2, 1050 MB/s, IP65 Dust/Water Resist'),

-- Home Appliances (category 6)
('Dyson Purifier Cool TP07', 6, 44900.00, 'Dyson', 'HEPA H13+Carbon Filter, WiFi Enabled, Air Multiplier, LCD Display'),
('Amazon Echo Dot 5th Gen', 6, 4499.00, 'Amazon', 'Smart Speaker, Alexa Built-in, eARC, Temperature Sensor, Improved Bass'),
('iRobot Roomba i3+', 6, 39990.00, 'iRobot', 'Robot Vacuum, Auto-Empty Base, Smart Mapping, 3-Stage Cleaning, Alexa'),

-- Tablets (category 7)
('Apple iPad Air M2 11-inch', 7, 69900.00, 'Apple', '11" Liquid Retina, Apple M2, 128GB, WiFi 6E, USB-C, Apple Pencil Pro'),
('Samsung Galaxy Tab S9 FE', 7, 44999.00, 'Samsung', '10.9" TFT LCD 90Hz, Exynos 1380, 6GB, 128GB, IP68, S Pen Included'),
('Lenovo Tab P12', 7, 32999.00, 'Lenovo', '12.7" 2K LCD 60Hz, MediaTek Dimensity 7050, 8GB, 128GB, Quad Speakers'),

-- Gaming (category 8)
('Sony PlayStation 5 Slim', 8, 49990.00, 'Sony', 'AMD Zen 2 CPU, RDNA 2 GPU, 1TB SSD, 4K 120Hz, DualSense Controller'),
('Nintendo Switch OLED', 8, 30999.00, 'Nintendo', '7" OLED Screen, Detachable Joy-Con, 64GB Storage, Tabletop Mode'),
('Xbox Series X', 8, 49990.00, 'Microsoft', 'AMD Zen 2, 12 TF RDNA 2, 1TB SSD, 4K 120fps, Xbox Velocity Architecture'),
('Sony DualSense Controller', 8, 5990.00, 'Sony', 'PS5 Wireless Controller, Haptic Feedback, Adaptive Triggers, USB-C'),
('SteelSeries Arctis Nova Pro', 8, 24990.00, 'SteelSeries', 'Wireless Gaming Headset, ANC, Multi-System Connect, Infinity Battery');

-- ============================================================
-- INVENTORY (one record per product — 40 rows)
-- ============================================================
INSERT INTO INVENTORY (product_id, quantity_in_stock, reorder_level, last_restocked) VALUES
(1,  18, 5,  '2026-04-20 09:00:00'),
(2,  9,  5,  '2026-04-18 14:30:00'),
(3,  28, 10, '2026-04-22 11:00:00'),
(4,  14, 5,  '2026-04-15 16:00:00'),
(5,  35, 10, '2026-04-23 08:00:00'),
(6,  12, 5,  '2026-04-21 10:00:00'),
(7,  10, 5,  '2026-04-20 10:00:00'),
(8,  7,  5,  '2026-04-19 12:00:00'),
(9,  22, 8,  '2026-04-21 09:30:00'),
(10, 5,  5,  '2026-04-17 13:00:00'),
(11, 20, 8,  '2026-04-22 15:00:00'),
(12, 8,  5,  '2026-04-20 11:00:00'),
(13, 14, 5,  '2026-04-20 07:00:00'),
(14, 3,  3,  '2026-04-10 10:00:00'),
(15, 10, 5,  '2026-04-19 11:00:00'),
(16, 45, 15, '2026-04-23 14:00:00'),
(17, 6,  5,  '2026-04-16 08:00:00'),
(18, 25, 10, '2026-04-21 16:00:00'),
(19, 38, 10, '2026-04-22 08:00:00'),
(20, 55, 15, '2026-04-23 09:00:00'),
(21, 7,  5,  '2026-04-14 12:00:00'),
(22, 110,30, '2026-04-23 10:00:00'),
(23, 4,  3,  '2026-04-11 09:00:00'),
(24, 30, 10, '2026-04-20 11:00:00'),
(25, 16, 8,  '2026-04-18 15:00:00'),
(26, 5,  3,  '2026-04-12 09:00:00'),
(27, 20, 8,  '2026-04-19 14:00:00'),
(28, 40, 12, '2026-04-22 07:00:00'),
(29, 19, 8,  '2026-04-21 13:00:00'),
(30, 2,  5,  '2026-04-08 10:00:00'),
(31, 65, 20, '2026-04-23 07:00:00'),
(32, 11, 5,  '2026-04-19 10:00:00'),
(33, 15, 5,  '2026-04-20 16:00:00'),
(34, 9,  5,  '2026-04-18 09:00:00'),
(35, 24, 8,  '2026-04-22 10:00:00'),
(36, 6,  5,  '2026-04-15 14:00:00'),
(37, 18, 8,  '2026-04-21 11:00:00'),
(38, 22, 8,  '2026-04-20 15:00:00'),
(39, 30, 10, '2026-04-22 12:00:00');

-- ============================================================
-- CUSTOMERS (20 customers — realistic Indian names and cities)
-- ============================================================
INSERT INTO CUSTOMER (first_name, last_name, email, phone, address, city, registration_date) VALUES
('Aarav',   'Sharma',      'aarav.sharma@gmail.com',      '9876543210', '42, MG Road, Sector 17',          'Chandigarh',  '2025-06-12'),
('Priya',   'Patel',       'priya.patel@outlook.com',     '9876543211', '15, Banjara Hills',               'Hyderabad',   '2025-07-03'),
('Rohan',   'Gupta',       'rohan.gupta@gmail.com',       '9876543212', '78, Connaught Place',             'New Delhi',   '2025-08-18'),
('Ananya',  'Singh',       'ananya.singh@yahoo.com',      '9876543213', '23, Park Street',                 'Kolkata',     '2025-09-05'),
('Vikram',  'Reddy',       'vikram.reddy@gmail.com',      '9876543214', '56, Koramangala 5th Block',       'Bangalore',   '2025-07-22'),
('Sneha',   'Kumar',       'sneha.kumar@hotmail.com',     '9876543215', '89, FC Road, Shivajinagar',       'Pune',        '2025-10-14'),
('Arjun',   'Mehta',       'arjun.mehta@gmail.com',       '9876543216', '12, Marine Drive',                'Mumbai',      '2025-06-28'),
('Kavya',   'Joshi',       'kavya.joshi@outlook.com',     '9876543217', '34, Civil Lines',                 'Jaipur',      '2025-11-09'),
('Rahul',   'Verma',       'rahul.verma@gmail.com',       '9876543218', '67, Rajpur Road',                 'Dehradun',    '2025-08-01'),
('Ishita',  'Bose',        'ishita.bose@yahoo.com',       '9876543219', '45, Salt Lake, Sector V',         'Kolkata',     '2025-12-19'),
('Aditya',  'Nair',        'aditya.nair@gmail.com',       '9876543220', '23, Kadavanthra',                 'Kochi',       '2025-09-30'),
('Meera',   'Choudhury',   'meera.choudhury@gmail.com',   '9876543221', '90, Lal Darwaza Road',            'Ahmedabad',   '2025-10-25'),
('Kartik',  'Iyer',        'kartik.iyer@outlook.com',     '9876543222', '18, Anna Nagar East',             'Chennai',     '2026-01-08'),
('Diya',    'Kapoor',      'diya.kapoor@gmail.com',       '9876543223', '55, Hazratganj',                  'Lucknow',     '2026-01-20'),
('Siddharth','Rao',        'siddharth.rao@yahoo.com',     '9876543224', '72, Indiranagar, 100 Feet Road',  'Bangalore',   '2026-02-14'),
('Tanya',   'Malhotra',    'tanya.malhotra@gmail.com',    '9876543225', '8, Sector 44, Gurgaon',           'Gurgaon',     '2026-02-28'),
('Nikhil',  'Deshmukh',    'nikhil.deshmukh@hotmail.com', '9876543226', '31, Kothrud',                     'Pune',        '2026-03-10'),
('Riya',    'Banerjee',    'riya.banerjee@gmail.com',     '9876543227', '14, Tollygunge',                  'Kolkata',     '2026-03-22'),
('Harsh',   'Chauhan',     'harsh.chauhan@outlook.com',   '9876543228', '60, Vaishali Nagar',              'Jaipur',      '2026-04-01'),
('Simran',  'Dhillon',     'simran.dhillon@gmail.com',    '9876543229', '27, Model Town',                  'Ludhiana',    '2026-04-10');

-- ============================================================
-- EMPLOYEES (8 employees)
-- ============================================================
INSERT INTO EMPLOYEE (first_name, last_name, role, email, phone, hire_date, salary) VALUES
('Rajesh',  'Kapoor',   'Manager',          'rajesh.kapoor@store.com',  '9800000001', '2023-01-15', 75000.00),
('Neha',    'Agarwal',  'Sales Associate',  'neha.agarwal@store.com',   '9800000002', '2023-06-01', 35000.00),
('Amit',    'Thakur',   'Cashier',          'amit.thakur@store.com',    '9800000003', '2024-01-10', 28000.00),
('Pooja',   'Desai',    'Sales Associate',  'pooja.desai@store.com',    '9800000004', '2024-03-20', 35000.00),
('Suresh',  'Pillai',   'Technician',       'suresh.pillai@store.com',  '9800000005', '2023-09-15', 40000.00),
('Divya',   'Menon',    'Inventory Clerk',  'divya.menon@store.com',    '9800000006', '2024-07-01', 30000.00),
('Manish',  'Tiwari',   'Sales Associate',  'manish.tiwari@store.com',  '9800000007', '2024-09-01', 33000.00),
('Priti',   'Saxena',   'Cashier',          'priti.saxena@store.com',   '9800000008', '2025-01-15', 27000.00);

-- ============================================================
-- ORDERS (18 orders with varied statuses & payment methods)
-- Note: total_amount is set to 0.00 and auto-updated by triggers
-- ============================================================
INSERT INTO ORDERS (customer_id, employee_id, order_date, total_amount, payment_method, order_status) VALUES
(1,  2, '2026-01-15 10:30:00', 0.00, 'UPI',          'Delivered'),
(2,  2, '2026-01-28 14:15:00', 0.00, 'Credit Card',  'Delivered'),
(3,  4, '2026-02-05 11:00:00', 0.00, 'Cash',         'Delivered'),
(4,  2, '2026-02-14 16:45:00', 0.00, 'Debit Card',   'Delivered'),
(5,  4, '2026-02-22 09:30:00', 0.00, 'UPI',          'Delivered'),
(6,  3, '2026-03-03 13:00:00', 0.00, 'Credit Card',  'Delivered'),
(7,  2, '2026-03-10 10:15:00', 0.00, 'Net Banking',  'Delivered'),
(1,  4, '2026-03-18 15:30:00', 0.00, 'UPI',          'Delivered'),
(8,  2, '2026-03-25 11:45:00', 0.00, 'Cash',         'Delivered'),
(3,  3, '2026-04-01 14:00:00', 0.00, 'Debit Card',   'Shipped'),
(13, 7, '2026-04-05 10:00:00', 0.00, 'UPI',          'Shipped'),
(14, 4, '2026-04-08 16:30:00', 0.00, 'Credit Card',  'Confirmed'),
(15, 2, '2026-04-12 09:15:00', 0.00, 'Net Banking',  'Confirmed'),
(16, 7, '2026-04-15 11:00:00', 0.00, 'UPI',          'Confirmed'),
(17, 3, '2026-04-18 14:30:00', 0.00, 'Cash',         'Pending'),
(18, 8, '2026-04-20 10:45:00', 0.00, 'Debit Card',   'Pending'),
(19, 2, '2026-04-22 13:00:00', 0.00, 'UPI',          'Pending'),
(20, 7, '2026-04-25 15:15:00', 0.00, 'Credit Card',  'Pending');

-- ============================================================
-- ORDER ITEMS (multiple items per order — 35+ line items)
-- Note: Triggers auto-decrement stock and update order totals
-- ============================================================
INSERT INTO ORDER_ITEMS (order_id, product_id, quantity, unit_price) VALUES
-- Order 1: Aarav — MacBook Air + AirPods Pro
(1, 1,  1, 114900.00),
(1, 19, 1, 24900.00),

-- Order 2: Priya — Samsung Galaxy S24 Ultra + Galaxy Tab S9 FE
(2, 8,  1, 129999.00),
(2, 33, 1, 44999.00),

-- Order 3: Rohan — HP Pavilion + Logitech Mouse + Keychron KB
(3, 3,  1, 54990.00),
(3, 24, 1, 9995.00),
(3, 25, 1, 7499.00),

-- Order 4: Ananya — iPhone 15 Pro
(4, 7,  1, 134900.00),

-- Order 5: Vikram — LG OLED TV + Bose QC Ultra + JBL Flip
(5, 14, 1, 154990.00),
(5, 21, 1, 32900.00),
(5, 20, 1, 9999.00),

-- Order 6: Sneha — Dell XPS 15 + Samsung SSD
(6, 2,  1, 139990.00),
(6, 28, 1, 8999.00),

-- Order 7: Arjun — boAt Headphones x2 + JBL Flip + Echo Dot
(7, 22, 2, 1799.00),
(7, 20, 1, 9999.00),
(7, 31, 1, 4499.00),

-- Order 8: Aarav (repeat) — OnePlus 12 + Nothing Phone 2
(8, 9,  1, 64999.00),
(8, 11, 1, 44999.00),

-- Order 9: Kavya — Samsung 55" TV + Xiaomi 43" TV
(9, 13, 1, 47990.00),
(9, 16, 1, 22999.00),

-- Order 10: Rohan (repeat) — Dell Monitor + Razer Mouse
(10, 26, 1, 52990.00),
(10, 27, 1, 14999.00),

-- Order 11: Kartik — PS5 Slim + DualSense Controller
(11, 35, 1, 49990.00),
(11, 38, 2, 5990.00),

-- Order 12: Diya — iPad Air M2 + Apple AirPods Pro
(12, 32, 1, 69900.00),
(12, 19, 1, 24900.00),

-- Order 13: Siddharth — Acer Nitro 5 + SteelSeries Headset
(13, 6,  1, 79990.00),
(13, 39, 1, 24990.00),

-- Order 14: Tanya — Dyson Air Purifier + Marshall Speaker
(14, 30, 1, 44900.00),
(14, 23, 1, 41999.00),

-- Order 15: Nikhil — Xiaomi 14 + Sony WH-1000XM5
(15, 12, 1, 69999.00),
(15, 18, 1, 29990.00),

-- Order 16: Riya — Nintendo Switch OLED + Lenovo Tab P12
(16, 36, 1, 30999.00),
(16, 34, 1, 32999.00),

-- Order 17: Harsh — Google Pixel 8 Pro
(17, 10, 1, 106999.00),

-- Order 18: Simran — TCL 55" QLED + iRobot Roomba + Echo Dot
(18, 17, 1, 42990.00),
(18, 32, 1, 39990.00),
(18, 31, 1, 4499.00);

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================
SELECT 'All sample data inserted successfully!' AS status;
SELECT CONCAT('Categories:   ', (SELECT COUNT(*) FROM CATEGORY))    AS count;
SELECT CONCAT('Products:     ', (SELECT COUNT(*) FROM PRODUCT))     AS count;
SELECT CONCAT('Inventory:    ', (SELECT COUNT(*) FROM INVENTORY))   AS count;
SELECT CONCAT('Customers:    ', (SELECT COUNT(*) FROM CUSTOMER))    AS count;
SELECT CONCAT('Employees:    ', (SELECT COUNT(*) FROM EMPLOYEE))    AS count;
SELECT CONCAT('Orders:       ', (SELECT COUNT(*) FROM ORDERS))      AS count;
SELECT CONCAT('Order Items:  ', (SELECT COUNT(*) FROM ORDER_ITEMS)) AS count;
