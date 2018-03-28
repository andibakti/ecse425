
#this program will test basic register instructions : add, sub, and, nor, or, xor, shiftleft, shiftright, div, mul

addi $1, $0, 10  #reg 1 = 10
addi $2, $0, 2   #reg2 = 2
add $3, $1, $2   #reg3 = 12
sub $4, $3, $2   #reg4 = 10
mul $5, $1, $2   #reg5 = 20
div $6, $3, $2   #reg6 = 6
sll $7, $2, 4    #reg7 = 32
srl $8, $2, 1    #reg8 = 1
or $1, $5        #reg1 = 30
addi $9, $0, 31  #reg9 = 31
and $9, $2       #reg9 = 2

