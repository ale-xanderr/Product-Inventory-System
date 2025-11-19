section .data
    ; ================= MENUS & HEADERS =================
    ; These strings define how the UI looks. 
    ; The '10' is the ASCII code for a Newline character.
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

    ; ================= MESSAGES & PROMPTS =================
    choice_msg db "Enter choice: ", 0
    exit_msg db 10, "Exiting System... Goodbye!", 10, 0
    newline db 10, 0
    
    ; -- Error Messages --
    ; Specific messages help the user know exactly what they did wrong
    error_not_number db 10, "Error: Invalid input! Please enter a NUMBER.", 10, 0
    
    ; -- Range Errors --
    error_menu_range db 10, "Error: Choice must be between 1 and 6.", 10, 0
    error_sub_range  db 10, "Error: Choice must be between 1 and 3.", 10, 0
    error_qty_range  db 10, "Error: Quantity must be between 1 and 99.", 10, 0
    error_price_neg  db 10, "Error: Price cannot be negative.", 10, 0

    ; -- Input Prompts --
    prompt_name db "Enter product name (max 20 chars): ", 0
    prompt_qty db "Enter quantity (1-99): ", 0
    prompt_price db "Enter price (integer): ", 0

    ; -- Edit Specific Prompts --
    edit_prompt_old db "Enter the existing product name in the list: ", 0
    edit_prompt_new_name db "Enter new product name: ", 0
    edit_prompt_new_qty db "Enter new quantity: ", 0
    edit_prompt_new_price db "Enter new price: ", 0
    
    ; -- Status Messages --
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
    ; This creates the clean columns for the list display
    table_header db 10, "=============================================================", 10, \
                      "Product             |  Quantity  |   Price    |   Total      ", 10, \
                      "=============================================================", 10, 0
    
    ; The format string for printf: String(Name) | Int(Qty) | Int(Price) | Int(Total)
    table_row_fmt db "%-19s | %-10d | %-10d | %-10d", 10, 0

    table_footer_start db 10, "=============================================================", 10, \
                            "OVERALL TOTAL: ", 0
    table_footer_end   db 10, "=============================================================", 10, 0
    
    fmt_int db "%d", 0
    fmt_str db "%s", 0

section .bss
    ; ================= VARIABLES =================
    choice resd 1
    
    ; Constants
    product_limit equ 20     ; Maximum products allowed
    product_length equ 21    ; Max name length (20 chars + null terminator)

    ; -- PARALLEL ARRAYS --
    ; We don't have 'structs' in basic assembly, so we use separate arrays.
    ; Index 0 of 'product_names' corresponds to Index 0 of 'quantities', etc.
    product_count resd 1
    product_names resb product_limit * product_length
    quantities    resd product_limit
    prices        resd product_limit
    
    ; -- Temporary Storage --
    ; Used to hold input before we decide to save it to the main arrays
    temp_name resb product_length
    temp_qty  resd 1
    temp_price resd 1
    
    ; -- Logic Variables --
    current_index resd 1   ; Used to remember which item we are processing
    loop_counter resd 1    ; Used for loops (i)
    grand_total resd 1     ; Sum of all asset values
    item_total  resd 1     ; Qty * Price for a single row
    found_flag  resd 1     ; Boolean flag (0 or 1) for searches

section .text
    global _main
    extern _printf, _scanf, _getchar

_main:
    ; Initialize our counter to 0 when program starts
    mov dword [product_count], 0

; ==========================================================
; MAIN MENU LOGIC
; ==========================================================
main_menu:
    ; Print the beautiful header and options
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

    ; VALIDATION 1: Check if scanf returned 1 (meaning it successfully read an integer)
    cmp eax, 1
    jne .menu_type_err

    ; VALIDATION 2: Check if the integer is within the valid range (1-6)
    mov eax, [choice]
    cmp eax, 1
    jl .menu_range_err
    cmp eax, 6
    jg .menu_range_err

    ; Switch case logic to jump to the right function
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
    ; If they typed letters ("abc"), we must clear the buffer, or it loops infinitely
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .retry_menu 

.menu_range_err:
    ; If number is out of bounds (e.g., 9), just ask again. No need to flush.
    push error_menu_range
    call _printf
    add esp, 4
    jmp .retry_menu

; ==========================================================
; SUBMENUS
; ==========================================================
submenu_delete:
    ; Always show the current list first so the user knows what to delete
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
    
    ; Validation logic (Type & Range 1-3)
    cmp eax, 1
    jne .del_type_err
    mov eax, [choice]
    cmp eax, 1
    jl .del_range_err
    cmp eax, 3
    jg .del_range_err

    cmp eax, 1
    je do_delete_by_name
    cmp eax, 2
    je do_delete_zero
    cmp eax, 3
    je main_menu

.del_type_err:
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .retry_del

.del_range_err:
    push error_sub_range
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
    push error_not_number
    call _printf
    add esp, 4
    jmp .retry_search

