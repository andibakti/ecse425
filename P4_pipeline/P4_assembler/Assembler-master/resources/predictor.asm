addi $1, $0, 10        #1 = 10
addi $2, $0, 20        #2 = 20
A: addi $1, $1, 2    # + 2
bne $1, $2, A
addi $10, $0, 1
addi $11, $0, 2
addi $12, $0, 3
beq $1, $0, A
addi $13, $0, 4
addi $14, $0, 5
addi $15, $0, 6
beq $1, $0, A
addi $16, $0, 7
addi $17, $0, 8