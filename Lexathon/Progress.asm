.globl	generateState, getState, putWord

.data
state:	.space 1000			# arbitrary estimate, copying theList size
addrTbl:.word addr4, addr5, addr6, addr7, addr8, addr9
addr4:	.word 0
addr5:	.word 0
addr6:	.word 0
addr7:	.word 0
addr8:	.word 0
addr9:	.word 0

fake:	.asciiz "aaaa aaaa aaaa bbbbb bbbbb bbbbb bbbbb bbbbb jjjjjj nnnnmmmm kkkwwwmmm @"
fakeWd:	.asciiz "hmmm5"
nl_:	.asciiz "\n"

.text

testing:
	la	$a0, fake
	jal	generateState
	
	li	$a0, 5
	jal	getState
	move	$a0, $v0
	li	$v0, 4
	syscall
	la	$a0, nl_
	syscall
	
	li	$a0, 5
	la	$a1, fakeWd
	jal	putWord
	
	li	$a0, 5
	jal	getState
	move	$a0, $v0
	li	$v0, 4
	syscall
	la	$a0, nl_
	syscall
	
	li	$a0, 6
	la	$a1, fakeWd
	jal	putWord
	
	li	$a0, 5
	la	$a1, fakeWd
	jal	putWord
	
	li	$a0, 5
	jal	getState
	move	$a0, $v0
	li	$v0, 4
	syscall
	
	li	$v0, 10
	syscall

##
# creates an array mirroring theList with '.' swapped for characters
# words of different length seperated by /0/0, .... ..../0/0..... ...../0/0......., etc
##
# input: a0 - address of theList to make state from
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
	jr	$ra

##
# input: a0 - number of letters
##
# returns: v0 - address in state for letters
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
# updates state with word added to proper list		
##
# in:	a0 - number of letters
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
	beqz	$t1, end
	sb	$t1, 0($t0)
	addi	$t0, $t0, 1
	addi	$a1, $a1, 1
	j	copyWord
end:
	jr $ra