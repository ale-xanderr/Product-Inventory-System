section .data
    ; ================= MENUS & HEADERS =================
    header db 10, "==================================================", 10, \
            "            PRODUCT INVENTORY SYSTEM", 10, \
            "==================================================", 10, 0

    main_menu db 10, "--- MAIN MENU ---", 10, \
        "[1] Add Product", 10, \
        "[2] Delete Menu", 10, \
        "[3] Search Menu", 10, \
        "[4] Display Menu", 10, \
        "[5] Edit Product", 10, \
        "[6] Exit", 10, \
        "==================================================", 10, 0

    delete_menu db 10, "--- DELETE MENU ---", 10, \
        "[1] Delete by Name", 10, \
        "[2] Delete All Zero Stock", 10, \
        "[3] Return to Main Menu", 10, 0

    search_menu db 10, "--- SEARCH MENU ---", 10, \
        "[1] Search by Name", 10, \
        "[2] Search Low Stock (< 5)", 10, \
        "[3] Return to Main Menu", 10, 0

    display_menu db 10, "--- DISPLAY MENU ---", 10, \
        "[1] Display All (Unsorted)", 10, \
        "[2] Display Sorted by Quantity (Ascending)", 10, \
        "[3] Return to Main Menu", 10, 0

    ; The "safety net" menu before editing. We don't want users getting trapped
    ; in edit mode if they clicked [5] by mistake.
    edit_product_menu db 10, "--- EDIT MENU ---", 10, \
        "[1] Select Product to Edit", 10, \
        "[2] Return to Main Menu", 10, 0

    ; This menu gives granular control over what field to change.
    ; Option [4] lets them switch products without leaving the Edit flow entirely.
    edit_options_menu db 10, "--- EDIT PRODUCT MENU ---", 10, \
        "[1] Edit Name", 10, \
        "[2] Edit Quantity", 10, \
        "[3] Edit Price", 10, \
        "[4] Back (Select Another Product)", 10, \
        "[5] Return to Main Menu", 10, 0

    ; ================= MESSAGES & PROMPTS =================
    choice_msg db "Enter choice: ", 0
    exit_msg db 10, "Exiting System... Goodbye!", 10, 0
    newline db 10, 0
    
    ; -- Error Handling Messages --
    ; We differentiate between "That's not a number" and "That number is wrong"
    ; to help the user correct their mistake faster.
    error_not_number db 10, "Error: Invalid input! Please enter a NUMBER.", 10, 0
    error_name_invalid db 10, "Error: Name cannot contain numbers or spaces.", 10, 0
    
    ; Specific range error messages for each menu context
    error_menu_range db 10, "Error: Choice must be between 1 and 6.", 10, 0
    error_sub_range  db 10, "Error: Choice must be between 1 and 3.", 10, 0
    error_edit_start_range db 10, "Error: Choice must be between 1 and 2.", 10, 0 
    error_edit_range db 10, "Error: Choice must be between 1 and 5.", 10, 0       
    error_qty_range  db 10, "Error: Quantity must be between 0 and 99.", 10, 0
    error_price_neg  db 10, "Error: Price cannot be negative.", 10, 0

    ; -- User Prompts --
    prompt_name db "Enter product name (max 20 chars): ", 0
    prompt_qty db "Enter quantity (1-99): ", 0
    prompt_price db "Enter price (integer): ", 0

    ; -- Edit Specific Prompts --
    edit_prompt_old db "Enter the existing product name to edit: ", 0
    edit_prompt_new_name db "Enter NEW product name: ", 0
    edit_prompt_new_qty db "Enter NEW quantity: ", 0
    edit_prompt_new_price db "Enter NEW price: ", 0
    
    ; -- System Feedback Messages --
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
    ; We use a fixed-width table layout for professional output.
    ; The format string uses '%-19s' to left-align text and '%-10d' for numbers.
    table_header db 10, "=============================================================", 10, \
                      "Product             |  Quantity  |   Price    |   Total      ", 10, \
                      "=============================================================", 10, 0
    
    table_row_fmt db "%-19s | %-10d | %-10d | %-10d", 10, 0

    table_footer_start db 10, "=============================================================", 10, \
                            "OVERALL TOTAL: ", 0
    table_footer_end   db 10, "=============================================================", 10, 0
    
    fmt_int db "%d", 0
    fmt_str db "%s", 0

