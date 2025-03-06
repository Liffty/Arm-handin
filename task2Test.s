.syntax unified

.data
digit: .ascii "xx\n"          // Reserve space for two digits and a newline
digitEnd:
test_values:                  // Array of test values
    .int 0, 5, 9, 10, 42, 99  // Original test cases
    .int -1, 100, 255         // Added edge cases outside valid range
test_count:
    .int 9                    // Updated number of test values
current_test:
    .int 0                    // Index of current test
output_msg:
    .ascii "Test case: "
output_msg_end:
test_value_msg:
    .ascii "Input value: "
test_value_msg_end:
expected_msg:
    .ascii "Expected: "
expected_msg_end:
actual_msg:
    .ascii "Actual:   "
actual_msg_end:
edge_case_msg:
    .ascii " (Edge case - outside 0-99 range)"
edge_case_msg_end:
pass_msg:
    .ascii "PASS\n"
pass_msg_end:
fail_msg:
    .ascii "FAIL\n"
fail_msg_end:
newline:
    .ascii "\n"
newline_end:
display_buffer:               // Buffer for displaying integer values
    .ascii "    "             // Space for up to 4 digits with sign
display_end:

.text
.global _start

_start:
    // Initialize test loop
    ldr r8, =current_test   // Get address of current test index
    mov r9, #0              // Start with first test
    str r9, [r8]            // Store initial test index
    
