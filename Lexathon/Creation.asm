##
#	Creation.asm: logic for setting up a new round/game
##
# globals:
#   random9word
#     void random9word(String word):
#       a0: address of where word is to be stored
#   scrabbleList
#     void scrabbleList(String word, String[] list):
#       a0: 9 letter word to check against (with middle character)
#       a1: address of list to store words in
 
.globl	random9Word
.globl	scrabbleList

.data
	buffer:	.space 10			# longest word will be 9 letters + /0, use for read from file

#	testFi:	.asciiz "9LetterWordList10.txt"  	
#	testWo:	.asciiz "oncomings"
#	testSc: .asciiz "4LetterWordList3911.txt"
#	testSc2:.asciiz "5LetterWordList4.txt"
	
#	words4: .asciiz "4LetterWordList3911.txt"
#	words5: .asciiz "5LetterWordList8649.txt"
#	words6: .asciiz "6LetterWordList15246.txt"
#	words7: .asciiz "7LetterWordList23123.txt"
#	words8: .asciiz "8LetterWordList28423.txt"
#	words9: .asciiz "9LetterWordList24869.txt"
#	num9:	.word	24869

	words4: .asciiz "s4LetterWordList1967.txt"
	words5: .asciiz "s5LetterWordList3824.txt"
	words6: .asciiz "s6LetterWordList6063.txt"
	words7: .asciiz "s7LetterWordList7973.txt"
	words8: .asciiz "s8LetterWordList8326.txt"
	words9: .asciiz "s9LetterWordList7729.txt"
	num9:	.word	7729	# num words in 9 letter list
			
	conf4:	.asciiz "...4 letters generated\n"
	conf5:	.asciiz "...5 letters generated\n"
	conf6:	.asciiz "...6 letters generated\n"
	conf7:	.asciiz "...7 letters generated\n"
	conf8:	.asciiz "...8 letters generated\n"
	conf9:	.asciiz "...9 letters generated\n\n"
		
	oriTbl: .space 26	# hashtable for original 9 letter word
	.align	2 
	chkTbl: .space 28	# hashtable for words to check against original
.text

# testMisc:
#	#j test9
#	la	$a0, testWo
#	jal	scrabbleList
#	j testEnd
	
	
#test9:
#	li	$s0, 10			# run the test 10 times
#test9Loop:
#	jal	random9Word		# put random 9 letter word in $v0
#	move	$a0, $v0		# and print
#	li	$v0, 4
#	syscall
#	la	$a0, nl
#	syscall
#	
#	addi	$s0, $s0, -1
#	bnez	$s0, test9Loop
#	
#	j testEnd
	
	
#testEnd:
#	li	$v0, 10
#
#	syscall


# using hashtable
# initial load 26 (28 for ease of wipe) bytes
# -- init hashtable with 9 bytes
# for every word, 9 readword, 9 readtable1, 9 readtable2, 9 storetable2, 9wipe

# using stringcompare
# for every word, 9 load, 9 store prep, 5 write, 9*5 compare

##################################################################
##################################################################
##################################################################


##
# a0: word to check agaisnt
# a1: where to store list
##
scrabbleList:
	addiu	$sp, $sp, -16	# store return address on stack
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)	# address of beginning of heap
	sw	$s1, 8($sp)	# address of middle letter
	sw	$s2, 12($sp)	# current heap address

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

## setting up list of words to return		
	move	$s0, $a1	# address of list base
	move	$s2, $s0	# current list index address
	
# write 4 letter words
	la	$a0, words4	# source file
	li	$a1, 5		# number of letters including /0
	move	$a2, $s1	# middle letter
	move	$a3, $s2	# heap location to start writing from
	jal	checkList
	move	$s2, $v0
	
	la	$a0, conf4
	li	$v0, 4
	syscall
	
# write 5 letter words
	la	$a0, words5	# source file
	li	$a1, 6		# number of letters including /0
	move	$a2, $s1	# middle letter
	move	$a3, $s2	# heap location to start writing from
	jal	checkList
	move	$s2, $v0
	
	la	$a0, conf5
	li	$v0, 4
	syscall

# write 6 letter words
	la	$a0, words6	# source file
	li	$a1, 7		# number of letters including /0
	move	$a2, $s1	# middle letter
	move	$a3, $s2	# heap location to start writing from
	jal	checkList
	move	$s2, $v0
	
	la	$a0, conf6
	li	$v0, 4
	syscall

# write 7 letter words
	la	$a0, words7	# source file
	li	$a1, 8		# number of letters including /0
	move	$a2, $s1	# middle letter
	move	$a3, $s2	# heap location to start writing from
	jal	checkList
	move	$s2, $v0
	
	la	$a0, conf7
	li	$v0, 4
	syscall	

# write 8 letter words
	la	$a0, words8	# source file
	li	$a1, 9		# number of letters including /0
	move	$a2, $s1	# middle letter
	move	$a3, $s2	# heap location to start writing from
	jal	checkList
	move	$s2, $v0
	
	la	$a0, conf8
	li	$v0, 4
	syscall	