section .bss
    ; ================= VARIABLES =================
    choice resd 1
    
    ; System Constraints
    product_limit equ 20     ; Hard limit on array size
    product_length equ 21    ; 20 chars for name + 1 null terminator

    ; -- PARALLEL ARRAYS --
    ; Since Assembly doesn't support complex Objects/Structs natively,
    ; we use three separate arrays. Index 0 in 'names' corresponds to
    ; index 0 in 'quantities' and 'prices'.
    product_count resd 1
    product_names resb product_limit * product_length
    quantities    resd product_limit
    prices        resd product_limit
    
    ; -- Temporary Input Buffers --
    ; We store user input here first to validate it before
    ; committing it to the main arrays.
    temp_name resb product_length
    temp_qty  resd 1
    temp_price resd 1
    
    ; -- Logic Control Variables --
    current_index resd 1   ; Tracks which product we are currently manipulating
    loop_counter resd 1    ; Standard loop iterator (i)
    grand_total resd 1     ; Accumulator for the total inventory value
    item_total  resd 1     ; Calculated on the fly: Quantity * Price
    found_flag  resd 1     ; Simple boolean (0/1) to track search success

section .text
    global _main
    extern _printf, _scanf, _getchar

_main:
    ; Initialize the product counter to zero on startup.
    ; This effectively clears our "list" without wiping memory.
    mov dword [product_count], 0

; ==========================================================
; MAIN MENU LOOP
; ==========================================================
; This is the central hub of the program. After almost any operation,
; the user lands back here.
main_menu_loop:
    push newline
    call _printf
    add esp, 4

    push header
    call _printf
    add esp, 4

    push main_menu
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

    ; -- ROBUST INPUT VALIDATION --
    ; Step 1: Did scanf actually find an integer? (EAX == 1)
    cmp eax, 1
    jne .menu_type_err

    ; Step 2: Did the user press Enter immediately after the number?
    ; If they typed "1a", scanf takes "1", but "a" is left over. We catch that here.
    call _getchar
    cmp eax, 10 
    jne .menu_type_err

    ; Step 3: Is the number within our allowed range (1-6)?
    mov eax, [choice]
    cmp eax, 1
    jl .menu_range_err
    cmp eax, 6
    jg .menu_range_err

    ; Routing the valid choice to the correct subroutine
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
    ; If invalid characters are found, we MUST flush the input buffer.
    ; Otherwise, the next scanf will read the same garbage, causing an infinite loop.
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .retry_menu 

.menu_range_err:
    ; Range errors don't leave garbage in the buffer, so no flush needed.
    push error_menu_range
    call _printf
    add esp, 4
    jmp .retry_menu

; ==========================================================
; SUBMENU: DELETE
; ==========================================================
submenu_delete:
    ; User Experience Improvement: Always show the list before asking what to delete.
    call display_logic_all 
    push delete_menu
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
    
    ; Standard validation pattern: Check type, check trailing chars, check range.
    cmp eax, 1
    jne .del_type_err
    call _getchar
    cmp eax, 10
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
    je main_menu_loop

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


; ==========================================================
; SUBMENU: SEARCH
; ==========================================================
submenu_search:
    push search_menu
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
    call _getchar
    cmp eax, 10
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
    je main_menu_loop

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


; ==========================================================
; SUBMENU: DISPLAY
; ==========================================================
submenu_display:
    push display_menu
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
    call _getchar
    cmp eax, 10
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
    je main_menu_loop

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
    jmp submenu_display ; Return to Display Menu so user can toggle sort modes easily.

; ==========================================================
; [1] ADD PRODUCT
; ==========================================================
do_add_product:
    ; Safety Check: Prevent array overflow
    mov eax, [product_count]
    cmp eax, product_limit
    jge .full

