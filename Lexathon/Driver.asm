.globl main
.data
initTime:	.word	30000 # game starts with N/1000 seconds
extraTime:	.word	5000 # +N/1000 seconds per good guess
.text
main:
start:
	jal	printTitleInfo		# choices at title screen
	jal	getUserChar
	
	beq	$v0, 113, quit		# if (input == 'q') { quit }
	beq	$v0, 110, newGame	# if (input == 'n') { new game }
	j	start			# else { ask again }

newGame:
	jal	random9Word
	### NEED TO SHUFFLE WORD HERE ###
	move	$s0, $v0		# store shuffled word in $s0
	move	$a0, $s0
	jal	scrabbleList
	move	$s1, $v0		# store word list in $s1
	move	$a0, $s1
	jal	generateState		# prep state
newGameChoice:	
	jal	printReadyInfo
	jal	getUserChar
	
	beq	$v0, 98, start		# if (input == 'b') { back to title }
	beq	$v0, 114, beginGame	# if (input == 'r') { begin game }

	j	newGameChoice
beginGame:
	lw	$t0, initTime		# initial relative time limit
	lw	$s6, extraTime		# $s6 contains time bonus per good guess
	li	$v0, 30			# get system time
	syscall
	addu	$s2, $a0, $t0		# $s2 contains absolute time limit

	li	$v0, 30			# first time update
	syscall
	subu	$t0, $s2, $a0
	blez	$t0, timeUp		# check if time over (?? why is this being checked ??)
	move	$a0, $t0
	jal	printTime
gameLoop:	
	li	$s3, 4			# s3 contains word length of current list
showWords:	
	move	$a0, $s3
	jal	getState
	move	$a0, $s3
	move	$a1, $v0
	jal	printState
	
	addi	$s3, $s3, 1
	blt	$s3, 10, showWords
	
	move	$a0, $s0		# print 3x3 grid
	jal	print3x3Word
	jal	getUserString
	move	$s4, $v0		# s4 contains string input

	li	$v0, 30			# check time
	syscall
	subu	$t0, $s2, $a0
	blez	$t0, timeUp		# check if time over
	move	$s5, $t0		# s5 contains time left 
	
	move	$a0, $s1		# pass list as argument
	move	$a1, $s4		# pass word as argument
	jal	checkWord
	beq	$v0, -1, resign
	beqz	$v0, continue
	beq	$v0, 1, goodGuess
	j	continue
goodGuess:
	move	$a0, $v1		# pass number of letters
	move	$a1, $s4		# pass word
	jal	putWord
	add	$s2, $s2, $s6		# +extra time		
	add	$s5, $s5, $s6
	move	$a0, $s6
	jal	printExtraTime
continue:	
	move	$a0, $s5		# time info
	jal	printTime	
			
	j gameLoop
	
resign:
	jal	printResignLose
	j	leftOver
timeUp:
	jal	printTimeLose
leftOver:
	move	$a0, $s1
	jal	collapseList	# clean list for leftover print
	move	$a0, $s1
	jal	printLeftover
	jal	printLn
	j	start
quit:
	li	$v0, 10
	syscall