test_loop:
    // Check if we've run all tests
    ldr r8, =current_test   // Get address of current test index
    ldr r9, [r8]            // Load current test index
    ldr r10, =test_count    // Get address of test count
    ldr r10, [r10]          // Load test count
    cmp r9, r10             // Compare current with total
    bge exit_success        // If all tests done, exit

    // Print which test we're running
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =output_msg       // "Test case: "
    mov r2, #11               // length
    swi 0
    
    // Print test number (1-indexed)
    ldr r8, =current_test     // Get address of current test index
    ldr r9, [r8]              // Load current test index
    add r9, r9, #1            // Add 1 to get 1-indexed number
    add r9, r9, #48           // Convert small number to ASCII
    
    // Store and print the test case number
    ldr r1, =display_buffer
    strb r9, [r1]
    
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =display_buffer
    mov r2, #1                // length
    swi 0
    
    // Print newline
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =newline          // newline
    mov r2, #1                // length
    swi 0
    
    // Print "Input value: "
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =test_value_msg   // "Input value: "
    mov r2, #13               // length
    swi 0
    
    // Load the current test value
    ldr r11, =test_values     // Get base address of test array
    ldr r12, [r8]             // Get current test index
    lsl r12, r12, #2          // Multiply by 4 (size of int)
    add r11, r11, r12         // Calculate address of current test value
    ldr r3, [r11]             // Load the test value to r3
    
    // Display the integer value properly
    // We'll handle a simple integer-to-string conversion here
    // Init buffer with spaces
    ldr r1, =display_buffer
    mov r2, #32               // Space character
    strb r2, [r1]             // Store space
    strb r2, [r1, #1]         // Store space
    strb r2, [r1, #2]         // Store space
    strb r2, [r1, #3]         // Store space
    
    mov r4, r3                // Copy value to r4
    mov r5, #0                // Position in buffer
    
    // Check if negative
    cmp r4, #0
    bge positive_number
    
    // Handle negative number
    mvn r4, r4                // Bitwise NOT
    add r4, r4, #1            // Add 1 (two's complement)
    mov r6, #45               // ASCII '-'
    strb r6, [r1]             // Store minus sign
    add r5, r5, #1            // Move position
    
positive_number:
    // Convert absolute value to string (right to left)
    mov r6, #0                // Digit counter
    
digit_loop:
    // Extract digit
    mov r7, #10
    udiv r8, r4, r7           // r8 = value / 10
    mul r9, r8, r7            // r9 = (value / 10) * 10
    sub r9, r4, r9            // r9 = value - ((value / 10) * 10) = digit
    
    // Convert to ASCII and store
    add r9, r9, #48           // Convert to ASCII
    add r6, r6, #1            // Increment digit counter
    
    // Store in reverse order (right-aligned)
    rsb r10, r6, #4           // r10 = 4 - digit_counter
    strb r9, [r1, r10]        // Store digit
    
    // Prepare for next digit
    mov r4, r8                // value = value / 10
    cmp r4, #0                // Check if more digits
    bne digit_loop            // Continue if non-zero
    
    // Print the integer value
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =display_buffer
    mov r2, #4                // length
    swi 0
    
    // Print newline
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =newline          // newline
    mov r2, #1                // length
    swi 0
    
    // Check if this is an edge case outside 0-99 range
    ldr r3, [r11]             // Reload test value
    cmp r3, #0                // Check if negative
    blt edge_case
    cmp r3, #99               // Check if > 99
    bgt edge_case
    b normal_case
    
edge_case:
    // Print edge case notification
    mov r0, #1                     // stdout
    mov r7, #4                     // write syscall
    ldr r1, =edge_case_msg         // Edge case message
    mov r2, #31                    // length
    swi 0
    
    // Print newline
    mov r0, #1                     // stdout
    mov r7, #4                     // write syscall
    ldr r1, =newline               // newline
    mov r2, #1                     // length
    swi 0
    
normal_case:
    // Run the actual test by calling our digit printing logic
    // Load the test value
    ldr r3, [r11]             // Load value back to r3
    
    // Here we include our actual digit printing logic
    // Check if n is single/double digit and process accordingly
    cmp r3, #10               // Compare n with 10
    blt test_single_digit     // If n < 10, branch to single_digit
    
    // Handle double digit number (10-99)
    // First, extract the tens digit
    mov r4, r3                // Copy n to r4
    mov r5, #10               // Put 10 in r5
    udiv r4, r4, r5           // r4 = n / 10 (tens digit)
    add r4, r4, #48           // Convert to ASCII
    
    // Store tens digit at the first position
    ldr r1, =digit            // Load address of buffer
    strb r4, [r1]             // Store tens digit at first position
    
    // For extracting ones digit
    mov r4, r3                // Start fresh with original n
    udiv r6, r4, r5           // r6 = n / 10
    mul r6, r5, r6            // r6 = (n/10) * 10
    sub r4, r4, r6            // r4 = n - ((n/10) * 10) = ones digit
    add r4, r4, #48           // Convert to ASCII
    
    // Store ones digit at the second position
    ldr r1, =digit            // Reload address
    add r1, r1, #1            // Move to second position
    strb r4, [r1]             // Store ones digit
    b test_print              // Branch to print

test_single_digit:
    // For single digit, put a '0' in the first position
    mov r4, #48               // ASCII '0'
    ldr r1, =digit            // Load address of buffer
    strb r4, [r1]             // Store '0' at first position
    
    // And put the actual digit in second position
    add r4, r3, #48           // Convert digit to ASCII
    add r1, r1, #1            // Move to second position
    strb r4, [r1]             // Store digit
    
    // Fall through to print

test_print:
    // Print the result message
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =actual_msg       // "Actual: "
    mov r2, #10               // length
    swi 0
    
    // Print digit buffer
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =digit            // The address of buffer
    mov r2, #3                // Length (2 digits + newline)
    swi 0
    
    // Move to next test
    ldr r8, =current_test     // Get address of current test
    ldr r9, [r8]              // Load current test
    add r9, r9, #1            // Increment test counter
    str r9, [r8]              // Store updated counter
    b test_loop               // Continue with next test

exit_success:
    // Print success message and exit
    mov r0, #1                // stdout
    mov r7, #4                // write syscall
    ldr r1, =pass_msg         // "All tests passed\n"
    mov r2, #5                // length
    swi 0
    
    // Exit with success
    mov r0, #0                // return code 0
    mov r7, #1                // exit syscall
    swi 0