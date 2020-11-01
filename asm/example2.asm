# script that alternates t1 between 0 and 1
# t3 is the number of times t1 alternates :)
# v0 is the result of the number of times t1 alternates given the number of a0 loops
# basically v0 is the result of when we divide our input a0 by 2, except we don't really divide.  

li $a0, 10 # we want to return our result at index 10!
li $t0, 0 # t0 is our counter (i)
li $t1, 0 # t1 is our alternating value between 0 and 1
li $t2, 0 #t2 is 0.
loop: 
	beq  $a0, $t0, end  # if t0 == 10 we jump to end
	addi $t0, $t0, 1    # adding 1 to the counter
	# we check to see if t2 and t1 are equal, if they are we make them not equal and we add 1 to $t3. 
	# if they aren't make them equal next time around. 
	beq $t2, $t1, then # if t1 == t2 we jump to then
	li $t1, 0
	j loop           # jump back to the top of the loop
	
then: 
addi $t3, $t3, 1
li $t1, 1
j loop

end:
# used from fib.asm script since we have set up the registers to do the same thing :)
    add $a0,$zero,$t3     #return the answer
    addi $v0,$zero,1      #set syscall type to print int
    SYSCALL               #print $a0
    addi $v0,$zero,10     #set syscall type to exit 
    SYSCALL               #exit
