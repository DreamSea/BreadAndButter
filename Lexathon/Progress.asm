##
#	Progress.asm: contains state of game and logic for manipulating state
##

.globl	allCreation, getState, putWord, checkWord, collapseList, getLetters, getList

.data
letters:.space 10	# 9 letters + null
theList:.space 1000	# arbitrary estimate of buffer size needed for word list
state:	.space 1000	# copying size of theList

# jump table into state buffer
addrTbl:.word addr4, addr5, addr6, addr7, addr8, addr9
addr4:	.word 0
addr5:	.word 0
addr6:	.word 0
addr7:	.word 0
addr8:	.word 0
addr9:	.word 0

#fake:	.asciiz "abcdefghi\n"
#fakeWd:	.asciiz "@aaaa"

.text

#testing:
#	la	$a0, letters
#	la	$v0, 4
#	syscall	
#	li	$v0, 10
#	syscall

##
#	void allCreation(): sets up a new game/round
##
allCreation:
	addiu	$sp, $sp, -4	# store return address on stack
	sw	$ra, 0($sp)
	
	la	$a0, letters
	jal	random9Word	# grab random word
	li	$a0, 9
	jal	shuffle		# shuffle that word
	la	$a0, letters
	la	$a1, theList
	jal	scrabbleList	# generate list from that word
	
	la	$a0, theList
	jal	generateState	# generate state display from list
	
	lw	$ra, 0($sp)	# recover return address from stack
	addiu	$sp, $sp, 4
	jr	$ra

##
#	void generateState(): creates an array mirroring theList with '.' swapped 
#		for characters. words of different length seperated by /0/0 to
#		handle cases where there are no words of a certain length
##
generateState:
	la	$t0, state
	la	$t2, addrTbl		# address table
	li	$t4, 4			# previous letter count
setAddress:
	lw	$t3, 0($t2)		# load address from table
	addi	$t2, $t2, 4 		# move address table forword by a word
	sw	$t0, 0($t3)
nextWord:
	li	$t5, 0			# reset letter count
generateLoop:
	lb	$t1, 0($a0)
	beq	$t1, 64, finishLoop	# @ found
	beq	$t1, 32, copySpace	# space found
swapPeriod:
	addi	$t5, $t5, 1
	li	$t1, 46
	sb	$t1, 0($t0)		# write period
	addi	$t0, $t0, 1		# adv
	addi	$a0, $a0, 1
	j 	generateLoop
copySpace:
	bgt	$t5, $t4, backTrack	# check if too many letters
	sb	$t1, 0($t0)		# write space
	addi	$t0, $t0, 1		# adv
	addi	$a0, $a0, 1
	j	nextWord
backTrack:
	sub	$t0, $t0, $t5		# go back to where # letter shift happened
	sub	$a0, $a0, $t5
	subi	$t0, $t0, 1
	subi	$a0, $a0, 1
	sb	$0, 0($t0)		# write two /0s 
	sb	$0, 1($t0)
	addi	$t0, $t0, 2
	addi	$a0, $a0, 1
	addi	$t4, $t4, 1
	j	setAddress		# set up next address in table
finishLoop:
	sb	$0, -1($t0)		# write /0 in case of leftovers from previous run
	jr	$ra

##
#	String getState(int numLetters)
##
# 	input:	a0 - number of letters
# 	return:	v0 - address in state for that number of letters
## 
getState:
	la	$t0, addrTbl
	subi	$t1, $a0, 4	# change to 0 index'd
	sll	$t1, $t1, 2	# word size
	add	$t0, $t0, $t1
	lw	$v0, 0($t0)	# address of address of word from table
	lw	$v0, 0($v0)	# address of word
	jr	$ra

##
#	void putState(): updates state with word added to proper list		
##
#	a0 - number of letters
# 	a1 - word to add
##
putWord:
	la	$t0, addrTbl
	subi	$t1, $a0, 4	# change to 0 index'd
	sll	$t1, $t1, 2	# word size
	add	$t0, $t0, $t1
	lw	$t0, 0($t0)	# address of address of word from table
	lw	$t0, 0($t0)	# address of word
scanNext:
	lb	$t1, 0($t0)
	addi	$t0, $t0, 1		# adv
	bne	$t1, 46, scanNext	# check against period
	subi	$t0, $t0, 1		# undo last add
copyWord:
	lb	$t1, 0($a1)
	beqz	$t1, end	# \0 reached
	beq	$t1, 10, end	# \n reached
	sb	$t1, 0($t0)
	addi	$t0, $t0, 1
	addi	$a1, $a1, 1
	j	copyWord