.add_ask_name:
    push prompt_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8
    
    ; String Input Hygiene:
    ; 1. Check if there are left-over characters (e.g. user typed "Apple Pie").
    call _getchar
    cmp eax, 10
    jne .name_has_garbage

    ; 2. Ensure the name contains only valid characters (no numbers allowed).
    call check_name_alpha
    cmp eax, 0
    je .name_has_digits

    ; 3. Ensure unique product names.
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

    ; Validating integers strictly (reject "12abc")
    cmp eax, 1
    jne .invalid_qty_type
    call _getchar 
    cmp eax, 10 
    jne .invalid_qty_type

    ; Logical check: Quantity 1-99
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
    
    cmp eax, 1
    jne .invalid_price_type
    call _getchar
    cmp eax, 10
    jne .invalid_price_type

    mov eax, [temp_price]
    cmp eax, 0
    jl .invalid_price_range

    ; --- SAVING DATA ---
    ; Calculate memory offsets based on product_count (index)
    mov ebx, [product_count]
    
    ; Store Name: Base Address + (Index * 21 bytes)
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, temp_name
    call strcpy_manual

    ; Store Integers: Base Address + (Index * 4 bytes)
    lea edi, [quantities + ebx * 4]
    mov eax, [temp_qty]
    mov [edi], eax

    lea edi, [prices + ebx * 4]
    mov eax, [temp_price]
    mov [edi], eax

    inc dword [product_count]

    push msg_added
    call _printf
    add esp, 4
    jmp main_menu_loop

.full:
    push msg_full
    call _printf
    add esp, 4
    jmp main_menu_loop

.duplicate_error:
    push msg_duplicate
    call _printf
    add esp, 4
    jmp .add_ask_name 

.name_has_garbage:
    call flush_buffer ; Clean up the mess (" Pie")
    push error_name_invalid
    call _printf
    add esp, 4
    jmp .add_ask_name

.name_has_digits:
    push error_name_invalid
    call _printf
    add esp, 4
    jmp .add_ask_name

.invalid_qty_type:
    call flush_buffer
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
    call flush_buffer
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

    push prompt_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8

    call flush_buffer 

    ; Search logic
    call get_product_index
    cmp ebx, -1
    je .not_found

    ; Actual deletion logic (shifting array elements)
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
    ; We iterate through the list. If we find a zero, we delete it.
    ; Importantly, we do NOT increment the index if we delete, because
    ; the next item slides into the current slot.
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

    push prompt_name
    call _printf
    add esp, 4

    push temp_name
    push fmt_str
    call _scanf
    add esp, 8
    
    call flush_buffer

    call get_product_index
    cmp ebx, -1
    je .s_not_found

    ; If found, we reuse the table print logic for just this one item
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
    mov eax, [quantities + ebx*4]
    cmp eax, 5
    jge .skip_low
    
    ; Found a match (< 5), print it
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

    ; Basic Bubble Sort Implementation
    ; Loops nested: i (outer), j (inner)
    mov ecx, [product_count]
    cmp ecx, 2
    jl .sort_done ; Optimization: No need to sort if count < 2
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
    
    ; Comparison: Swap if Qty[j] > Qty[j+1]
    mov eax, [quantities + edx*4]
    mov edi, [quantities + edx*4 + 4]
    cmp eax, edi
    jle .no_swap

    ; --- SWAP OPERATION ---
    ; Swap integers (Quantity & Price) directly in memory
    mov [quantities + edx*4], edi
    mov [quantities + edx*4 + 4], eax
    mov eax, [prices + edx*4]
    mov edi, [prices + edx*4 + 4]
    mov [prices + edx*4], edi
    mov [prices + edx*4 + 4], eax
    
    ; Swap Strings (Name) requires a manual loop copy via registers
    push ecx
    push ebx
    push esi
    mov eax, edx
    imul eax, product_length
    add eax, product_names
    push eax
    mov edi, temp_name
    mov esi, eax
    call strcpy_manual ; Name 1 -> Temp
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
    call strcpy_manual ; Name 2 -> Name 1
    mov esi, temp_name
    mov eax, edx
    inc eax
    imul eax, product_length
    add eax, product_names
    mov edi, eax
    call strcpy_manual ; Temp -> Name 2
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
    jmp submenu_display

