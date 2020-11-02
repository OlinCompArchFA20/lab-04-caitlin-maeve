# find the highest value in a series of four inputs
# using loops in this version
# originally tried to make it find highest and lowest but that was too hard :(

addi $a0, $zero, 82      # input value 0
addi $a1, $zero, 4 	# input value 1
addi $a2, $zero, 200	# input value 2 
addi $a3, $zero, 137	# input value 3 

addi $t0, $zero, 1 	# n
addi $t1, $a0, 0 	# current compare 1
addi $t2, $a1, 0 	# current compare 2

addi $s0, $zero, 0	# highest value

loop:
	addi $t0,$t0,1        #n++
	slt $s0, $t1, $t2 	# find index of the highest value
	beq $s0, $zero, firstMore # if t0 is greater
	bne $s0, $zero, secondMore # if t1 is greater
	
firstMore:
	addi $s0, $t1, 0 # set highest to t1
	j update

secondMore:
	addi $s0, $t2, 0 # set highest to t2
	j update

update:  		# update values for next comparison based on n
	beq $t0, 2, compare2
	beq $t0, 3, compare3
	beq $t0, 4, finish
		
compare2:
	addi $t1, $s0, 0 # last highest
	addi $t2, $a2, 0 # value 3
	j loop

compare3: 
	addi $t1, $s0, 0 # last highest
	addi $t2, $a3, 0 # value 4
	j loop
	
finish: 
	add $s0,$zero,$s0     #return the answer
	addi $v0,$zero,1      #set syscall type to print int
	addi $v0,$zero,10     #set syscall type to exit 
