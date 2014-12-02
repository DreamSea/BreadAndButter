# $s0 : absolute time limit
# $s1 : time bonus per good guess (load extraTime in here once to have in registers)
# $s2 : n-letter list to print, use in showWords loop
# $s3 : contains word input from user
# $s4 : contains time left, equal to $s0 minus current time
# ---
# TODO: can mess with scoring in $s5 - s7
# TODO: maybe adjust time bonus based on letters
# TODO: end game when user has guessed every word

.globl main
.data
initTime:	.word	60000 # game starts with N/1000 seconds
extraTime:	.word	10000 # +N/1000 seconds per good guess
.text
main:
start:
	jal	printTitleInfo		# choices at title screen
	jal	getUserChar
	
	beq	$v0, 113, quit		# if (input == 'q') { quit }
	beq	$v0, 110, newGame	# if (input == 'n') { new game }
	j	start			# else { ask again }

newGame:
	jal	allCreation
newGameChoice:	
	jal	printReadyInfo
	jal	getUserChar
	
	beq	$v0, 98, start		# if (input == 'b') { back to title }
	beq	$v0, 114, beginGame	# if (input == 'r') { begin game }

	j	newGameChoice
beginGame:
	lw	$t0, initTime		# initial relative time limit
	li	$v0, 30			# get system time
	syscall
	addu	$s0, $a0, $t0		# $s0 contains absolute time limit
	lw	$s1, extraTime		# $s1 contains time bonus per good guess

	li	$v0, 30			# first time update
	syscall
	subu	$t0, $s0, $a0
	move	$a0, $t0
	jal	printTime
gameLoop:	
	li	$s2, 4			# $s2 contains word length of current list
showWords:	
	move	$a0, $s2
	jal	getState		# get list of n-length words
	move	$a0, $s2
	move	$a1, $v0
	jal	printState		# print list of n-length words
	
	addi	$s2, $s2, 1
	blt	$s2, 10, showWords	# loop through showing list for lengths 4-9
	
	jal	getLetters		# grab letters to print
	move	$a0, $v0		
	jal	print3x3Word		# print 3x3 grid
	jal	getUserString
	move	$s3, $v0		# $s3 contains string input

	li	$v0, 30			# check time
	syscall
	subu	$t0, $s0, $a0
	blez	$t0, timeUp		# check if time over
	move	$s4, $t0		# $s4 contains time left 
	
	move	$a1, $s3		# pass word as argument
	jal	checkWord
	beq	$v0, -1, resign
	beqz	$v0, continue
	beq	$v0, 1, goodGuess
	j	continue
goodGuess:
	move	$a0, $v1		# pass number of letters
	move	$a1, $s3		# pass word
	jal	putWord
	add	$s0, $s0, $s1		# + extra time to absolute	
	add	$s4, $s4, $s1		# update time left too
	move	$a0, $s1
	jal	printExtraTime
continue:	
	move	$a0, $s4		# time info
	jal	printTime				
	j 	gameLoop

resign:
	jal	printResignLose
	j	leftOver
timeUp:
	jal	printTimeLose
leftOver:
	jal	collapseList	# clean list for leftover print
	jal	getList		# get list to print leftovers
	move	$a0, $v0
	jal	printLeftover
	jal	printLn
	j	start
quit:
	li	$v0, 10
	syscall
