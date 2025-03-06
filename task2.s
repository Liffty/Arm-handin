.syntax unified

.data
digit: .ascii "xx\n"    // Reserve space for two digits and a newline
digitEnd:
n:    .int 42           // Test with the number 42 (can be any number 0-99)

.text
.global _start

_start:
    // Load the value of n into register r3
    ldr r3, =n          // Get the address of n
    ldr r3, [r3]        // Load the value stored at n
    
    // Check if n is a single digit (0-9) or double digit (10-99)
    cmp r3, #10         // Compare n with 10
    blt single_digit    // If n < 10, branch to single_digit
    
    // Handle double digit number (10-99)
    // First, extract the tens digit
    mov r4, r3          // Copy n to r4
    mov r5, #10         // Put 10 in r5
    udiv r4, r4, r5     // r4 = n / 10 (tens digit)
    add r4, r4, #48     // Convert to ASCII
    
    // Store tens digit at the first position
    ldr r1, =digit      // Load address of buffer
    strb r4, [r1]       // Store tens digit at first position
    
    // For extracting ones digit (avoid using original mul approach)
    mov r4, r3          // Start fresh with original n in r4
    udiv r6, r4, r5     // r6 = n / 10
    mul r6, r5, r6      // r6 = (n/10) * 10 using the correct mul syntax
    sub r4, r4, r6      // r4 = n - ((n/10) * 10) = ones digit
    add r4, r4, #48     // Convert to ASCII
    
    // Store ones digit at the second position
    ldr r1, =digit      // Reload address of buffer
    add r1, r1, #1      // Move to second position
    strb r4, [r1]       // Store ones digit
    b print             // Branch to print

single_digit:
    // For single digit, put a '0' in the first position
    mov r4, #48         // ASCII '0'
    ldr r1, =digit      // Load address of buffer
    strb r4, [r1]       // Store '0' at the first position
    
    // And put the actual digit in second position
    add r4, r3, #48     // Convert digit to ASCII
    add r1, r1, #1      // Move to second position
    strb r4, [r1]       // Store digit
    
    // Fall through to print

// Don't touch below this label.
// This piece of code prints the string between labels
// "digit" and "digitEnd" and then exits the program.
print:
    mov r0, 1           // standard output
    mov r7, 4           // Write System call
    ldr r1, =digit      // The address of string to write
    mov r2, digitEnd-digit  // We write three bytes now (xx\n)
    swi 0
    
    // Now we exit gracefully
    mov r0, 0
    mov r7, 1
    swi 0