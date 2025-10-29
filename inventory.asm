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

section .bss
    choice resd 1

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
    je add_product

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