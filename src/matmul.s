.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    ble a1 x0 error # bad dimensions
    ble a2 x0 error
    ble a4 x0 error
    ble a5 x0 error
    bne a2 a4 error # matrix multiplication undefined

    # Prologue
    addi sp sp -32
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    
    li s0 0         # current row
    add s1 a1 x0    # rows in matrix 0
    add s2 a0 x0    # pointer to matrix 0
    add s3 a3 x0    # pointer to matrix 1
    add s4 a6 x0    # output matrix pointer
    add s5 a2 x0    # cols of 0 and rows of 1
    add s6 a5 x0    # cols in matrix 1
    
outer_loop_start: # move down rows of matrix 0
    bge s0 s1 outer_loop_end
    
    # find current row
    mul t0 s0 s5   
    slli t0 t0 2 # shifting by 4 bytes (bc finding int locations)   
    add t0 s2 t0
    
    # current col
    li t1 0
   
inner_loop_start: # dot product with each column of matrix 2
    bge t1 s6 inner_loop_end
    
    # Find current col
    slli t2 t1 2       
    add t2 s3 t2 
    
    # now we needa prep for the dot call (which has its inputs specified in the lab spec)
    mv a0 t0    # current row for dot (from matrix 0)
    mv a1 t2    # current col for dot (from matrix 1)
    mv a2 s5    # things to dot product
    li a3 1     # stride for rows
    mv a4 s6    # stride for cols
    
    addi sp sp -8
    sw t0 0(sp)
    sw t1 4(sp)
    jal ra dot
    lw t1 4(sp)
    lw t0 0(sp)
    addi sp sp 8
    
    # finally, let's put the number back in to correct address in terms of s4
    mul t3 s0 s6    
    add t3 t3 t1    
    slli t3 t3 2
    add t3 s4 t3    
    sw a0 0(t3)
    
    addi t1 t1 1
    j inner_loop_start

inner_loop_end:
    addi s0 s0 1   # we need to keep going until every column of matrix 1 has been hit
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    addi sp sp 32

    jr ra
    
error:
    addi a0 x0 38
    j exit