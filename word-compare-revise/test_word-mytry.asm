.data
	input:	.space 11		# space for 10 characters user input
	
	newline:.asciiz "\n"
	true:	.asciiz "Match"
	false:	.asciiz "Doesn't Match"
	filename: .asciiz "9-letter-dict.txt" #file 
	textSpace: .space 512000     #space to store strings to be read
	
.text
li $v0, 13           #open a file
li $a1, 0            # file flag (read)
la $a0, filename         # load file name
add $a2, $zero, $zero    # file mode (unused)
syscall
move $a0, $v0        # load file descriptor
li $v0, 14           #read from file
la $a1, textSpace        # allocate space for the bytes loaded
li $a2, 512000         # number of bytes to be read
syscall  


start:
	li	$v0, 8	
	la	$a0, input
	li	$a1, 11		# read 10 characters (allows 9 + nullchar)
	syscall
	la	$a0, input	# prep 1st string for compare
	la	$a1, textSpace	# prep 2nd string for compare
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
	#li $v0,10
	#syscall
	j	start		# loop back to start for testing
	
######################################################
# compareStrings($a0, $a1) returns $v0
# $a0 1st string#input
# $a1 2nd string# dictionary
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
	move	$t0, $a0	# load 1st string address in $t0
	move	$t1, $a1	# load 2nd string address in $t1
	li	$v0, 0		# init to true(1) (set false later if not true)
	li	$t9, 9		# 9 characters to scan through
	la	$t8, true	# init to true

loop:
	beqz 	$t9, found	# run through this for each char (might be overshooting by 1)
	lb	$t2, 0($t0)	# store current letter of 1st string
	lb	$t3, 0($t1)	# store current letter of 2nd string
	beq    $t3,64,end      #use @ to test the end of the dictionary.
	#beqz	$t3, nullFound	# when 1st string hits \0, go to nullfound to check state of 2nd string
	bne	$t2, $t3, nope	# if letters are not the same, false
	addi	$t9, $t9, -1	# decrement loop counter
	add	$t0, $t0, 1	# shift 1st string char index by 1
	add	$t1, $t1, 1	# shift 2nd string char index by 1
	b	loop
	
	
	
nope:
	addi    $a1,$a1,10
	j	compareStrings
	
found:
li $v0,1
j end

end:
	jr	$ra
