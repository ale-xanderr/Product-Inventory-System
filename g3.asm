section .data
    ; ================= MENUS & HEADERS =================
    header db 10, "==================================================", 10, \
            "            PRODUCT INVENTORY SYSTEM", 10, \
            "==================================================", 10, 0

    menu_main db 10, "--- MAIN MENU ---", 10, \
        "[1] Add Product", 10, \
        "[2] Delete Menu", 10, \
        "[3] Search Menu", 10, \
        "[4] Display Menu", 10, \
        "[5] Edit Product", 10, \
        "[6] Exit", 10, \
        "==================================================", 10, 0

    menu_delete db 10, "--- DELETE MENU ---", 10, \
        "[1] Delete by Name", 10, \
        "[2] Delete All Zero Stock", 10, \
        "[3] Back to Main Menu", 10, 0

    menu_search db 10, "--- SEARCH MENU ---", 10, \
        "[1] Search by Name", 10, \
        "[2] Search Low Stock (< 5)", 10, \
        "[3] Back to Main Menu", 10, 0

    menu_display db 10, "--- DISPLAY MENU ---", 10, \
        "[1] Display All (Unsorted)", 10, \
        "[2] Display Sorted by Quantity (Ascending)", 10, \
        "[3] Back to Main Menu", 10, 0

    ; ================= SPECIALIZED ERROR MESSAGES =================
    ; General
    choice_msg db "Enter choice: ", 0
    exit_msg db 10, "Exiting System... Goodbye!", 10, 0
    newline db 10, 0
    
    ; Type Errors (User entered string instead of int)
    err_not_number db 10, "Error: Invalid input! Please enter a number.", 10, 0
    
    ; Range Errors (User entered int, but wrong value)
    err_menu_range db 10, "Error: Choice must be between 1 and 6.", 10, 0
    err_sub_range  db 10, "Error: Choice must be between 1 and 3.", 10, 0
    err_qty_range  db 10, "Error: Quantity must be between 1 and 99.", 10, 0
    err_price_neg  db 10, "Error: Price cannot be negative.", 10, 0

    ; Input Prompts
    ask_name db "Enter product name (max 20 chars): ", 0
    ask_qty db "Enter quantity (1-99): ", 0
    ask_price db "Enter price (integer): ", 0

    ; Edit Specific Prompts
    edit_ask_old db "Enter the existing product name in the list: ", 0
    edit_ask_new_name db "Enter new product name: ", 0
    edit_ask_new_qty db "Enter new quantity: ", 0
    edit_ask_new_price db "Enter new price: ", 0
    
    ; Status Messages
    msg_added db 10, "Product added successfully!", 10, 0
    msg_full db 10, "Error: Inventory full!", 10, 0
    msg_duplicate db 10, "Error: Product already exists!", 10, 0
    msg_deleted db 10, "Product deleted successfully.", 10, 0
    msg_not_found db 10, "Error: Product not found.", 10, 0
    msg_updated db 10, "Product updated successfully!", 10, 0
    msg_empty db 10, "List is empty.", 10, 0
    msg_sorting db 10, "Sorting products...", 10, 0
    msg_zero_deleted db 10, "All zero-stock products deleted.", 10, 0
    msg_no_low_stock db 10, "No low-stock products found.", 10, 0

    ; ================= TABLE FORMATTING =================
    tbl_header db 10, "=============================================================", 10, \
                      "Product             |  Quantity  |   Price    |   Total      ", 10, \
                      "=============================================================", 10, 0
    
    tbl_row_fmt db "%-19s | %-10d | %-10d | %-10d", 10, 0

    tbl_footer_start db 10, "=============================================================", 10, \
                            "OVERALL TOTAL: ", 0
    tbl_footer_end   db 10, "=============================================================", 10, 0
    
    fmt_int db "%d", 0
    fmt_str db "%s", 0

section .bss
    ; ================= VARIABLES =================
    choice resd 1
    
    ; Constants
    product_limit equ 20
    product_length equ 21

    ; Data Storage
    product_count resd 1
    product_names resb product_limit * product_length
    quantities    resd product_limit
    prices        resd product_limit
    
    ; Temp variables
    temp_name resb product_length
    temp_qty  resd 1
    temp_price resd 1
    
    ; Logic vars
    current_index resd 1
    loop_counter resd 1
    grand_total resd 1
    item_total  resd 1
    found_flag  resd 1

