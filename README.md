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

### 🧭 Menu Navigation

```
Main Menu
   ↓
User chooses option
   ├── 1 → add_product
   ├── 2 → delete_menu
       ├── 1 → delete_by_name
       ├── 2 → delete_zero_stock
       └── 0 → back_to_main_menu
   ├── 3 → search_menu
       ├── 1 → search_by_name
       ├── 2 → search_low_stock
       └── 0 → back_to_main_menu
   ├── 4 → display_menu
       ├── 1 → display_all
       ├── 2 → display_sorted
       └── 0 → back_to_main_menu
   └── 0 → exit_program
```
## 💻 How to Run (Windows)

```bash
nasm -f win32 inventory.asm
gcc -o inventory inventory.obj
inventory.exe
```
---

## 🚀 How to Contribute

To keep the repository stable and organized, please follow this workflow:

### 1. Fork the Repository
Click **Fork** at the top-right of this repo to create your copy under your GitHub account.

### 2. Clone Your Fork
```bash
git clone https://github.com/<your-username>/Product-Inventory-System.git
```
Replace `<your-username>` with your GitHub username.

### 3. Create a New Branch
```bash
git checkout -b feature-name
```

### 4. Make Your Changes
Implement your code, documentation, or bug fixes.
```bash
git add .
git commit -m "Add search by product name feature"
```

### 5. Push to Your Fork
```bash
git push origin feature-name
```

### 6. Open a Pull Request (PR)
1. Go to your fork on GitHub  
2. Click **New Pull Request**  
3. Set the base repo to the main project (e.g., `username/Product-Inventory-System`)  
4. Add a clear description of your changes

---

## 🔑 Notes
- **Do not push directly to main**
- Keep your fork updated:
```bash
git remote add upstream https://github.com/ale-xanderr/Product-Inventory-System.git
git checkout main
git pull upstream main
git push origin main
```

---
