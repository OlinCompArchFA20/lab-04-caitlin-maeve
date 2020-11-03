# v0 is the result of the $t0
# program that checks to see if input a0 = t0, and if a0 != t0 then we add 1 to t0.

addi $a0, $zero, 1 # a0 is our input we are comparing
addi $t0, $zero, 2 # t0 is the register we are comparing against
addi $t1, $zero, 0 # t1 stores the result of t0 if a0 != t0. 

beq  $a0, $t0, end  # if t0 == 10 we jump to end and add 1 to t0
addi $t0, $t0, 1
end:
# used from fib.asm script since we have set up the registers to do the same thing :)
add $a0,$zero,$t0  #returns the answer
addi $v0,$zero,1      #set syscall type to print int
addi $v0,$zero,10     #set syscall type to exit 