# write 9 letter words
	la	$a0, words9	# source file
	li	$a1, 10		# number of letters including /0
	move	$a2, $s1	# middle letter
	move	$a3, $s2	# heap location to start writing from
	jal	checkList
	move	$s2, $v0
	
	la	$a0, conf9
	li	$v0, 4
	syscall	
			
# finish list with @ and /0
	li	$t0, 64
	sb	$t0, 0($s2)
	sb	$0, 1($s2)
	addi	$s2, $s2, 2
#	sub	$t0, $s2, $s0	leftover heap math

# real heap pointer		
#	move	$a0, $t0	# allocate $t0 bytes on heap
#	li	$v0, 9
#	syscall
#	la	$v0, theList
		
	lw	$s2, 12($sp)		
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 16
	jr	$ra


##
# a0: word file to read
# a1: number of letters in words including /0
# a2: middle letter
# a3: current heap location
# v0: ending heap location
##
checkList:
	addiu	$sp, $sp, -20	# store return address on stack
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)	# address of heap base
	sw	$s1, 8($sp)	# letters per word
	sw	$s2, 12($sp)	# middle letter
	sw	$s3, 16($sp)	# file descriptor
	
	move	$s0, $a3	# heap base
	move	$s1, $a1 	# letters per word including /0
	move	$s2, $a2	# value of middle letter

# open word file read from
	jal	openFile
	move	$s3, $v0	# store file descriptor
# grab next word
grabNext:	
	move	$a0, $s3	# file desc
	la	$a1, buffer	# input buffer
	move	$a2, $s1	# chars to read
	jal	nextWord

	# if @ is read (1 letter), finish
  	li	$t0, 1
  	beq	$t0, $v1, finishUp
	
	la	$t1, oriTbl
	la	$t2, chkTbl

## reset chkTbl
	li	$t3, 7		# 7*4 = 28
	li	$t4, 0		# current address
wipeCheck:
	sw	$0, chkTbl($t4)
	addi	$t4, $t4, 4	
	addi	$t3, $t3, -1
	bnez	$t3, wipeCheck

# compare word with OriTbl
	li	$t0, 0		# current letter
	addi	$t5, $s1, -1	
loopCheck:	
	lb	$t2, buffer($t0)
	addi	$t2, $t2, -97
	bltz	$t2, grabNext		# bad letter found, probably '-'
	lb	$t3, oriTbl($t2)
	lb	$t4, chkTbl($t2)
	addi	$t4, $t4, 1
	blt	$t3, $t4, grabNext	# chk contains letter count not in ori
	sb	$t4, chkTbl($t2)
	
	addi	$t0, $t0, 1
	blt	$t0, $t5, loopCheck	# more letters to check

#finalCheck:
	addi	$t0, $s2, -97
	lb	$t1, chkTbl($t0)
	beqz	$t1, grabNext		# doesn't contain middle letter

# write to file if success
	li	$t0, 0			# current letter
copyWord:
	lb	$t1, buffer($t0)
	sb	$t1, 0($s0)
	add	$s0, $s0, 1
	addi	$t0, $t0, 1
	bne	$t0, $t5, copyWord	# more to copy
	
	li	$t1, 32			# space
	sb	$t1, 0($s0)
	addi	$s0, $s0, 1
	j	grabNext

# close file
finishUp:
	move	$a0, $s3
	jal	closeFile
	move	$v0, $s0
	
	lw	$s3, 16($sp)
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 20
	jr	$ra

##################################################################
##################################################################
##################################################################

##
# a0: address of where to store word
##
random9Word:
	move	$a3, $a0
	la	$a0, words9
	li	$a1, 9
	lw	$a2, num9
	j	randomWord	# randomWord() contains the jr $ra

# a0: file address
# a1: letter per word
# a2: number of words in file
# a3: address of where to store word
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
	move	$a1, $a3
	move	$a2, $t1	# letters/word for nextWord()
randomLoop:
	addi	$t3, $t3, -1
	bnez	$t3, normalLoop
	move	$a1, $a3	
normalLoop:
	jal	nextWord	# only changes v0, up
	bnez	$t3, randomLoop
	
	move	$a0, $t0	
	jal	closeFile
	
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 4
	jr	$ra

##################################################################
##################################################################
##################################################################


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
#	changes only $v0 and $v1
##
# a0: file distriptor
# a1: input buffer
# a2: number of characters to read
##
# v0: address of input buffer with next word
# v1: number of letters read
nextWord:
	li	$v0, 14
	syscall
	addu	$a1, $a1, $a2	# shift address to location of space+1
	sb	$0, -1($a1)	# null the space in input buffer
	subu	$a1, $a1, $a2	# restore address
	
	move	$v1, $v0	# return number of letters read
	move	$v0, $a1	# return input buffer with next word
	jr	$ra