section .text
    global _main
    extern _printf, _scanf, _getchar

_main:
    mov dword [product_count], 0

; ==========================================================
; MAIN MENU LOGIC
; ==========================================================
main_menu:
    push newline
    call _printf
    add esp, 4

    push header
    call _printf
    add esp, 4

    push menu_main
    call _printf
    add esp, 4

.retry_menu:
    push choice_msg
    call _printf
    add esp, 4
    
    push choice
    push fmt_int
    call _scanf
    add esp, 8

    ; 1. CHECK TYPE (Did they type a number?)
    cmp eax, 1
    jne .menu_type_err

    ; 2. CHECK RANGE (Is it 1-6?)
    mov eax, [choice]
    cmp eax, 1
    jl .menu_range_err
    cmp eax, 6
    jg .menu_range_err

    ; Valid choice processing
    cmp eax, 1
    je do_add_product
    cmp eax, 2
    je submenu_delete
    cmp eax, 3
    je submenu_search
    cmp eax, 4
    je submenu_display
    cmp eax, 5
    je do_edit_product
    cmp eax, 6
    je exit_program

.menu_type_err:
    call flush_buffer
    push err_not_number
    call _printf
    add esp, 4
    jmp .retry_menu 

.menu_range_err:
    push err_menu_range
    call _printf
    add esp, 4
    jmp .retry_menu

; ==========================================================
; SUBMENUS
; ==========================================================
submenu_delete:
    call display_logic_all 
    push menu_delete
    call _printf
    add esp, 4

.retry_del:
    push choice_msg
    call _printf
    add esp, 4
    push choice
    push fmt_int
    call _scanf
    add esp, 8
    
    ; Check Type
    cmp eax, 1
    jne .del_type_err

    ; Check Range
    mov eax, [choice]
    cmp eax, 1
    jl .del_range_err
    cmp eax, 3
    jg .del_range_err

    ; Process
    cmp eax, 1
    je do_delete_by_name
    cmp eax, 2
    je do_delete_zero
    cmp eax, 3
    je main_menu

.del_type_err:
    call flush_buffer
    push err_not_number
    call _printf
    add esp, 4
    jmp .retry_del

.del_range_err:
    push err_sub_range
    call _printf
    add esp, 4
    jmp .retry_del


submenu_search:
    push menu_search
    call _printf
    add esp, 4

.retry_search:
    push choice_msg
    call _printf
    add esp, 4
    push choice
    push fmt_int
    call _scanf
    add esp, 8

    cmp eax, 1
    jne .search_type_err

    mov eax, [choice]
    cmp eax, 1
    jl .search_range_err
    cmp eax, 3
    jg .search_range_err

    cmp eax, 1
    je do_search_name
    cmp eax, 2
    je do_search_low
    cmp eax, 3
    je main_menu

.search_type_err:
    call flush_buffer
    push err_not_number
    call _printf
    add esp, 4
    jmp .retry_search

.search_range_err:
    push err_sub_range
    call _printf
    add esp, 4
    jmp .retry_search


submenu_display:
    push menu_display
    call _printf
    add esp, 4

.retry_disp:
    push choice_msg
    call _printf
    add esp, 4
    push choice
    push fmt_int
    call _scanf
    add esp, 8

    cmp eax, 1
    jne .disp_type_err

    mov eax, [choice]
    cmp eax, 1
    jl .disp_range_err
    cmp eax, 3
    jg .disp_range_err

    cmp eax, 1
    je do_display_all_wrapper
    cmp eax, 2
    je do_display_sorted
    cmp eax, 3
    je main_menu

.disp_type_err:
    call flush_buffer
    push err_not_number
    call _printf
    add esp, 4
    jmp .retry_disp

.disp_range_err:
    push err_sub_range
    call _printf
    add esp, 4
    jmp .retry_disp

do_display_all_wrapper:
    call display_logic_all
    jmp main_menu

; ==========================================================
; [1] ADD PRODUCT
; ==========================================================
do_add_product:
    mov eax, [product_count]
    cmp eax, product_limit
    jge .full

    ; 1. Ask Name
.add_ask_name:
    push ask_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8
    
    call check_duplicate_func
    cmp eax, 1
    je .duplicate_error

    ; 2. Ask Quantity
