# A program to randomly pick a lucky number (between 1 to 100) and to ask the user to guess it.  
# You may assume the user always gives valid input

.data
# lower and upper bounds of the lucky number
lowBound: .word 1
highBound: .word 100


# define the strings for any output messages
guessMsg: .asciiz "\n\n\nThe number of guess made so far: " 
rangeMsg: .asciiz "\nThe lucky number is between "
andMsg: .asciiz " and "
inputNumMsg: .asciiz "\nEnter your guess of the number: "
correctMsg: .asciiz "\n\nYour guess is correct!\n"

 

.text
.globl main

main:	# use syscall of code 30 to get the current time as the number of milliseconds from Jan. 1, 1970. The returned number is in 64 bits (lower 32 bits in $a0 and higher 32 bits in $a1)
	# you don't need to know the syscall code 30 but can see the MIPS->Syscalls tab in MARS help manual for its details. 
	li $v0, 30   # Get the current time; (lower 32 bits in $a0 and higher 32 bits in $a1)
	syscall 

	# use syscall of code 40 to set the seed of a random number generator. The lower 32 bits of the current time is used for the seed.
	# you don't need to know the syscall code 40 but can see the MIPS->Syscalls tab in MARS help manual for its details. 
	li $v0, 40  # Set the seed for random generator; 
	addi $a1, $a0, 0  # Here, $a1 is for storing the seed values (which is the lower 32 bits of the current time; i.e. in $a0)
	li $a0, 1	# $a0 here is used as the ID of the random generator.  It can be any integer, use 1 for simplicity.
	syscall

	la $t0, lowBound 	# t0 stores the ADDRESS of the lower bound "array"
	lw $s0, 0($t0) 		# s0 stores the lower bound INTEGER 
	la $t1, highBound 	# t1 stores the ADDRESS of the upperbound "array"
	lw $s1, 0($t1) 		# s1 also stores the upper bound INTEGER
	li $s5, 0           	# keep the number of guesses input so far
						# s0: Lowerbound of the SECRET number;  
						# s1: Upperbound of the SECRET number;
						# s5: number of times of guesses by the user so far
	
	# get the range of the bounds  
	sub $t0, $s1, $s0  # $t0 (=99) stores the range of bounds of the SECRET
	addi $t0, $t0, 1   # add 1 to $t0, (i.e. $t0=100) since when the upperbound of the RANDOM number is set, 
					   # this RANDOM number Uppebound is Non-inclusive (see desc. below)

	# use syscall of code 42 to get a random number (returned in $a0) from the range [0, $a1).
	# you don't need to know the syscall code 42 but can see the MIPS->Syscalls tab in MARS help manual for its details. 
	li $v0, 42  		# Generate a RANDOM number of range [0, $a1), It Must be started from Zero, upto $a1 (non-inclusive)
						# [ or ] means inclusive,  ( or ) means non-iclusive
	li $a0, 1 			# Here $a0 is used to get the ID of the random generator,(i.e. ID is 1 we set earlier)  
	
	addi $a1, $t0, 0  	# $a1 set the max. value for the RANDOM number.
						# Hence, the range of the RANDOM number is [0, $t0)  or  [0, 100) or [0, 99] 
	syscall

	add $s2, $a0, $s0   # (random number + lower bound) yields the lucky (SECRET) number in the specified bounds.
						# i.e. hence the range of the SECRET number is [1, 100]
						#
						# $s2 stores the Secret (lucky) number
	li $v0, 1
	add $a0, $s2, $zero
	syscall


guessLoop: 
	# your code begins here

	# output the number of guesses ($s5) input so far;
	li $v0, 4
	la $a0, guessMsg
	syscall
	
	li $v0, 1
	add $a0, $s5, $zero
	syscall
	

	# output the possible range (s0 and s1) of the lucky number as the guess hint for the user;
	li $v0, 4
	la $a0, rangeMsg
	syscall
	
	
	# print lower bound
	li $v0, 1
	add $a0, $s0, $zero
	syscall
	
	li $v0, 4
	la $a0, andMsg
	syscall
	
	li $v0, 1
	add $a0, $s1, $zero
	syscall
	

	# ask the user to enter a guess of the lucky number;
	li $v0, 4 
	la $a0, inputNumMsg
	syscall

	# read the input number and store it in $v0.
	li $v0, 5
	syscall

	# update the number of guesses ($s5)
	addi $s5, $s5, 1
	

	# assuming the input number is within the range in output, update the range for the next output 



	# if input number ($v0) less than lucky number, update the lower bound
	slt $t1, $v0, $s2
	bne $t1, $zero, lessThan
	j elseIf 
	lessThan:
		add $s0, $v0, $zero
		j guessLoop
			
	# if input number ($v0) greater than lucky number, update upper bound
	# then goto guessLoop to ask user input again 
	elseIf:
	slt $t1, $s2, $v0
	bne $t1, $zero, greaterThan
	j exit
	greaterThan:
		add $s1, $v0, $zero
		j guessLoop

	# if the user's guess is correct	
	# output congratulation message and exit the program.
	exit:
	li $v0, 4
	la $a0, correctMsg
	syscall 

	li $v0, 10
	syscall
	
	# further work if you work out the basic guessingGame.s successfully and want more challenge
	# user input validation
	# two-player mode	  
