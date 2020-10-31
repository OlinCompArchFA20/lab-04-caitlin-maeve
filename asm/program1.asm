# find the highest value in a series of four inputs
# using loops in this version
# originally tried to make it find highest and lowest but that was too hard :(

addi $a0, $zero, 8      # input value 0
addi $a1, $zero, 4 	# input value 1
addi $a2, $zero, 3	# input value 2 
addi $a3, $zero, 3	# input value 3 

addi $t0, $zero, 1 	# loop counter
addi $t1, $a0, 0 	# current compare 1
addi $t2, $a1, 0 	# current compare 2
addi $t3, $zero, 0	# highest value

loop:
	addi $t0,$t0,1        #n++
	slt $t3, $t0, $t1 	# find the lowest of the two values
	bne $t3, $zero, firstMore # if t0 is greater
	beq $t3, $zero, secondMore # if t1 is greater

update: 
	# update the values for comparison
	beq $t0, 2, compare2
	beq $t0, 3, compare3
	beq $t0, 4, finish
		
compare2:
	addi $t1, $t3, 0 # last highest
	addi $t2, $a2, 0 # new value
	j loop

compare3: 
	addi $t1, $t3, 0 # last highest
	addi $t2, $a3, 0 # new value
	j loop
	
firstMore:
	addi $t3, $a0, 0 # set highest
	j update

secondMore:
	addi $t3, $a1, 0 # set highest
	j update

finish: 
	add $t3,$zero,$t3     #return the answer
	addi $v0,$zero,1      #set syscall type to print int
	SYSCALL               #print $a0
	addi $v0,$zero,10     #set syscall type to exit 
	SYSCALL               #exit