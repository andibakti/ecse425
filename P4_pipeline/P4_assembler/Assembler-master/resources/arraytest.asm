# store in memory an array with values 1,2,3,4,5,6,7,8,9,10
addi $10, $0, 100  	# array pointer address
add $1, $10, $0  	# array pointer address 
addi $2, $0, 1		# value to store
addi $3, $0, 110 	# max array address to loop until 

loop: sw $2, 0($1) 
addi $1, $1, 1 			# increment address
addi $2, $2, 1 			# increment value of value to store
bne $1, $3, loop 

addi $1, $10, 0 		# reset array pointer address

loop2: lw $5, 0($1) 		# read from memory
addi $1, $1, 1
bne $1, $3, loop2 