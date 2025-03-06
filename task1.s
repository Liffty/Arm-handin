.syntax unified

.data
digit: .ascii "x\n"
digitEnd:
n:    .int 5

.text
.global _start

_start:
    // Load the value of n into register r3
    ldr r3, =n        // Get the address of n
    ldr r3, [r3]      // Load the value stored at n (5)
    
    // Convert the integer to ASCII
    add r3, r3, #48   // Add 48 to convert digit to ASCII (0 is 48 in ASCII)
    
    // Store the ASCII value in the digit buffer
    ldr r1, =digit    // Load the address of the digit buffer
    strb r3, [r1]     // Store the ASCII value at the buffer location

// Don't touch below this lable.
// This piece of code prints the string between labels
// "digit" and "digitEnd" and then exits the program.
print:
    mov r0,1          // standard output
    mov r7,4          // Write System call
    ldr r1,=digit     // The address of string to write
    mov r2,digitEnd-digit  // We write only two bytes, counting \n
    swi 0
    
    // Now we exit gracefully
    mov r0,0
    mov r7,1
    swi 0

