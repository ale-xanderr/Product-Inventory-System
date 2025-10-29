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

    ; read choice
    push choice
    push format_int
    call _scanf
    add esp, 8

    mov eax, [choice]

    ; invalid choice
    push invalid
    call _printf
    add esp, 4

    jmp menu_loop


