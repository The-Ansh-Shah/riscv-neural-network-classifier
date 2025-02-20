.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    add t0 a0 zero  # t0 will index the list
    blt zero a1 loop_start
    li a0 36
    j exit

loop_start:
    # Read the first index
    lw t1 0(t0)
    # Check if it's less than 0
    bge t1 zero loop_continue
    # If it is less than 0, we need to store a 0 at the location
    sw zero 0(t0)

loop_continue:
    # Decrease iterations
    addi a1 a1 -1
    # Let's check if we're done
    beq zero a1 loop_end
    # Increment the index pointer by 4 (sizeof(int))
    addi t0 t0 4
    # Loop again
    j loop_start

loop_end:
    # Epilogue
    jr ra