.add_ask_qty:
    push ask_qty
    call _printf
    add esp, 4

    push temp_qty
    push fmt_int
    call _scanf
    add esp, 8

    ; Validate Type
    cmp eax, 1
    jne .invalid_qty_type

    ; Validate Range
    mov eax, [temp_qty]
    cmp eax, 1
    jl .invalid_qty_range
    cmp eax, 99
    jg .invalid_qty_range

    ; 3. Ask Price
.add_ask_price:
    push ask_price
    call _printf
    add esp, 4

    push temp_price
    push fmt_int
    call _scanf
    add esp, 8
    
    ; Validate Type
    cmp eax, 1
    jne .invalid_price_type

    ; Validate Positive
    mov eax, [temp_price]
    cmp eax, 0
    jl .invalid_price_range

    ; 4. Store Data
    mov ebx, [product_count]
    
    ; Copy Name
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, temp_name
    call strcpy_manual

    ; Store Quantity
    lea edi, [quantities + ebx * 4]
    mov eax, [temp_qty]
    mov [edi], eax

    ; Store Price
    lea edi, [prices + ebx * 4]
    mov eax, [temp_price]
    mov [edi], eax

    inc dword [product_count]

    push msg_added
    call _printf
    add esp, 4
    jmp main_menu

.full:
    push msg_full
    call _printf
    add esp, 4
    jmp main_menu

.duplicate_error:
    push msg_duplicate
    call _printf
    add esp, 4
    jmp .add_ask_name 

; --- SPECIALIZED ERROR HANDLERS FOR ADD ---
.invalid_qty_type:
    call flush_buffer
    push err_not_number  ; "Input must be a NUMBER"
    call _printf
    add esp, 4
    jmp .add_ask_qty

.invalid_qty_range:
    push err_qty_range   ; "Quantity must be 1-99"
    call _printf
    add esp, 4
    jmp .add_ask_qty

.invalid_price_type:
    call flush_buffer
    push err_not_number  ; "Input must be a NUMBER"
    call _printf
    add esp, 4
    jmp .add_ask_price

.invalid_price_range:
    push err_price_neg   ; "Price cannot be negative"
    call _printf
    add esp, 4
    jmp .add_ask_price

; ==========================================================
; [2.1] DELETE BY NAME
; ==========================================================
do_delete_by_name:
    mov eax, [product_count]
    cmp eax, 0
    je .list_is_empty

    push ask_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

    call get_product_index
    cmp ebx, -1
    je .not_found

    call delete_at_index
    push msg_deleted
    call _printf
    add esp, 4
    jmp submenu_delete

.not_found:
    push msg_not_found
    call _printf
    add esp, 4
    jmp submenu_delete

.list_is_empty:
    push msg_empty
    call _printf
    add esp, 4
    jmp submenu_delete

; ==========================================================
; [2.2] DELETE ZERO STOCK
; ==========================================================
do_delete_zero:
    mov ecx, [product_count]
    cmp ecx, 0
    je .list_is_empty
    mov ebx, 0

.loop_check:
    cmp ebx, [product_count]
    jge .done_zero
    mov eax, [quantities + ebx * 4]
    cmp eax, 0
    je .found_zero
    inc ebx
    jmp .loop_check

.found_zero:
    push ebx
    call delete_at_index
    pop ebx
    jmp .loop_check

.done_zero:
    push msg_zero_deleted
    call _printf
    add esp, 4
    jmp submenu_delete

.list_is_empty:
    push msg_empty
    call _printf
    add esp, 4
    jmp submenu_delete

; ==========================================================
; [3.1] SEARCH BY NAME
; ==========================================================
do_search_name:
    mov eax, [product_count]
    cmp eax, 0
    je .list_empty

    push ask_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

    call get_product_index
    cmp ebx, -1
    je .s_not_found

    push tbl_header
    call _printf
    add esp, 4
    mov [current_index], ebx
    call print_single_product
    push tbl_footer_end
    call _printf
    add esp, 4
    jmp submenu_search

.s_not_found:
    push msg_not_found
    call _printf
    add esp, 4
    jmp submenu_search

.list_empty:
    push msg_empty
    call _printf
    add esp, 4
    jmp submenu_search

; ==========================================================
; [3.2] SEARCH LOW STOCK
; ==========================================================
do_search_low:
    mov eax, [product_count]
    cmp eax, 0
    je .list_empty

    push tbl_header
    call _printf
    add esp, 4
    mov ecx, [product_count]
    mov ebx, 0
    mov dword [found_flag], 0 

