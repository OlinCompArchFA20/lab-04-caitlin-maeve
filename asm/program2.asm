# Program that checks to see if input register a0 = t0, if not it adds 1 to t0
#v0 returns output of t0.

addi $a0, $zero, 5 # we want to return our result at index 10!
addi $t0, $zero, 3 # t0 is our counter (i)

beq  $a0, $t0, end  # if t0 == 10 we jump to end
addi $t0, $t0, 1    # adding 1 to t0

end:
# used from fib.asm script since we have set up the registers to do the same thing :)
    add $a0,$zero,$t0     #return the answer
    addi $v0,$zero,1      #set syscall type to print int
    addi $v0,$zero,10     #set syscall type to exit 
