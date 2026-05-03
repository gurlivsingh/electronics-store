# Data Sources & Collection Methodology
## Electronics Store Management System — UCS310 DBMS Project
### Group 2Q21 | Thapar Institute of Engineering & Technology

---

## Overview

The synthetic dataset used in this project was constructed from publicly available
Indian e-commerce product listings, Census demographic data, and industry salary
reports. All records are **realistic but fabricated** for academic demonstration.

---

## 1. Product Data (40 Products, 8 Categories)

| Attribute | Source | Access Date |
|-----------|--------|-------------|
| Product Names & Specifications | Amazon.in product listings | April 2026 |
| Prices (MRP in ₹) | Flipkart.com, Croma.com comparative pricing | April 2026 |
| Brand Information | Official brand websites (apple.com/in, samsung.com/in, etc.) | April 2026 |
| Category Classification | Standard retail electronics taxonomy (Croma, Reliance Digital) | April 2026 |

**Method:** We searched the top-selling electronics on Amazon India and Flipkart
across eight major categories (Laptops, Smartphones, TVs, Audio, Accessories,
Home Appliances, Tablets, Gaming). For each product we recorded the exact product
name, brand, MRP, and key specifications as listed on the product page.

**References:**
- https://www.amazon.in/gp/bestsellers/electronics
- https://www.flipkart.com/top-rated/electronics
- https://www.croma.com/
- https://store.apple.com/in
- https://www.samsung.com/in/

---

## 2. Customer Data (20 Customers)

| Attribute | Source | Notes |
|-----------|--------|-------|
| First & Last Names | Indian Census 2021 — Common name distributions | Names selected from top-100 male/female first names and top-50 surnames |
| Cities | Census of India 2021 — Tier-1 and Tier-2 urban centres | 12 distinct cities across North, South, East, and West India |
| Addresses | Fabricated street addresses using real locality names | Cross-verified with Google Maps for plausibility |
| Email Addresses | Randomly generated using first.last@{gmail,outlook,yahoo}.com | Not real email accounts |
| Phone Numbers | Sequential 10-digit numbers in 9876543xxx range | Not real phone numbers |

**References:**
- Census of India 2021, Registrar General of India
  https://censusindia.gov.in/
- "Most Popular Indian Baby Names 2020–2025" — IndiaToday
  https://www.indiatoday.in/

---

## 3. Employee Data (8 Employees)

| Attribute | Source | Notes |
|-----------|--------|-------|
| Names | Same name-pool methodology as customer data | — |
| Roles | Standard electronics retail org chart | Manager, Sales Associate, Cashier, Technician, Inventory Clerk |
| Salaries (₹/month) | Glassdoor India — Retail Electronics salary data | Median values for each role in Tier-1 cities |
| Hire Dates | Evenly distributed across 2023-01 to 2025-01 | Simulates gradual team growth |

**References:**
- Glassdoor India salary reports for retail electronics roles
  https://www.glassdoor.co.in/Salaries/
- PayScale India — Retail Industry Compensation
  https://www.payscale.com/research/IN/Industry=Retail/Salary

---

## 4. Order & Transaction Data (18 Orders, 35+ Line Items)

| Attribute | Source / Method | Notes |
|-----------|-----------------|-------|
| Order Dates | Evenly spread across Jan 2026 – Apr 2026 | Simulates ~4-month business period |
| Order Status Distribution | 8 Delivered, 2 Shipped, 3 Confirmed, 5 Pending | Mimics real retail fulfilment funnel |
| Payment Methods | Cash, Credit Card, Debit Card, UPI, Net Banking | UPI dominant (~35%), matching RBI FY2025 digital payment trends |
| Items per Order | 1–3 items per order | Mean 1.9 items, matching Indian online retail averages |
| Quantities | Mostly 1, occasionally 2 | Realistic for high-value electronics |

**Method:** Order data was generated to produce meaningful aggregate metrics:
- Total revenue of approximately ₹25–30 lakhs across 18 orders
- Multiple repeat customers (Aarav, Rohan) to demonstrate the
  `sp_customer_order_history` cursor procedure
- Several low-stock situations to trigger the `trg_stock_alert` trigger
- All five payment methods and all five order statuses are represented

**References:**
- RBI Annual Report 2024-25 — Digital Payment Trends in India
  https://www.rbi.org.in/scripts/AnnualReportPublications.aspx
- RedSeer Consulting — India E-Commerce Market Report Q1 2026
  https://redseer.com/

---

## 5. Inventory & Stock Levels

| Attribute | Source / Method |
|-----------|-----------------|
| Initial Stock | Random values between 2 and 110 units | 
| Reorder Levels | Set at 3–30 units depending on product category |
| Last Restocked | Dates in April 2026, varying by product |

**Method:** Stock levels were deliberately set to create a mix of:
- **Healthy stock** (majority of products) — quantity well above reorder level
- **Low stock** (4–5 products) — below reorder level, triggering alerts
- **Near-critical** (1–2 products) — stock of 2–3, demonstrating urgency classification

This distribution ensures the `sp_check_low_stock` cursor procedure and the
`trg_stock_alert` trigger produce meaningful output during demonstration.

---

## Data Integrity Notes

1. All product prices are in Indian Rupees (₹) inclusive of GST, matching
   real MRP values as of April 2026.
2. Customer phone numbers and email addresses are synthetic and do not
   correspond to real individuals.
3. Employee salaries reflect industry-standard compensation for
   retail electronics roles in Indian metropolitan areas.
4. Order patterns are designed to exercise all PL/SQL components
   (procedures, functions, cursors, triggers) during demonstration.

---

*Document prepared for UCS310 — Database Management Systems, Thapar Institute of Engineering & Technology, May 2026.*
