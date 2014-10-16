############################################################
# Notes:
# - dict .space must be 10 * number of words/lines in .txt
# - the mars.jar must be located in the same location as .txt
############################################################

.data
	buffer:	.space 10	# arbitrary
	dict:	.space 90	# number of words * 10 bytes (max length 9 letter + null)
	file:	.asciiz "words.txt"
.text

.globl	loadDict
############################################################
# String[] loadDict()
# function that reads words in from .txt file and returns
# the array address in $v0
############################################################
# $t0 (unused) used to contains file descriptor
# $t1 address/index of dictionary
# $t2 byte from current index of buffer
# $t3 (unused) used to contain counter for something
# $t4 counter for bytes/word needed for alignment
###########################################################			
loadDict:
	li	$v0, 13		# system call for open file
	la	$a0, file	# output file name
 	li	$a1, 0		# open for writing (flags are 0: read, 1: write)
 	li	$a2, 0		# mode is ignored
	syscall

 	# scan file
 	move	$a0, $v0	# file to read
 	li	$a2, 10		# length of buffer (change this if changing buffer size)
 	la	$t1, dict	# save address of dictionary
 	li	$t4, 10		# (init) number of bytes allowed per word in dictionary
readMore:
 	la	$a1, buffer	# reset buffer address
 	li	$v0, 14		# syscall read file
 	syscall
 	beqz	$v0, finishReading	# no more letters to read
scanBuffer:
 	beqz	$v0, readMore		# check if theres anything left in buffer
 	lb	$t2, 0($a1)		# load byte at current index of buffer
 	#beqz	$t2, finishReading	# null term found, no more to read
 	beq	$t2, 13, carriageFound	# (13) CR
 	beq	$t2, 10, newlineFound	# (10) NL
 	sb	$t2, 0($t1)		# store byte in current index of dictionary
 	subi	$v0, $v0, 1		# decr number of bytes left to read in buffer
 	subi	$t4, $t4, 1		# decr number of spaces needed to align word
 	addi	$a1, $a1, 1		# incr buffer index
 	addi	$t1, $t1, 1		# incr dict index
 	j 	scanBuffer
carriageFound:			# ignores carriage returns
 	addi	$a1, $a1, 1	# incr index past carriage
 	subi	$v0, $v0, 1	# decr bytes left to read
 	j	scanBuffer
newlineFound:			# prep for next word
 	addi	$a1, $a1, 1	# incr index past newline
 	subi	$v0, $v0, 1	# decr bytes left to read
	add	$t1, $t1, $t4	# start next word on a multiple of 10
 	li	$t4, 10		# (refresh) number of bytes/word
 	j	scanBuffer
finishReading:
 	li	$v0, 16		# close file
 	syscall
 	la	$v0, dict	# load dictionary address in $v0 to return
 	jr	$ra