.low_loop:
    cmp ebx, ecx
    jge .low_done
    mov eax, [quantities + ebx*4]
    cmp eax, 5
    jge .skip_low
    mov [current_index], ebx
    push ecx
    push ebx
    call print_single_product
    pop ebx
    pop ecx
    mov dword [found_flag], 1 
.skip_low:
    inc ebx
    jmp .low_loop

.low_done:
    push tbl_footer_end
    call _printf
    add esp, 4
    mov eax, [found_flag]
    cmp eax, 0
    je .no_low_found
    jmp submenu_search

.no_low_found:
    push msg_no_low_stock
    call _printf
    add esp, 4
    jmp submenu_search

.list_empty:
    push msg_empty
    call _printf
    add esp, 4
    jmp submenu_search

; ==========================================================
; [4.2] DISPLAY SORTED
; ==========================================================
do_display_sorted:
    mov eax, [product_count]
    cmp eax, 0
    je .empty_sort

    push msg_sorting
    call _printf
    add esp, 4

    mov ecx, [product_count]
    cmp ecx, 2
    jl .sort_done
    dec ecx
    mov ebx, 0 
.outer_loop:
    cmp ebx, ecx
    jge .sort_done
    mov edx, 0
    mov esi, ecx
    sub esi, ebx 
.inner_loop:
    cmp edx, esi
    jge .next_outer
    mov eax, [quantities + edx*4]
    mov edi, [quantities + edx*4 + 4]
    cmp eax, edi
    jle .no_swap

    ; SWAP
    mov [quantities + edx*4], edi
    mov [quantities + edx*4 + 4], eax
    mov eax, [prices + edx*4]
    mov edi, [prices + edx*4 + 4]
    mov [prices + edx*4], edi
    mov [prices + edx*4 + 4], eax
    
    push ecx
    push ebx
    push esi
    mov eax, edx
    imul eax, product_length
    add eax, product_names
    push eax
    mov edi, temp_name
    mov esi, eax
    call strcpy_manual
    pop eax
    mov eax, edx
    inc eax
    imul eax, product_length
    add eax, product_names
    mov esi, eax
    mov eax, edx
    imul eax, product_length
    add eax, product_names
    mov edi, eax
    call strcpy_manual
    mov esi, temp_name
    mov eax, edx
    inc eax
    imul eax, product_length
    add eax, product_names
    mov edi, eax
    call strcpy_manual
    pop esi
    pop ebx
    pop ecx

.no_swap:
    inc edx
    jmp .inner_loop
.next_outer:
    inc ebx
    jmp .outer_loop
.sort_done:
    call display_logic_all
    jmp main_menu

.empty_sort:
    push msg_empty
    call _printf
    add esp, 4
    jmp main_menu

; ==========================================================
; [5] EDIT PRODUCT
; ==========================================================
do_edit_product:
    mov eax, [product_count]
    cmp eax, 0
    je .edit_empty

    call display_logic_all

.edit_step1:
    push edit_ask_old
    call _printf
    add esp, 4
    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

    call get_product_index
    cmp ebx, -1
    je .edit_not_found
    mov [current_index], ebx

.edit_step2:
    push edit_ask_new_name
    call _printf
    add esp, 4
    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

.edit_step3:
    push edit_ask_new_qty
    call _printf
    add esp, 4
    push temp_qty
    push fmt_int
    call _scanf
    add esp, 8
    
    ; Validation QTY
    cmp eax, 1
    jne .edit_bad_qty_type
    mov eax, [temp_qty]
    cmp eax, 1
    jl .edit_range_qty
    cmp eax, 99
    jg .edit_range_qty

.edit_step4:
    push edit_ask_new_price
    call _printf
    add esp, 4
    push temp_price
    push fmt_int
    call _scanf
    add esp, 8

    ; Validation Price
    cmp eax, 1
    jne .edit_bad_price_type
    mov eax, [temp_price]
    cmp eax, 0
    jl .edit_range_price

    ; Save Updates
    mov ebx, [current_index]
    
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, temp_name
    call strcpy_manual

    lea edi, [quantities + ebx * 4]
    mov eax, [temp_qty]
    mov [edi], eax

    lea edi, [prices + ebx * 4]
    mov eax, [temp_price]
    mov [edi], eax

    push msg_updated
    call _printf
    add esp, 4
    jmp main_menu

