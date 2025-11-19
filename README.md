# 🧾 Product Inventory System (Assembly Language Project)

### 📚 Computer Organization & Architecture — Final Project

**👥 Group Members:**
- Member 1 — [Aquino, Sean Xander]
- Member 2 — [David, Kenji Nathaniel]
- Member 3 — [Lanuzo, Jessica Mae]
- Member 4 — [Tercero, Michelle]

---

## 🧠 Project Overview

The **Product Inventory System** is an Assembly language (NASM) program designed to manage a retail inventory using a text-based interface.

Unlike simple list managers, this system utilizes **Parallel Arrays** to track the **Name**, **Quantity**, and **Price** of each product. It performs real-time arithmetic to calculate the **Total Asset Value** per item (`Quantity * Price`) and sums up the **Grand Total** value of the entire inventory.

**Key Technical Concepts:**
- **Parallel Arrays:** Managing separate memory blocks for strings and integers that correspond by index.
- **Bubble Sort Algorithm:** sorting data in ascending order.
- **Robust Input Validation:** Handling "Type Errors" (strings vs integers) and "Range Errors".
- **Buffer Synchronization:** Using custom buffer flushing to ensure clean input streams.

---

## ⚙️ Features

### ➕ 1. Add Product
- Allows the user to input:
  - **Product Name** (Max 20 characters).
  - **Quantity** (Validated range: 1-99).
  - **Price** (Validated: Must be a positive integer).
- **Duplicate Check:** Prevents adding a product if the name already exists in the list.

### ❌ 2. Delete Menu
- **Delete by Name:** Removes a specific product. The system shifts all subsequent array elements to the left to close the gap.
- **Delete All Zero Stock:** automatically iterates through the entire list and removes every product where the `Quantity` is 0.

### 🔍 3. Search Menu
- **Search by Name:** Locates a specific product and displays its Name, Quantity, Price, and Total Value.
- **Search Low-Stock:** Scans the inventory and displays all products with a **Quantity less than 5**.

### 📋 4. Display Menu
- **Display All (Unsorted):** Renders a clean, formatted table of the current inventory.
- **Display Sorted:** Sorts the inventory by **Quantity (Ascending)** using the **Bubble Sort** algorithm before displaying.
- **Financial Calculation:**
  - Computes line-item totals.
  - Displays the **OVERALL TOTAL** (Grand Total) of the inventory at the footer.

### ✏️ 5. Edit Product
- Allows users to modify an existing record.
- The user enters the name of the product to find.
- If found, the user can overwrite the **Name**, **Quantity**, and **Price**.

---

## 🧩 Program Design

The project uses a **Modular Architecture**, utilizing labels as subroutines to handle specific logic.

| Module Label | Functionality |
|:--|:--|
| `main_menu` | Controls the primary program loop and navigation. |
| `do_add_product` | Handles input capture, validation, and parallel array storage. |
| `do_edit_product` | Searches for an index and updates the arrays at that specific location. |
| `do_display_sorted` | Implements **Bubble Sort** to reorder arrays before printing. |
| `display_logic_all` | Renders the table and computes the Grand Total loop. |
| `flush_buffer` | **Critical Helper:** Consumes leftover newline characters from the input stream to prevent "skipped" inputs during error handling. |

---

### 🧭 Menu Navigation Map

The program is structured with a Main Menu and several Sub-menus:

```text
[ MAIN MENU ]
    │
    ├── [1] Add Product
    │
    ├── [2] Delete Menu
    │       ├── [1] Delete by Name
    │       ├── [2] Delete All Zero Stock
    │       └── [3] Back to Main Menu
    │
    ├── [3] Search Menu
    │       ├── [1] Search by Name
    │       ├── [2] Search Low Stock (< 5)
    │       └── [3] Back to Main Menu
    │
    ├── [4] Display Menu
    │       ├── [1] Display All (Unsorted)
    │       ├── [2] Display Sorted by Quantity (Ascending)
    │       └── [3] Back to Main Menu
    │
    ├── [5] Edit Product
    │
    └── [6] Exit
