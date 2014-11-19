.data
	nl:	.asciiz	"\n"
#	.globl	main
	fake:	.asciiz "azazazaza"
.text
main:
test9Loop:
	jal	random9Word		# put random 9 letter word in $v0
	move	$s0, $v0
	move	$a0, $v0		# and print
	li	$v0, 4
	syscall
	
	
	la	$a0, nl
	syscall
	
	move	$a0, $s0
	#la	$a0, fake
	jal	scrabbleList
	move	$s1, $v0
	
	la	$a0, nl
	li	$v0, 4
	
	move	$a0, $s1
	syscall
	
	li	$v0, 10
	syscall
