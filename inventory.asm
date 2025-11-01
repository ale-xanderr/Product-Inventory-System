section .data
    header db "==================================================", 10, \
            "            PRODUCT INVENTORY SYSTEM", 10, \
            "==================================================", 10, 0

    menu db "[1] Add Product", 10, \
        "[2] Delete Product by Name", 10, \
        "[3] Delete All Products with Zero Stock", 10, \
        "[4] Search Product by Name", 10, \
        "[5] Search Low-Stock Product", 10, \
        "[6] Display All Products", 10, \
        "[7] Display Products Sorted by Quantity", 10, \
        "[8] Exit", 10, \
        "==================================================",10, 0

    choice_msg db "Enter choice: ", 0
    invalid_msg db "Invalid choice. Please try again.", 10, 0
    exit_msg db "Exiting the System. Goodbye!", 10, 0

    format_int db "%d", 0
    format_str db "%s", 0

    ;add product

    add_product_msg db "Enter the product's name: ", 0
    add_quantity_msg db "How many stocks of the product: ", 0
    add_success_msg db "Product has been added successfully", 10, 0
    add_list_full_msg db "Product list is full (20)", 10, 0
    add_duplicate_msg db "Product already exists in the list!", 10, 0
    add_invalid_quantity_msg db "Quantity must be within 1-99!", 10, 0
 
section .bss
    choice resd 1

    product_limit equ 20          ; max 20 products in the product list
    product_length equ 21         ; max 20 chars + null terminator
    product_count resd 1          ; number of products stored

    temp_name resb product_length
    temp_quantity resd 1
    

section .text
    global _main
    extern _printf, _scanf

_main:
    ; print header
    push header
    call _printf
    add esp, 4

menu_loop:
    ; print menu
    push menu
    call _printf
    add esp, 4

    ; ask for user choice
    push choice_msg
    call _printf
    add esp, 4

    ; read choice
    push choice
    push format_int
    call _scanf
    add esp, 8

    mov eax, [choice]

    ; add product 
    cmp eax, 1
    je add_product_msg

    ; delete product by name
    cmp eax, 2
    je delete_by_name

    ;delete all products with zero stock
    cmp eax, 3
    je delete_zero_stock

    ; search product by name
    cmp eax, 4
    je search_by_name

    ; search low-stock product
    cmp eax, 5
    je search_low_stock

    ; display all products
    cmp eax, 6
    je display_all

    ; display products sorted by quantity
    cmp eax, 7
    je display_sorted

    ;exit program
    cmp eax, 8
    je exit_program

    ; invalid choice
    push invalid_msg
    call _printf
    add esp, 4

    jmp menu_loop

add_product:
    ; check first if the list is full
    mov eax, [product_count]
    cmp eax, product_limit
    jge add_list_full_msg

    ; ask for the product's name
    push add_product_msg
    call _printf
    add esp, 4

    push temp_name
    push format_str
    call _scanf
    add esp, 8

    ; ask for the product's quantity
    push add_quantity_msg
    call _printf
    add esp, 4

    push temp_quantity
    push format_int
    call _scanf
    add esp, 8

    ; store the products in array
    mov ebx, [product_count]
    mov edi, product_length
    imul edx, product_length




    jmp menu_loop

delete_by_name:
    jmp menu_loop

delete_zero_stock:
    jmp menu_loop

search_by_name:
    jmp menu_loop

search_low_stock:
    jmp menu_loop

display_all:
    jmp menu_loop

display_sorted:
    jmp menu_loop

exit_program:
    push exit_msg
    call _printf
    add esp, 4
    ret
