
# Fibonacci sequence generation

addi $10, $0, 5           # Stores the number of generated number desired
addi $1, $0, 1            # F(0) = 1, reg 1 always store F(n-1)
addi $2, $0, 1            # F(1) = 1, reg 2 always stores F(n)
addi $11, $0, 3000        # store address in mem
addi $15, $0, 4           # word size

loop : addi $3, $2, 0     # temp = old F(n)
	add $2, $2, $1        # update F(n)
	addi $1, $3, 0        # update F(n-1)
	mult $10, $15         # computes by how much data pointer is shifted
	mflo $12
	add $13, $11, $12     # update data pointer
	sw $2, 0($13)         # stores F(n) in mem
	addi $10, $10, -1     # decrease counter
	bne $10, $0, loop     # loop condition
	
#end of program
	
