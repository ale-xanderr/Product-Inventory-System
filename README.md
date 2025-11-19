🧾 Product Inventory System (Assembly Language Project)
📚 Computer Organization & Architecture — Final Project
👥 Group Members: - Member 1 — [Aquino, Sean Xander]

Member 2 — [David, Kenji Nathaniel]

Member 3 — [Lanuzo, Jessica Mae]

Member 4 — [Tercero, Michelle]

🧠 Project Overview
The Product Inventory System is an Assembly language program designed to manage a list of products using a text-based interface.

Each product record tracks the Name, Quantity, and Price. The system calculates the total asset value per item and the grand total of the inventory.

This program demonstrates:

Parallel Array Data Structures (Managing Names, Quantities, and Prices).

Modular Programming with Submenus.

Bubble Sort Algorithm for organizing data.

Robust Input Validation (Type checking, Range checking, and Buffer flushing).

Formatted Output (Table views).

⚙️ Features
➕ 1. Add Product
Add a new product by entering:

Name (Max 20 characters)

Quantity (1-99)

Price (Integer)

Includes duplicate name detection.

Validates that inputs are numbers where required.

❌ 2. Delete Menu
Delete by Name: Removes a specific product and shifts the remaining array elements to fill the gap.

Delete Zero Stock: Iterates through the list and automatically deletes all products where Quantity = 0.

🔍 3. Search Menu
Search by Name: Finds a specific product and displays its details in a table row.

Search Low-Stock: Displays all products with a Quantity less than 5.

📋 4. Display Menu
Display All (Unsorted): Shows a formatted table of all products.

Display Sorted: Sorts the inventory by Quantity (Ascending) using Bubble Sort before displaying.

Features:

Calculates Total = Quantity * Price for each row.

Calculates and displays the Grand Total Asset Value of the inventory.

✏️ 5. Edit Product
Allows the user to modify an existing product.

Validates that the product exists before editing.

Updates Name, Quantity, and Price.

🧩 Program Design
The project employs modular programming, dividing tasks into specific labels and helper functions:

Module Label	Description
main_menu	Handles the primary loop and navigation (Options 1-6).
do_add_product	Captures input, validates it, and stores it in parallel arrays.
do_edit_product	Locates an index by name and overwrites data at that index.
submenu_delete	Handles navigation for "Delete by Name" and "Delete Zero Stock".
submenu_search	Handles navigation for "Search by Name" and "Search Low Stock".
submenu_display	Handles navigation for "Unsorted" and "Sorted" views.
display_logic_all	The core loop that renders the formatted table and calculates totals.
flush_buffer	Critical Helper: Clears the input buffer to prevent skipped inputs during string/int transitions.

🧭 Menu Navigation Map
The program uses a Nested Menu Structure:

Plaintext

[ Main Menu ]
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
💻 How to Run (Windows)
Prerequisites:

NASM (Netwide Assembler)

GCC (MinGW or similar C Compiler for linking)

Commands:

Bash

# 1. Assemble the source code
nasm -f win32 inventory.asm

# 2. Link using GCC (links with C library for printf/scanf)
gcc -o inventory inventory.obj

# 3. Run the executable
inventory.exe
🚀 How to Contribute
To keep the repository stable and organized, please follow this workflow:

Fork the Repository: Click Fork at the top-right of this repo.

Clone Your Fork:

Bash

git clone https://github.com/<your-username>/Product-Inventory-System.git
Create a New Branch:

Bash

git checkout -b feature-name
Make Your Changes: Implement code or fix bugs.

Bash

git add .
git commit -m "Added price validation logic"
Push to Your Fork:

Bash

git push origin feature-name
Open a Pull Request: Submit your PR to the main repository for review.

🔑 Notes
Input Validation: The system is designed to handle mixed inputs (e.g., typing characters when a number is expected) by flushing the buffer and prompting the user again.

Data Limits: The program is currently set to handle a maximum of 20 products (defined by product_limit equ 20).
