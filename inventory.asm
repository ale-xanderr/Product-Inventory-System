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
        "==================================================", 10, 0

    choice_msg db "Enter choice: ", 0
    invalid_msg db "Invalid choice. Please try again.", 10, 0
    exit_msg db "Exiting the System. Goodbye!", 10, 0

    format_int db "%d", 0
    format_str db "%s", 0

    newline db 10, 0

    ;add product

    add_product_msg db "Enter the product's name (20): ", 0
    add_quantity_msg db "How many stocks of the product (1-99): ", 0
    add_success_msg db "Product has been added successfully", 10, 0
    add_list_full_msg db "Product list is full (20)", 10, 0
    add_duplicate_msg db "Product already exists in the list!", 10, 0
    add_invalid_quantity_msg db "Quantity must be 1-99!", 10, 0

    ; display product
    display_header db "===== CURRENT INVENTORY =====", 10, 0
    display_products db "%s" --> "%d", 10, 0
    display empty db "Inventory is empty.", 10, 0
 
section .bss
    choice resd 1

    product_limit equ 20          ; max 20 products in the product list
    product_length equ 21         ; max 20 chars + null terminator
    product_count resd 1          ; number of products stored

    product_names resb product_limit * product_length           ; array for strings
    quantities resd product_limit                               ; array for quantities
    
    temp_name resb product_length                   
    temp_quantity resd 1
    

section .text
    global _main
    extern _printf, _scanf

_main:
    mov dword [product_count], 0        ; initialize the count

    ; ; print header
    ; push header
    ; call _printf
    ; add esp, 4

menu_loop:
    ; print header
    push header
    call _printf
    add esp, 4

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

; add product
add_product:
    ; check first if the list is full
    mov eax, [product_count]
    cmp eax, product_limit
    jge add_full_list

    ; ask for the product's name
    push add_product_msg
    call _printf
    add esp, 4

    push temp_name
    push format_str
    call _scanf
    add esp, 8

    ; check if the product is a duplicate
    call check_duplicate
    test eax, eax
    jnz .duplicate

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
    
    lea edi, [product_names + ebx * product_length]
    mov esi, temp_name
    call string_copy

    lea edi, [quantities + ebx *4]
    mov eax, [temp_quantity]
    mov [edi], eax

    inc dword [product_count]

    push add_success_msg
    call _printf
    add esp, 4
    
    jmp menu_loop


add_duplicate:
    push add_duplicate_msg
    call _printf
    add esp, 4
    jmp menu_loop

add_full_list:
    push add_list_full_msg
    call _printf
    add esp, 4
    jmp menu_loop

add_invalid_quantity:
    push add_invalid_quantity_msg
    call _printf
    add esp, 4
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
    push display_header
    call _printf
    add esp, 4

    mov ecx, [product_count]
    test ecx, ecx
    jz display_empty
    
    mov ebx, 0

display_loop:
    lea esi, [product_names + ebx * product_length]
    lea edi, [quantities + ebx *4]
    mov eax, [edi]

    push eax
    push esi
    push display_products
    call _printf
    add esp, 12

    inc ebx
    cmp ebx, ecx
    jl display_loop

    jmp menu_loop

display_sorted:
    jmp menu_loop

exit_program:
    push exit_msg
    call _printf
    add esp, 4
    ret
