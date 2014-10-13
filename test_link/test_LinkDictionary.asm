# test to link with LoadDictionary file and print a loaded word from returned array

.globl scanBuffer

.text
	jal	loadDict	# returns address of dictionary array in $v0
	move	$t0, $v0	# store dict array in $t0
printWord:
	li	$v0, 11		# syscall to print char
	lb	$a0, ($t0)	# load byte from dict array
	beqz	$a0, scanBuffer	# end of word found
	syscall
	addi	$t0, $t0, 1	# incr array index
	j printWord
	
#loadDict:			# just testing how global labels interact
scanBuffer:			# just testing how global labels interact
	li	$v0, 10
	syscall
				# looks like jump prefers labels in same file before global
				# (or does it jump to closest matching label?)