.edit_not_found:
    push msg_not_found
    call _printf
    add esp, 4
    jmp .edit_step1 

.edit_empty:
    push msg_empty
    call _printf
    add esp, 4
    jmp main_menu

; --- EDIT SPECIALIZED ERROR HANDLERS ---
.edit_bad_qty_type:
    call flush_buffer
    push err_not_number
    call _printf
    add esp, 4
    jmp .edit_step3

.edit_range_qty:
    push err_qty_range
    call _printf
    add esp, 4
    jmp .edit_step3

.edit_bad_price_type:
    call flush_buffer
    push err_not_number
    call _printf
    add esp, 4
    jmp .edit_step4

.edit_range_price:
    push err_price_neg
    call _printf
    add esp, 4
    jmp .edit_step4

; ==========================================================
; HELPERS
; ==========================================================

; *** FLUSH BUFFER: Clears invalid input from stdin ***
flush_buffer:
    push ebx
.flush_loop:
    call _getchar
    cmp eax, 10 ; Check for newline
    je .flush_done
    cmp eax, -1 ; Check for EOF
    je .flush_done
    jmp .flush_loop
.flush_done:
    pop ebx
    ret

display_logic_all:
    mov ecx, [product_count]
    cmp ecx, 0
    je .disp_empty
    push tbl_header
    call _printf
    add esp, 4
    mov dword [grand_total], 0
    mov ebx, 0
    mov [loop_counter], ebx
.d_loop:
    mov ebx, [loop_counter]
    cmp ebx, [product_count]
    jge .d_done
    mov [current_index], ebx
    call print_single_product
    inc dword [loop_counter]
    jmp .d_loop
.d_done:
    push tbl_footer_start
    call _printf
    add esp, 4
    push dword [grand_total]
    push fmt_int
    call _printf
    add esp, 8
    push tbl_footer_end
    call _printf
    add esp, 4
    ret
.disp_empty:
    push msg_empty
    call _printf
    add esp, 4
    ret

print_single_product:
    mov ebx, [current_index]
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, edi 
    mov eax, [quantities + ebx*4]
    mov edx, [prices + ebx*4]
    push eax 
    imul eax, edx 
    mov [item_total], eax
    add [grand_total], eax
    pop eax 
    push dword [item_total]
    push edx                
    push eax                
    push esi                
    push tbl_row_fmt
    call _printf
    add esp, 20
    ret

delete_at_index:
    mov esi, ebx
    inc esi     
    mov edi, ebx 
.shift_loop:
    cmp esi, [product_count]
    jge .shift_done
    push edi
    push esi
    mov eax, edi
    imul eax, product_length
    add eax, product_names
    push eax 
    mov eax, esi
    imul eax, product_length
    add eax, product_names
    push eax 
    call strcpy_manual
    add esp, 8 
    pop esi
    pop edi
    mov eax, [quantities + esi * 4]
    mov [quantities + edi * 4], eax
    mov eax, [prices + esi * 4]
    mov [prices + edi * 4], eax
    inc edi
    inc esi
    jmp .shift_loop
.shift_done:
    dec dword [product_count]
    ret

get_product_index:
    mov ecx, [product_count]
    cmp ecx, 0
    je .pi_not_found
    mov ebx, 0
.pi_loop:
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, edi      
    mov edi, temp_name 
    push ecx
    push ebx
    call strcmp_manual 
    pop ebx
    pop ecx
    cmp eax, 1 
    je .pi_found
    inc ebx
    cmp ebx, [product_count]
    jl .pi_loop
.pi_not_found:
    mov ebx, -1
    ret
.pi_found:
    ret 

check_duplicate_func:
    call get_product_index
    cmp ebx, -1
    jne .cd_found
    mov eax, 0
    ret
.cd_found:
    mov eax, 1
    ret

strcpy_manual:
.copy_char:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne .copy_char
    ret

strcmp_manual:
    push esi
    push edi
.cmp_loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .cmp_diff
    cmp al, 0
    je .cmp_same
    inc esi
    inc edi
    jmp .cmp_loop
.cmp_diff:
    pop edi
    pop esi
    mov eax, 0
    ret
.cmp_same:
    pop edi
    pop esi
    mov eax, 1
    ret

exit_program:
    push exit_msg
    call _printf
    add esp, 4
    ret