.empty_sort:
    push msg_empty
    call _printf
    add esp, 4
    jmp submenu_display

; ==========================================================
; [5] EDIT PRODUCT
; ==========================================================
do_edit_product:
    mov eax, [product_count]
    cmp eax, 0
    je .edit_empty

    ; Label for returning if user selects "Back" inside Edit
.edit_start:
    call display_logic_all

.edit_start_menu_loop:
    ; Early Exit Menu: "Do you really want to edit or go back?"
    push edit_product_menu
    call _printf
    add esp, 4

    push choice_msg
    call _printf
    add esp, 4

    push choice
    push fmt_int
    call _scanf
    add esp, 8

    cmp eax, 1
    jne .edit_start_type_err
    call _getchar
    cmp eax, 10
    jne .edit_start_type_err

    mov eax, [choice]
    cmp eax, 1
    je .edit_step1      ; Proceed to Selection
    cmp eax, 2
    je main_menu_loop   ; Cancel

    push error_edit_start_range
    call _printf
    add esp, 4
    jmp .edit_start_menu_loop

.edit_start_type_err:
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .edit_start_menu_loop

.edit_step1:
    push edit_prompt_old
    call _printf
    add esp, 4
    push temp_name
    push fmt_str
    call _scanf
    add esp, 8
    
    call flush_buffer

    call get_product_index
    cmp ebx, -1
    je .edit_not_found
    mov [current_index], ebx

; *** EDIT OPTIONS SUB-MENU ***
.edit_menu_loop:
    push edit_options_menu
    call _printf
    add esp, 4

    push choice_msg
    call _printf
    add esp, 4

    push choice
    push fmt_int
    call _scanf
    add esp, 8

    cmp eax, 1
    jne .edit_menu_error
    call _getchar
    cmp eax, 10
    jne .edit_menu_error

    mov eax, [choice]
    cmp eax, 1
    jl .edit_range_error
    cmp eax, 5
    jg .edit_range_error

    cmp eax, 1
    je .do_edit_name
    cmp eax, 2
    je .do_edit_qty
    cmp eax, 3
    je .do_edit_price
    cmp eax, 4
    je .edit_start    ; Restart the Edit process (Select new product)
    cmp eax, 5
    je main_menu_loop ; Full exit

.edit_menu_error:
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .edit_menu_loop

.edit_range_error:
    push error_edit_range
    call _printf
    add esp, 4
    jmp .edit_menu_loop

.do_edit_name:
    push edit_prompt_new_name
    call _printf
    add esp, 4
    push temp_name
    push fmt_str
    call _scanf
    add esp, 8
    
    call _getchar
    cmp eax, 10
    jne .edit_name_junk

    call check_name_alpha
    cmp eax, 0
    je .edit_name_digits

    call check_duplicate_func
    cmp eax, 1
    je .edit_duplicate_error

    ; Update array in memory
    mov ebx, [current_index]
    mov edi, product_names
    mov eax, ebx
    imul eax, product_length
    add edi, eax
    mov esi, temp_name
    call strcpy_manual

    push msg_updated
    call _printf
    add esp, 4
    jmp .edit_menu_loop

.edit_name_junk:
    call flush_buffer
    push error_name_invalid
    call _printf
    add esp, 4
    jmp .do_edit_name

.edit_name_digits:
    push error_name_invalid
    call _printf
    add esp, 4
    jmp .do_edit_name

.edit_duplicate_error:
    push msg_duplicate
    call _printf
    add esp, 4
    jmp .do_edit_name

