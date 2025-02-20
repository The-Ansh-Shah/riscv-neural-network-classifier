.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    add t0 a0 zero  # initialize the indexer (t0)
    blt zero a1 loop_start # So that length >= 1 (a1)
    addi a0 zero 36
    j exit

loop_start:
    # Take in a value from the array
    lw t1 0(t0) # This will be the max (t1)
    add t3 zero zero # This will be the max index
    
loop_continue:
    # Decrease the count
    addi a1 a1 -1
    # if we're done looking at stuff
    beq zero a1 loop_end
    # otherwise, increase the indexer to the next word
    addi t0 t0 4
    # let's take a look at the value there
    lw t2 0(t0) # temporary value to compare to (t2)
    # if max >= temp, continue
    bge t1 t2 loop_continue
    # otherwise, reassign the max
    add t1 t2 zero
    # Update the index
    sub t3 t0 a0  # Find the distance (multiples of 4) from the start
    srli t3 t3 2  # Divide by 4 to get the index
    # Continue
    j loop_continue

loop_end:
    # Epilogue
    add a0 zero t3
    jr ra
