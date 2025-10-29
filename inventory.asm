section .data
    header db "================================", 10, \
            "   PRODUCT INVENTORY SYSTEM", 10, \
            "================================", 10, 0

    menu db "[1] Add Product", 10, \
        "[2] Delete Product by Name", 10, \
        "[3] Delete All Products with Zero Stock", 10, \
        "[4] Search Product by Name", 10, \
        "[5] Search Low-Stock Product", 10, \
        "[6] Display All Products", 10, \
        "[7] Display Products Sorted by Quantity", 10, \
        "[8] Exit", 10, \
        "================================",10, 0

    choice db "Enter choice: ", 0

    invalid db "Invalid choice. Please try again.", 10, 0

    exit db "Exiting the System. Goodbye!", 10, 0
    
section .bss
section .text