end:
	jr $ra

##
#	int[] checkWord(String word): checks if word is in list, and
#  		if so mark/replace it with periods, returns result of check
##
# 	in:	a0 - word
# 	out:	v0 - 0 if no, 1 if yes, -1 if quit
#		v1 - number of letters in word, meaningless if v0 is 0
##
checkWord:
	la	$t5, theList
	li	$v0, 0
	lb	$t0, 0($a0)		# precheck against '@', '?', etc
	beq	$t0, 64, finishCW	# @ input found
	beq	$t0, 10, finishCW	# \n input found
	beq	$t0, 63, shuffleMid
	beq	$t0, 33, resignCW
resetCW:
	move	$t0, $a0
	li	$t3, 0			# letter counter for backtrack stage
loopCW:
	lb	$t1, 0($t5)
	lb	$t2, 0($t0)
	addi	$t5, $t5, 1
	addi	$t0, $t0, 1
	addi	$t3, $t3, 1
	beqz	$t2, successCW		# word reached \0
	beq	$t2, 10, successCW	# word reached \n
	beq	$t1, 64, finishCW	# list reached @
	bne	$t1, $t2, toSpaceCW	# letters dont match
	j	loopCW
successCW:
	blt	$t3, 5, finishCW	# word didnt have enough letters
	bne	$t1, 32, toSpaceCW	# word was only prefix of list item
	li	$v0, 1
	li	$t4, 46			# period
	addi	$t5, $t5, -1		# undo add
	addi	$t3, $t3, -1
	move	$v1, $t3		# store letter count
replaceCW:
	addi	$t5, $t5, -1
	addi	$t3, $t3, -1
	sb	$t4, 0($t5)		# fill with periods
	bnez	$t3, replaceCW
finishCW:
	jr 	$ra
resignCW:
	li	$v0, -1
	jr	$ra
toSpaceCW:				# keeps from matching suffix
	beq	$t1, 32, resetCW
	lb	$t1, 0($t5)
	addi	$t5, $t5, 1
	beq	$t1, 64, finishCW	# list reached @
	bne	$t1, 32, toSpaceCW
	j	resetCW
	
##
# 	void collapseList(): compress list by removing periods
##
collapseList:
	la	$t6, theList
	li	$t3, 46		# value of period
	li	$t4, 32		# value of space
	li	$t5, 0		# last found (to check against space after period)	
prepCL:
	lb	$t1, 0($t6)
	addi	$t6, $t6, 1
	beq	$t1, 64, finishCL	# @ found, nothing to compress
	bne	$t1, $t3, prepCL	# search for periods
	addi	$t0, $t6, -1		# $t0 contains first period found
loopCL:
	lb	$t1, 0($t6)
	addi	$t6, $t6, 1
	beqz	$t1, finalWrite
	beq	$t1, $t3, loopCL	# adv through periods
	lb	$t2, -2($t6)
	beq	$t2, $t3, loopCL	# check if last one was a period
writeCL:	
	sb	$t1, 0($t0)		# transfer bytes over
	addi	$t0, $t0, 1
	j	loopCL
finalWrite:
	sb	$0, 0($t0)
finishCL:
	jr	$ra	

##
#	void shuffle(int numLetters): shuffles first n letters of stored word
#To shuffle an array a of n elements (indices 0..n-1):
# for i from n ? 1 downto 1 do
#      j ? random integer with 0 ? j ? i
#      exchange a[j] and a[i]
##
#	a0: number of letters to shuffle
##
shuffle:
	addi	$t0, $a0, -1
shuffleLoop:
	li	$v0, 42
	move	$a1, $t0
	syscall
	
	lb	$t1, letters($a0)
	lb	$t2, letters($t0)
	sb	$t2, letters($a0)
	sb	$t1, letters($t0)
	
	addi	$t0, $t0, -1
	bgtz	$t0, shuffleLoop
	
	jr	$ra

##
#	void shuffleMid(): Shuffles letters array while keeping middle letter same
##
shuffleMid:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lb	$t0, letters+4	# swap mid letter to end
	lb	$t1, letters+8
	sb	$t0, letters+8
	sb	$t1, letters+4
	
	li	$a0, 8		# shuffle up to end-1 char
	jal shuffle

	lb	$t0, letters+4	# swap end letter back to mid
	lb	$t1, letters+8
	sb	$t0, letters+8
	sb	$t1, letters+4
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
##
#	String getLetters(): returns current shuffled word
##
getLetters:
	la	$v0, letters
	jr	$ra

##
#	String[] getList(): returns word list
##
getList:
	la	$v0, theList
	jr	$ra
