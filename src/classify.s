.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t0 5
    bne a0 t0 cli_args_error
    
    addi sp sp -52
    sw ra 0(sp)
    sw s0 4(sp) # holder of read m0
    sw s1 8(sp) # holder of read m1
    sw s2 12(sp) # holder of read input
    sw s3 16(sp) # output filename
    sw s4 20(sp) # print or not
    sw s5 24(sp) # list of matrices --------- h matrix from matmul(m0, input)
    sw s6 28(sp) # row* m0
    sw s7 32(sp) # col* m0 ----- o matrix from matmul(m1, relu(h))
    sw s8 36(sp) # row* m1
    sw s9 40(sp) # col* m1
    sw s10 44(sp) # row* input
    sw s11 48(sp) # col* input

    mv s5 a1
    mv s4 a2
    lw s3 16(a1)
    
    # Read pretrained m0
    lw t0 4(s5) # t0 is now an address to m0
    mv a0 t0 # a pointer to the filename
    addi sp sp -4
    mv a1 sp
    mv s6 sp # a location for a1
    addi sp sp -4
    mv a2 sp
    mv s7 sp # a location for a2
    
    jal ra read_matrix # now a1 contains the rows, and a2 contains the cols, and a0 is the matrix
    
    mv s0 a0

    # Read pretrained m1
    lw t0 8(s5) # t0 is now an address to m1
    mv a0 t0 # a pointer to the filename
    addi sp sp -4
    mv a1 sp
    mv s8 sp # a location for a1
    addi sp sp -4
    mv a2 sp
    mv s9 sp # a location for a2
    
    jal ra read_matrix # now a1 contains the rows, and a2 contains the cols, and a0 is the matrix
    
    mv s1 a0

    # Read input matrix
    lw t0 12(s5) # t0 is now an address to input
    mv a0 t0 # a pointer to the filename
    addi sp sp -4
    mv s10 sp
    mv a1 sp
    addi sp sp -4
    mv a2 sp
    mv s11 sp
    
    jal ra read_matrix # now a1 contains the rows, and a2 contains the cols, and a0 is the matrix
    
    mv s2 a0
   
    # Compute h = matmul(m0, input)
    lw t0 0(s6) # (n) * k
    lw t1 0(s11) # k * (m)
    mul t0 t0 t1 # (n) * (m)
    slli a0 t0 2 # multiply by 4 (bytes per int), stored in a0 for malloc
    
    jal ra malloc
    
    beq x0 a0 malloc_error # if it failed, we move, otherwise a0 is location to open memory
    # now we just need matmul(s0, s2), which we will store at s5
    mv a6 a0
    mv s5 a0
    mv a0 s0
    lw a1 0(s6)
    lw a2 0(s7)
    mv a3 s2
    lw a4 0(s10)
    lw a5 0(s11)

    
    jal ra matmul

    # Compute h = relu(h)
    
    mv a0 s5 # a0 is h
    lw t0 0(s6) # (n) * k
    lw t1 0(s11) # k * (m)
    mul a1 t0 t1 # (n) * (m) # this is the number of ints in the array (n * m)
    
    jal ra relu
    
    # currently, s5 was modified in place so s5 stores relu(h)

    # Compute o = matmul(m1, h)
    # we need the dimensions of relu(h), which are the same as h (rows of m0, cols of input)
    lw t2 0(s8)    # rows of m1
    lw t3 0(s11)   # cols of input
    mul t4 t2 t3   # number of elements in o
    slli a0 t4 2   # a0 has number of bytes for o
    jal ra malloc
    beq a0 x0 malloc_error
    mv s7 a0      # s7 now holds pointer to o

    # Call matmul to compute o = m1 * h
    mv a0 s1      
    lw a1 0(s8)   
    lw a2 0(s9)  
    mv a3 s5      
    lw a4 0(s6)   
    lw a5 0(s11)  
    mv a6 s7      
    jal ra matmul

    # Write output matrix o (currently located at s7)
    mv a0 s3
    mv a1 s7
    lw a2 0(s8)
    lw a3 0(s11)
    
    jal ra write_matrix

    # Compute and return argmax(o)
    mv a0 s7
    lw t0 0(s8)
    lw t1 0(s11)
    mul a1 t0 t1
    
    jal ra argmax

    # If enabled, print argmax(o) and newline
    beq s4 x0 print
    
continue:
    
    addi sp sp -4
    sw a0 0(sp)
    mv a0 s7
    jal ra free
    mv a0 s5
    jal ra free
    lw a0 0(sp)
    addi sp sp 4
    
    addi sp sp 24 # this is for the rows and columns i had stored
    
    lw ra 0(sp)
    lw s0 4(sp) # holder of read m0
    lw s1 8(sp) # holder of read m1
    lw s2 12(sp) # holder of read input
    lw s3 16(sp) # output filename
    lw s4 20(sp) # print or not
    lw s5 24(sp) # list of matrices --------- h matrix from matmul(m0, input)
    lw s6 28(sp) # row* m0
    lw s7 32(sp) # col* m0 ----- o matrix from matmul(m1, relu(h))
    lw s8 36(sp) # row* m1
    lw s9 40(sp) # col* m1
    lw s10 44(sp) # row* input
    lw s11 48(sp)
    addi sp sp 52
    
    jr ra

malloc_error:
    li a0 26
    j exit
    
cli_args_error:
    li a0 31
    j exit
    
print:
    # a0 is currently the argmax
    addi sp sp -4
    sw a0 0(sp)
    jal ra print_int
    li a0 '\n'
    jal ra print_char
    lw a0 0(sp)
    addi sp sp 4
    j continue
