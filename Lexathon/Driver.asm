.globl main
.data
initTime:	.word	10000 # game starts with N seconds
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
	li	$v0, 30			# get system time
	syscall
	addu	$s2, $a0, $t0		# $s2 contains absolute time limit
gameLoop:
	li	$v0, 30			# update time
	syscall
	subu	$t0, $s2, $a0
	blez	$t0, endGame		# check if time over
	move	$a0, $t0
	jal	printTime
	
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

	j	gameLoop
endGame:
	jal	printGameOver
	
	### temp stuff check what the list is
	move	$a0, $s1
	li	$v0, 4
	syscall
	jal	printLn
	jal	printLn
	### /temp stuff
	j	start
quit:
	li	$v0, 10
	syscall
