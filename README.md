# 🧾 Product Inventory System (Assembly Language Project)

### 📚 Computer Organization & Architecture — Final Project  

**👥 Group Members:**  
- Member 1 — [Aquino, Sean Xander]  
- Member 2 — [David, Kenji Nathaniel]  
- Member 3 — [Lanuzo, Jessica Mae]  
- Member 4 — [Tercero, Michelle]  

---

## 🧠 Project Overview

The **Product Inventory System** is an Assembly language program designed to manage a simple list of products.  
Each product record contains a **Product Name** and **Quantity**, allowing users to **Add**, **Delete**, **Search**, and **Display** entries using a text-based menu.

This program demonstrates:
- Modular programming design  
- String and integer operations  
- Loops and conditional jumps  
- Input validation and error handling  

---

## ⚙️ Features

### ➕ Add Product
- Add a new product by entering its **name** and **quantity**.  
- Prevents duplicate product names.  
- Requires at least **10 entries** for testing and validation.  

### ❌ Delete Product
- **Delete by Product Name:** Remove a specific product from the inventory.  
- **Delete All Zero Stock Products:** Automatically remove all products with `quantity = 0`.  

### 🔍 Search Product
- **By Name:** Find a product and view its quantity.  
- **Low-Stock Products:** Display all products below a user-defined stock threshold.  

### 📋 Display Products
- **All Products:** Show all stored products with their quantities.  
- **Sorted by Quantity:** Display products arranged from highest to lowest stock.  

---

## 🧩 Program Design

The project employs **modular programming**, with separate procedures for each major operation:

| Module | Description |
|:--|:--|
| `main_menu` | Displays the main menu and handles user selection |
| `add_product` | Adds a new product and validates input |
| `delete_by_name` | Deletes a product using its name |
| `delete_zero_stock` | Removes products with zero stock |
| `search_by_name` | Finds a product by name |
| `search_low_stock` | Finds products below a threshold |
| `display_all` | Displays all stored products |
| `display_sorted` | Displays products sorted by quantity |
| `input_validation` | Ensures valid input for quantity and names |  
---
