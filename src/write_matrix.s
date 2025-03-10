.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue
    addi sp sp -20
    sw ra 0(sp)
    sw s0 4(sp) # matrix loc
    sw s1 8(sp) # file desc
    sw s2 12(sp) # row
    sw s3 16(sp) # cols
    
    mv s0 a1 # matrix location (let's just track it)
    mv s2 a2
    mv s3 a3
    
    # prepare to open
    li a1 1
    jal ra fopen
    li t0 -1
    beq a0 t0 fopen_error
    
    # if it hasnt errored, a0 is the file descriptor, and we write a2 and a3 to the file
    mv s1 a0 # has the file descriptor (we'll need it to close the file)
    
    addi sp sp -8
    sw s2 0(sp)
    sw s3 4(sp)
    mv a1 sp
    
    li a2 2
    li a3 4
    
    jal ra fwrite
    
    addi sp sp 8
    
    li t0 2
    bne t0 a0 fwrite_error
    
    # now we write the rest of the data onto the file
    mv a0 s1
    mv a1 s0
    mul a2 s2 s3
    li a3 4
    
    jal ra fwrite
    
    mul t0 s2 s3
    bne t0 a0 fwrite_error
    
    # now we close the file
    mv a0 s1
    jal ra fclose
    bne x0 a0 fclose_error

    # Epilogue
   
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    addi sp sp 20

    jr ra


fopen_error:
    li a0 27
    j exit
   
fwrite_error:
    li a0 30
    j exit
    
fclose_error:
    li a0 28
    j exit