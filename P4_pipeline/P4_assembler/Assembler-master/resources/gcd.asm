# computes the greatest common divisor of two integers stored in $1, $2
# The Euclidean Algorithm

# example: GCD(270, 190)

#     function: GCD(A, B)
#         A = 270
#         B = 190
#         if A = 0, then GCD(A, B) = B
#            return A
#         if B = 0, then GCD(A, B) = A
#            return B
#         R = A % B
#         GCD(A, B) = GCD(B, R)
#         end while
#    end function

# values to compute
# A = 270, B = 192

################################
# computes gcd of 270 and 192
addi $2, $0, 270    #A
addi $3, $0, 192    #B

loop:   beq $2, $0, ENDA
		addi $0, $0, 0
        beq $3, $0, ENDB
        div $2, $3
        add $2, $0, $3
        mfhi $3
        j loop

ENDA:    add $5, $0, $3
ENDB:    add $6, $0, $2