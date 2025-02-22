.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    bge zero a2 error_36    # Check if num_elems < 1
    bge zero a3 error_37    # Check if stride_arr0 < 1
    bge zero a4 error_37    # Check if stride_arr1 < 1
   
    # Set up some counters
    add t0 a0 zero
    add t1 a1 zero
    
    # Set a0 to an empty sum
    add a0 zero zero
    
    # Set the strides to 4 times whatever they currently are (for ints)
    slli a3 a3 2
    slli a4 a4 2
    
loop_start:
    # Store the current positions
    lw t2 0(t0)
    lw t3 0(t1)
    
    # Store the sum of multiplications in a0
    mul t4 t2 t3
    add a0 a0 t4
    
    # Increase counts
    add t0 t0 a3
    add t1 t1 a4
    
    # Check if we're still under a2 (elements to use)
    addi a2 a2 -1
    blt zero a2 loop_start

loop_end:
    # Epilogue
    jr ra
    
error_36:
    addi a0 zero 36
    j exit
    
error_37:
    addi a0 zero 37
    j exit