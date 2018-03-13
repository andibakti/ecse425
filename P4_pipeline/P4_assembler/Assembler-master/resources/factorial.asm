# computes factorial of n > 0, where n is stored in register $1

# example: !5 = 1 * 2 * 3 * 4 * 5

# 	function: factorial(n)
# 		k = 1
# 		i = 1
# 		while [ i != n ] do
# 			lo = k * i
# 			k = lo
# 			i = i + 1
# 		end while
# 		return k
#	end function

# value of factorial to compute
addi $1, $0, 5 # n

################################

addi $2, $0, 1 # k 
addi $3, $0, 1 # i

loop: 	beq $1, $3, END
		mult $2, $3
		mflo $2 
		addi $3, $3, 1
		j loop

# store result in $1
END: addi $1, $2, 0

