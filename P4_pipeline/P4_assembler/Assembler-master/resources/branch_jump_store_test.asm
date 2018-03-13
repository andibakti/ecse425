addi $15, $0, 4 			# initializing the beginning of Data Section address in memory
addi $11,  $0, 2000			# word size in byte

addi $1, $0, 3
addi $2, $0, 3
sub  $3, $1, $3
and  $4, $1, $2 
beq  $3, $0, Branch			# Branch is always taken
ori  $2, $2, 1
addi $5,  $0, 20
mult $4, $15			
mflo $12

Branch: addi $10, $0, 0
		mult $10, $4		# $lo=4*$10, for word alignment 
		mflo $12			# assume small numbers
		add  $13, $11, $12  # Make data pointer [2000+($10)*4]
		or   $5, $1, $2
		
		j Store
		
Store: sw $5, 0($13)