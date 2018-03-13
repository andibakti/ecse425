# ex: numbersum(5) = 1 + 2 + 3 + 4 + 5

addi $1, $0, 25 # n

################################

addi $2, $0, 0 # k 
addi $3, $0, 1 # i

loop: 	beq $1, $3, END
		add $2, $2, $3
		addi $3, $3, 1
		j loop

# store result in $1
END: addi $1, $2, 0

