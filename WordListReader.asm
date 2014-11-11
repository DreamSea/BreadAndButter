# several shortcuts taken such that the methods in this break quite a few convention rules
# 
# fairly sure .globl random9Word /does/ obey convention rules as a whole, making it
# safe to be called from from other files
#
# return9 exposed to outside, this .asm only changes return9 on random9Word calls
.globl	random9Word

.data
	buffer:	.space 10			# longest word will be 9 letters + /0, use for read from file
	return9:.space 10			# address of 9 letter word to return (allows buffer reuse)

	testFi:	.asciiz "9LetterWordList10.txt"

	words9:	.asciiz "9LetterWordList10.txt"	# name of 9 letter word list file
	num9:	.word	10			# number of words in 9 letter word list file

	nl:	.asciiz	"\n"
	
	testWo:	.asciiz "abandoned"
	testSc: .asciiz "4LetterWordList4.txt"
			
	oriTbl: .space 26
	chkTbl: .space 26
.text

testMisc:
	#j test9
	la	$a0, testWo
	jal	scrabbleList
	j testEnd
	
	
test9:
	li	$s0, 10			# run the test 10 times
test9Loop:
	jal	random9Word		# put random 9 letter word in $v0
	move	$a0, $v0		# and print
	li	$v0, 4
	syscall
	la	$a0, nl
	syscall
	
	addi	$s0, $s0, -1
	bnez	$s0, test9Loop
	
	j testEnd
	
	
testEnd:
	li	$v0, 10

	syscall


# using hashtable
# initial load 26 (28 for ease of wipe) bytes
# -- init hashtable with 9 bytes
# for every word, 9 readword, 9 readtable1, 9 readtable2, 9 storetable2, 9wipe

# using stringcompare
# for every word, 9 load, 9 store prep, 5 write, 9*5 compare


##
# a0: word to check agaisnt
# v0: address on heap of where list begins
##
scrabbleList:
	addiu	$sp, $sp, -12	# store return address on stack
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)	# address of end of heap
	sw	$s1, 8($sp)	# address of middle letter

## grab middle letter
	lb	$s1, 4($a0)

## reset table
	li	$t0, 0
wipeOriTbl:
	sb	$0, oriTbl($t0)
	addi	$t0, $t0, 1
	blt	$t0, 26, wipeOriTbl	

## make table	
	li	$t0, 9
makeOriTbl:
	lb	$t1, ($a0)
	addi	$t1, $t1, -97
	lb	$t2, oriTbl($t1)
	addi	$t2, $t2, 1
	sb	$t2, oriTbl($t1)
	
	addi	$a0, $a0, 1
	subi	$t0, $t0, 1
	bnez	$t0, makeOriTbl	

## heap pointer		
	li	$a0, 0		# allocate 'zero' bytes on heap
	li	$v0, 9
	move	$s0, $v0	# current address of end of heap
	
# write 4 letter words
	la	$a0, testSc
	li	$a1, 4
	move	$a2, $s1
	move	$a3, $s0
	
# write 5 letter words

	
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 12
	jr	$ra


##
# a0: word file to read
# a1: number of letters in words
# a2: middle letter
# a3: current heap location
# v0: how many letters have been added to heap pointer
##
checkList:
	addiu	$sp, $sp, -12	# store return address on stack
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)	# address of heap base
	sw	$s1, 8($sp)


# open word file read from

# compare  word with 
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 12
	jr	$ra


##
# a0: word to compare against return9
##
# v0: 1 if word can be made from return9 letters
##
checkAgainst:

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
	addi	$t3, $t3, -1
	bnez	$t3, normalLoop
	la	$a1, return9	# final loop input buffer
normalLoop:
	jal	nextWord	# only changes v0, up
	bnez	$t3, randomLoop
	
	move	$a0, $t0	
	jal	closeFile
	
	la	$v0, return9	# move chosen word into return register
	
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 4
	jr	$ra

##
#	changes $v0, $a1, and $a2
##
# a0: address
# v0: file descriptor
openFile:
	li	$v0, 13
	li	$a1, 0	#flags
	li 	$a2, 0	#mode
	syscall
	jr	$ra

##
#	changes only $v0	
##
# a0: file descriptor
closeFile:
	li	$v0, 16
	syscall
	jr	$ra

##
#	changes only $v0
##
# a0: file distriptor
# a1: input buffer
# a2: number of characters to read
# updates input buffer with next word
nextWord:
	li	$v0, 14
	syscall
	addu	$a1, $a1, $a2	# shift address to location of space+1
	sb	$0, -1($a1)	# null the space in input buffer
	subu	$a1, $a1, $a2	# restore address
	
	move	$v0, $a1	# return input buffer with next word
	jr	$ra
