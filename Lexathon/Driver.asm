# $s0 : absolute time limit
# $s1 : time bonus per good guess (load extraTime in here once to have in registers)
# $s2 : n-letter list to print, use in showWords loop
# $s3 : contains word input from user
# $s4 : contains time left, equal to $s0 minus current time
# $s5 : current score
# $s6 : last score bonus
# $s7 : current highscore
# ---
# TODO: maybe adjust time bonus based on letters
# TODO: end game when user has guessed every word

.globl main
.data
initTime:	.word	60000 # game starts with N/1000 seconds
extraTime:	.word	10000 # +N/1000 seconds per good guess
scoreWord:	.word	0
scoreName:	.asciiz	"none"
scoreFile:	.asciiz	"zHighscore.txt"
.text
main:
	li	$s7, 0			# init highscore to 0
	jal	loadScore
start:
	move	$a0, $s7
	la	$a1, scoreName
	jal	printHighscore
	jal	printTitleInfo		# choices at title screen
	jal	getUserChar
	
	beq	$v0, 113, quit		# if (input == 'q') { quit }
	beq	$v0, 110, newGame	# if (input == 'n') { new game }
	beq	$v0, 114, resetScore	# if (input == 'r') { reset highscore }
	j	start			# else { ask again }

resetScore:
	li	$s7, 0
	li	$t0, 110
	la	$t1, scoreName
	sb	$t0, 0($t1)
	sb	$t0, 2($t1)
	li	$t0, 111
	sb	$t0, 1($t1)
	li	$t0, 101
	sb	$t0, 3($t1)
	
	jal	saveScore
	j	start

saveScore:
	sw	$s7, scoreWord
	li	$v0, 13		# system call for open file
	la	$a0, scoreFile	# output file name
	li	$a1, 1		# Open for writing (flags are 0: read, 1: write)
	syscall
	move	$t0, $v0	# file desc
	
	li	$v0, 15
	move	$a0, $t0
	la	$a1, scoreWord
	li	$a2, 4		# 4 bytes to a word
	syscall			# write file
	li	$v0, 15
	la	$a1, scoreName
	syscall
	li	$v0, 16
	move	$a0, $t0
	syscall			# close file
	jr	$ra
	
loadScore:
	li	$v0, 13		# system call for open file
	la	$a0, scoreFile	# output file name
	li	$a1, 0		# Open for writing (flags are 0: read, 1: write)
	syscall
	move	$t0, $v0	# file desc
	
	li	$v0, 14
	move	$a0, $t0
	la	$a1, scoreWord
	li	$a2, 4		# 4 bytes to a word
	syscall			# read file
	lw	$s7, scoreWord
	
	li	$v0, 14
	la	$a1, scoreName
	syscall
	sb	$0, scoreName($v0)
	
	li	$v0, 16
	move	$a0, $t0
	syscall			# close file
	jr	$ra
	
##################################################################

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
	li	$s5, 0			# $s5 contains score, start at 0

	li	$v0, 30			# first time update
	syscall
	subu	$t0, $s0, $a0
	move	$a0, $t0
	jal	printTime
	move	$a0, $s5
	move	$a1, $s7
	jal	printScore
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
	sll	$s6, $v1, 10		# bonus for letter length (length * 1024)
	sra	$t0, $s4, 10		# bonus for time (milli / 1024)
	add	$s6, $s6, $t0
	move	$a0, $v1		# pass number of letters
	move	$a1, $s3		# pass word
	jal	putWord
	add	$s0, $s0, $s1		# + extra time to absolute	
	add	$s4, $s4, $s1		# update time left too
	move	$a0, $s1
	move	$a1, $s6
	add	$s5, $s5, $s6 
	jal	printGood
continue:	
	move	$a0, $s4		# time info
	jal	printTime
	move	$a0, $s5
	move	$a1, $s7
	jal	printScore	
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
	move	$a1, $s5
	jal	printLeftover
	jal	printLn
	ble	$s5, $s7, notHigh
	jal	printNewHigh
	la	$a0, scoreName
	jal	getWho
	
	move	$s7, $s5
	jal	saveScore
notHigh:	
	j	start
quit:
	li	$v0, 10
	syscall
