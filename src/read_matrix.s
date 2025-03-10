.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -16
    sw ra 0(sp)
    sw s0 4(sp)     # address of num rows
    sw s1 8(sp)     # address of num cols
    sw s2 12(sp)    # file descriptor
   
    mv s0 a1    # gonna need to keep these around
    mv s1 a2
    
    # open the file
    li a1 0 # read only
    jal ra fopen # open the file
    li t0 -1 # in case it failed
    beq t0 a0 fopen_error
    
    mv s2 a0 # keep the file descriptor saved

    # read the first 4 bytes (row count) into memory pointed by s0
    mv a1 s0
    li a2 4
    jal ra fread
    li t0 4
    bne a0 t0 fread_error

    # read the next 4 bytes (column count) into memory pointed by s1
    mv a0 s2 
    mv a1 s1
    li a2 4
    jal ra fread
    li t0 4
    bne a0 t0 fread_error
    
    # make space on the heap (a0 is currently bytes read previously, a1 is pointer to bytes, a2 is the bytes intended to be read)
    lw t0 0(s0)
    lw t1 0(s1)
    mul t0 t0 t1
    slli t0 t0 2
    mv a0 t0
    
    addi sp sp -4
    sw t0 0(sp)
    jal ra malloc
    lw t0 0(sp)
    addi sp sp 4
    
    beq a0 x0 malloc_error
    
    # now we read the rest of the matrix into this spot (a0 is pointer to location but needs to be in a1, 
    # a1 is still bytes but needs reassignment, a2 is bytes to be read but needs to be whatever t0 is)
    
    mv a1 a0 # a1 is now the location to store the matrix
    mv a2 t0 # a2 is now the number of bytes (4 * length * width)
    mv a0 s2 # file descriptor
    
    addi sp sp -8
    sw a2 0(sp)
    sw a1 4(sp)
    jal ra fread
    lw a2 0(sp)
    lw a1 4(sp)
    addi sp sp 8
    
    bne a2 a0 fread_error
    
    # finally, we fclose (a0 is bytes read, a1 is location of bytes, a2 is bytes expected to be read)
    mv a0 s2 # stick on file descriptor again
    addi sp sp -4
    sw a1 0(sp)
    jal ra fclose
    lw a1 0(sp)
    addi sp sp 4
    
    bne a0 x0 fclose_error
    
    # a1 contains the location of the matrix, but need to return it through a0
    mv a0 a1
    
    lw ra 0(sp)
    lw s0 4(sp) 
    lw s1 8(sp) 
    lw s2 12(sp) 
    addi sp sp 16
    
    jr ra

fopen_error:
    li a0 27
    j exit
    
fread_error:
    li a0 29
    j exit
    
malloc_error:
    li a0 26
    j exit
    
fclose_error:
    li a0 28
    j exit