.search_range_err:
    push error_sub_range
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
    push error_not_number
    call _printf
    add esp, 4
    jmp .retry_disp

.disp_range_err:
    push error_sub_range
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
    ; 1. Check if we reached the limit (20)
    mov eax, [product_count]
    cmp eax, product_limit
    jge .full

    ; *** CRITICAL STEP ***
    ; We just came from a menu selection (integer input). 
    ; The 'Enter' key is still in the buffer. We MUST clear it, 
    ; otherwise the next string input will automatically read nothing and skip.
    call flush_buffer

.add_ask_name:
    push prompt_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8
    
    ; Check if this name already exists
    call check_duplicate_func
    cmp eax, 1
    je .duplicate_error

.add_ask_qty:
    push prompt_qty
    call _printf
    add esp, 4

    push temp_qty
    push fmt_int
    call _scanf
    add esp, 8

    ; Validate Quantity (Number check & 1-99 check)
    cmp eax, 1
    jne .invalid_qty_type

    mov eax, [temp_qty]
    cmp eax, 1
    jl .invalid_qty_range
    cmp eax, 99
    jg .invalid_qty_range

.add_ask_price:
    push prompt_price
    call _printf
    add esp, 4

    push temp_price
    push fmt_int
    call _scanf
    add esp, 8
    
    ; Validate Price (Number check & Positive check)
    cmp eax, 1
    jne .invalid_price_type

    mov eax, [temp_price]
    cmp eax, 0
    jl .invalid_price_range

    ; === SAVE DATA TO ARRAYS ===
    mov ebx, [product_count]
    
    ; 1. Save Name (Calculate address: base + (index * 21))
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, temp_name
    call strcpy_manual

    ; 2. Save Quantity (Calculate address: base + (index * 4))
    lea edi, [quantities + ebx * 4]
    mov eax, [temp_qty]
    mov [edi], eax

    ; 3. Save Price (Calculate address: base + (index * 4))
    lea edi, [prices + ebx * 4]
    mov eax, [temp_price]
    mov [edi], eax

    ; Increment total product count
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

; -- Add Product Error Handlers --
.invalid_qty_type:
    call flush_buffer ; Clear bad input
    push error_not_number
    call _printf
    add esp, 4
    jmp .add_ask_qty

.invalid_qty_range:
    push error_qty_range
    call _printf
    add esp, 4
    jmp .add_ask_qty

.invalid_price_type:
    call flush_buffer ; Clear bad input
    push error_not_number
    call _printf
    add esp, 4
    jmp .add_ask_price

.invalid_price_range:
    push error_price_neg
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

    ; Clear buffer because we are about to ask for a String name
    call flush_buffer

    push prompt_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

    ; Search for the name
    call get_product_index
    cmp ebx, -1 ; -1 means not found
    je .not_found

    ; If found (ebx has the index), delete it
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
    ; Loop through the entire array
    cmp ebx, [product_count]
    jge .done_zero
    
    ; Check quantity at current index
    mov eax, [quantities + ebx * 4]
    cmp eax, 0
    je .found_zero
    
    inc ebx
    jmp .loop_check

.found_zero:
    push ebx ; Save ebx because delete_at_index might mess with registers
    call delete_at_index
    pop ebx
    ; IMPORTANT: Do NOT increment ebx here. 
    ; When we delete, items shift left. The new item at this index 
    ; hasn't been checked yet. So we loop again at the SAME index.
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

    ; Clear buffer for string input
    call flush_buffer

    push prompt_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

    call get_product_index
    cmp ebx, -1
    je .s_not_found

    ; Print the table header, then the single row found
    push table_header
    call _printf
    add esp, 4
    mov [current_index], ebx
    call print_single_product
    push table_footer_end
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

    push table_header
    call _printf
    add esp, 4
    mov ecx, [product_count]
    mov ebx, 0
    mov dword [found_flag], 0 

.low_loop:
    cmp ebx, ecx
    jge .low_done
    
    ; Check if quantity < 5
    mov eax, [quantities + ebx*4]
    cmp eax, 5
    jge .skip_low
    
    ; Print this item
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
    push table_footer_end
    call _printf
    add esp, 4
    
    ; If flag is still 0, we didn't find anything
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
; [4.2] DISPLAY SORTED (BUBBLE SORT)
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
    jl .sort_done ; Don't sort if 0 or 1 item
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
    
    ; Compare Qty[j] and Qty[j+1]
    mov eax, [quantities + edx*4]
    mov edi, [quantities + edx*4 + 4]
    cmp eax, edi
    jle .no_swap

    ; --- SWAP LOGIC (If out of order) ---
    ; 1. Swap Quantities
    mov [quantities + edx*4], edi
    mov [quantities + edx*4 + 4], eax
    
    ; 2. Swap Prices
    mov eax, [prices + edx*4]
    mov edi, [prices + edx*4 + 4]
    mov [prices + edx*4], edi
    mov [prices + edx*4 + 4], eax
    
    ; 3. Swap Names (Complex because they are strings)
    push ecx
    push ebx
    push esi
    
    ; Copy name 1 to temp
    mov eax, edx
    imul eax, product_length
    add eax, product_names
    push eax
    mov edi, temp_name
    mov esi, eax
    call strcpy_manual
    pop eax
    
    ; Copy name 2 to name 1
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
    
    ; Copy temp to name 2
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

    ; Display the list so user knows what to type
    call display_logic_all

    ; Clear buffer for string input
    call flush_buffer

