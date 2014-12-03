# toSolve: output display funky if full 9 letters input...
#	could make input length >>> expected user input to 'ensure'
#	user input ends in \n at cost of extra buffer space... 
# toSolve: input buffer as first in data segment, removes need
#	for .align and multiple of 4?
.data
	input:	.space 10		# space for 10 characters user input
	toMatch:.asciiz "toast"
	newline:.asciiz "\n"
	true:	.asciiz "Match"
	false:	.asciiz "Doesn't Match"
.text
start:
	li	$v0, 8	
	la	$a0, input
	li	$a1, 10		# read 10 characters (allows 9 + nullchar)
	syscall

	la	$a0, input	# prep 1st string for compare
	la	$a1, toMatch	# prep 2nd string for compare
	jal	compareStrings	# function to compare 1st and 2nd string

	la 	$a0, true	# init output string to true
	beqz 	$v0, wasFalse	# if false, set output string to false
	j 	printResult
wasFalse:
	la 	$a0, false
printResult:
	li	$v0, 4
	syscall
	la	$a0, newline	# output formatting
	syscall
	j	start		# loop back to start for testing
	
######################################################
# compareStrings($a0, $a1) returns $v0
# $a0 1st string
# $a1 2nd string
# $v0 true(1) if strings are equal, false(0) otherwise
# note: this only checks if first 9 characters match
######################################################
# $t0 has address to 1st string
# $t1 has address to 2nd string
# $t2 stores current character of 1st string
# $t3 stores current character of 2nd string
# $t9 has number of characters to check
######################################################
compareStrings:
	li	$v0, 1		# init to true(1) (set false later if not true)
	li	$t9, 9		# 9 characters to scan through
	la	$t8, true	# init to true
	la	$t0, ($a0)	# load 1st string address in $t0
	la	$t1, ($a1)	# load 2nd string address in $t1
loop:
	beqz 	$t9, end	# run through this for each char (might be overshooting by 1)
	lb	$t2, 0($t0)	# store current letter of 1st string
	lb	$t3, 0($t1)	# store current letter of 2nd string
	beqz	$t3, nullFound	# when 1st string hits \0, go to nullfound to check state of 2nd string
	bne	$t2, $t3, nope	# if letters are not the same, false
	addi	$t9, $t9, -1	# decrement loop counter
	add	$t0, $t0, 1	# shift 1st string char index by 1
	add	$t1, $t1, 1	# shift 2nd string char index by 1
	b	loop
nope:
	li	$v0, 0		# difference was found, set return to false(0)
	b	end
nullFound:
	beqz	$t2, end	# if 2nd string index is also \0, success
	bne	$t2, 10, nope	# else if 2nd string index isn't \n
end:
	jr	$ra

######################################################
# old byte matching shenanigans
######################################################
#li $v0 1
#la $t0, buffer
#addi $t0, $t0, 2
#lb $a0, 0($t0)
#syscall
#
#li $v0, 4
#la $a0, newline
#syscall
#
#li $v0 1
#la $t0, butter
#lb $a0, 0($t0)
#syscall
#
#li $v0, 4
#la $a0, newline
#syscall
######################################################