.do_edit_qty:
    push edit_prompt_new_qty
    call _printf
    add esp, 4
    push temp_qty
    push fmt_int
    call _scanf
    add esp, 8
    
    cmp eax, 1
    jne .edit_qty_error
    call _getchar
    cmp eax, 10
    jne .edit_qty_error

    ; Allow 0 in Edit mode (to support "Delete Zero Stock" testing)
    mov eax, [temp_qty]
    cmp eax, 0
    jl .edit_qty_range
    cmp eax, 99
    jg .edit_qty_range

    mov ebx, [current_index]
    lea edi, [quantities + ebx * 4]
    mov eax, [temp_qty]
    mov [edi], eax

    push msg_updated
    call _printf
    add esp, 4
    jmp .edit_menu_loop

.edit_qty_error:
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .do_edit_qty

.edit_qty_range:
    push error_qty_range
    call _printf
    add esp, 4
    jmp .do_edit_qty

.do_edit_price:
    push edit_prompt_new_price
    call _printf
    add esp, 4
    push temp_price
    push fmt_int
    call _scanf
    add esp, 8

    cmp eax, 1
    jne .edit_price_error
    call _getchar
    cmp eax, 10
    jne .edit_price_error

    mov eax, [temp_price]
    cmp eax, 0
    jl .edit_price_range

    mov ebx, [current_index]
    lea edi, [prices + ebx * 4]
    mov eax, [temp_price]
    mov [edi], eax

    push msg_updated
    call _printf
    add esp, 4
    jmp .edit_menu_loop

.edit_price_error:
    call flush_buffer
    push error_not_number
    call _printf
    add esp, 4
    jmp .do_edit_price

.edit_price_range:
    push error_price_neg
    call _printf
    add esp, 4
    jmp .do_edit_price

.edit_not_found:
    push msg_not_found
    call _printf
    add esp, 4
    jmp .edit_step1 

.edit_empty:
    push msg_empty
    call _printf
    add esp, 4
    jmp main_menu_loop

; ==========================================================
; HELPERS
; ==========================================================

; Clears the input buffer to prevent "infinite loop" errors on bad input.
flush_buffer:
    push ebx
.flush_loop:
    call _getchar
    cmp eax, 10 ; Loop until we hit Newline
    je .flush_done
    cmp eax, -1 ; Or EOF
    je .flush_done
    jmp .flush_loop
.flush_done:
    pop ebx
    ret

; Validates that a string contains no numbers.
check_name_alpha:
    push esi
    mov esi, temp_name
.check_loop:
    mov al, [esi]
    cmp al, 0
    je .check_ok
    cmp al, '0'
    jl .next_char
    cmp al, '9'
    jle .check_fail ; Fail if digit 0-9 found
.next_char:
    inc esi
    jmp .check_loop
.check_fail:
    pop esi
    mov eax, 0
    ret
.check_ok:
    pop esi
    mov eax, 1
    ret

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
    imul eax, edx ; Calculate Asset Value (Qty * Price)
    mov [item_total], eax
    add [grand_total], eax
    pop eax 
    push dword [item_total]
    push edx                
    push eax                
    push esi                
    push table_row_fmt
    call _printf
    add esp, 20
    ret

; Removes an item by shifting all subsequent items LEFT by one index
delete_at_index:
    mov esi, ebx
    inc esi     
    mov edi, ebx 

.shift_loop:
    cmp esi, [product_count]
    jge .shift_done
    
    ; CRITICAL: Save registers before calculating addresses
    push edi
    push esi
    
    mov eax, edi
    imul eax, product_length
    add eax, product_names
    mov edi, eax        
    
    mov eax, esi        
    imul eax, product_length
    add eax, product_names
    mov esi, eax        
    
    call strcpy_manual
    
    pop esi
    pop edi
    
    ; Shift Integers
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
    
    call stricmp_manual ; Case-insensitive check
    
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

; Standard Case-Insensitive String Comparison
stricmp_manual:
    push esi
    push edi
.cmp_loop:
    mov al, [esi]
    mov bl, [edi]
    
    ; Convert to Lowercase logic
    cmp al, 'A'
    jl .check_bl
    cmp al, 'Z'
    jg .check_bl
    add al, 32
.check_bl:
    cmp bl, 'A'
    jl .compare_now
    cmp bl, 'Z'
    jg .compare_now
    add bl, 32
    
.compare_now:
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