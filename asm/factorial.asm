addi $a0, $zero, 5       # input value to find factorial of
addi $t0, $zero, 1 	 # loop counter
addi $t1, $zero, 0	 # running total	

loop:
    mult $t2, $t1, $a0 # multiply
    addi $t0, $t0, 1
    beq $t0,$a0,breakloop #if (n==N) goto breakloop;
    j loop                #restart loop

breakloop:
    add $a0,$zero,$t1     #return the answer
    addi $v0,$zero,1      #set syscall type to print int
    SYSCALL               #print $a0
    addi $v0,$zero,10     #set syscall type to exit 
    SYSCALL               #exit
