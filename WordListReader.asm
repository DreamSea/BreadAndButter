# several shortcuts taken such that the methods in this break quite a few convention rules
# 
# fairly sure .globl random9Word /does/ obey convention rules as a whole, making it
# safe to be called from from other files
.globl	random9Word

.data
	buffer:	.space 10			# longest word will be 9 letters + /0
	testFi:	.asciiz "9LetterWordList10.txt"
	words9:	.asciiz "9LetterWordList10.txt"	# name of 9 letter word list file
	num9:	.word	10			# number of words in 9 letter word list file

	nl:	.asciiz	"\n"
.text

test:
	li	$s0, 10			# run the test 10 times
testLoop:
	jal	random9Word		# put random 9 letter word in $v0
	move	$a0, $v0		# and print
	li	$v0, 4
	syscall
	la	$a0, nl
	syscall
	
	addi	$s0, $s0, -1
	bnez	$s0, testLoop
	
	li	$v0, 10			# exit when test is finished
	syscall

##
# v0: returns address of random 9 letter word
##
random9Word:
	la	$a0, words9
	li	$a1, 9
	lw	$a2, num9
	j	randomWord	# randomWord() contains the jr $ra

# a0: file address
# a1: letter per word
# a2: number of words in file
# v0: returns address of random word
randomWord:
	addiu	$sp, $sp, -4	# store return address on stack
	sw	$ra, 0($sp)
	
	addi	$t1, $a1, 1	# t1 contains letters per word including /0
	move	$t2, $a2	# t2 contains words in file
	
	jal	openFile	# address stored in $a0
	move	$t0, $v0	# t0 contains file descriptor
	
	li	$v0, 42
	move	$a1, $t2	# generates a random int [0, words in file)
	syscall
	addi	$t3, $a0, 1	# place random int in $t3, which counts how many words to go through
		
	move	$a0, $t0	# file descriptor for nextWord()
	la	$a1, buffer	# input buffer for nextWord()
	move	$a2, $t1	# letters/word for nextWord()
randomLoop:
	jal	nextWord	# only changes v0, up
	addi	$t3, $t3, -1
	bnez	$t3, randomLoop
	move	$t4, $v0	# save chosen word
	
	li	$v0, 16		# close file
	move	$a0, $t0	
	syscall
	
	move	$v0, $t4	# move chosen word into return register
	
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 4
	jr	$ra

##
#	changes only $v0	
##
# a0: address
# a1: flags
# a2: mode
# v0: file descriptor
openFile:
	li	$v0, 13
	li	$a1, 0
	li 	$a2, 0
	syscall
	jr	$ra

##
#	changes only $v0
##
# a0: file distriptor
# a1: input buffer
# a2: number of characters to read
# v0: word
nextWord:
	li	$v0, 14
	syscall
	addu	$a1, $a1, $a2	# shift address to location of space+1
	sb	$0, -1($a1)	# null the space in input buffer
	subu	$a1, $a1, $a2	# restore address
	
	move	$v0, $a1	# return input buffer with next word
	jr	$ra