.edit_step1:
    push edit_prompt_old
    call _printf
    add esp, 4
    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

    ; Find the item to edit
    call get_product_index
    cmp ebx, -1
    je .edit_not_found
    mov [current_index], ebx

.edit_step2:
    push edit_prompt_new_name
    call _printf
    add esp, 4
    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

.edit_step3:
    push edit_prompt_new_qty
    call _printf
    add esp, 4
    push temp_qty
    push fmt_int
    call _scanf
    add esp, 8
    
    ; Validate new Qty
    cmp eax, 1
    jne .edit_bad_qty_type
    mov eax, [temp_qty]
    cmp eax, 1
    jl .edit_range_qty
    cmp eax, 99
    jg .edit_range_qty

.edit_step4:
    push edit_prompt_new_price
    call _printf
    add esp, 4
    push temp_price
    push fmt_int
    call _scanf
    add esp, 8

    ; Validate new Price
    cmp eax, 1
    jne .edit_bad_price_type
    mov eax, [temp_price]
    cmp eax, 0
    jl .edit_range_price

    ; --- SAVE UPDATES ---
    mov ebx, [current_index]
    
    ; Update Name
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, temp_name
    call strcpy_manual

    ; Update Qty
    lea edi, [quantities + ebx * 4]
    mov eax, [temp_qty]
    mov [edi], eax

    ; Update Price
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

.edit_bad_qty_type:
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .edit_step3

.edit_range_qty:
    push error_qty_range
    call _printf
    add esp, 4
    jmp .edit_step3

.edit_bad_price_type:
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .edit_step4

.edit_range_price:
    push error_price_neg
    call _printf
    add esp, 4
    jmp .edit_step4

; ==========================================================
; HELPERS
; ==========================================================

; *** FLUSH BUFFER ***
; This function keeps reading characters from the input 
; until it hits a Newline (Enter key). 
; It prevents "ghost" inputs from messing up the next scan.
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

; *** DISPLAY LOGIC ***
; Loops through all products and calculates the Grand Total
display_logic_all:
    mov ecx, [product_count]
    cmp ecx, 0
    je .disp_empty
    push table_header
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
    ; Print Footer with Grand Total
    push table_footer_start
    call _printf
    add esp, 4
    push dword [grand_total]
    push fmt_int
    call _printf
    add esp, 8
    push table_footer_end
    call _printf
    add esp, 4
    ret
.disp_empty:
    push msg_empty
    call _printf
    add esp, 4
    ret

; *** PRINT SINGLE PRODUCT ***
; Prints one row and adds (Qty * Price) to the Grand Total
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
    
    ; Calculate Total Value for this item
    imul eax, edx 
    mov [item_total], eax
    add [grand_total], eax ; Add to global sum
    pop eax 
    
    ; Print the formatted row
    push dword [item_total]
    push edx                
    push eax                
    push esi                
    push table_row_fmt
    call _printf
    add esp, 20
    ret

; *** DELETE AT INDEX ***
; Removes an item by shifting all subsequent items LEFT by one position
delete_at_index:
    mov esi, ebx
    inc esi     ; Source = index + 1
    mov edi, ebx ; Dest = index
.shift_loop:
    cmp esi, [product_count]
    jge .shift_done
    
    ; Shift Name
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
    
    ; Shift Qty
    mov eax, [quantities + esi * 4]
    mov [quantities + edi * 4], eax
    
    ; Shift Price
    mov eax, [prices + esi * 4]
    mov [prices + edi * 4], eax
    
    inc edi
    inc esi
    jmp .shift_loop
.shift_done:
    dec dword [product_count]
    ret

; *** GET PRODUCT INDEX ***
; Helper to find the index of 'temp_name' in the list.
; Returns: Index in EBX, or -1 if not found.
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

; *** CHECK DUPLICATE ***
; Returns 1 if found, 0 if not.
check_duplicate_func:
    call get_product_index
    cmp ebx, -1
    jne .cd_found
    mov eax, 0
    ret
.cd_found:
    mov eax, 1
    ret

; *** STRING COPY ***
; Copy string from ESI to EDI byte by byte
strcpy_manual:
.copy_char:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne .copy_char
    ret

; *** STRING COMPARE ***
; Compare string at ESI with EDI. Returns 1 if equal, 0 if not.
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
