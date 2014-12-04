##
#	Display.asm: MARS console implementation of UI	
##
.globl	printTitleInfo printHighscore getUserChar printLn printTime printScore
.globl	printReadyInfo getUserString print3x3Word
.globl	printTimeLose printResignLose printState printGood printLeftover printNewHigh getWho
.data
infoHi: .asciiz "High Score: "
infoBy: .asciiz " by "
infoSt:	.asciiz	"(n)ew game\n"
infoRs:	.asciiz	"(r)eset highscore\n"
infoQu:	.asciiz	"(q)uit\n"
infoRd:	.asciiz "(r)eady\n"
infoBa:	.asciiz "(b)ack\n"
strCmd:	.asciiz "Command: "
strTime:.asciiz	"Time Left (s): "
strScor:.asciiz "Your score: "
strBeat:.asciiz "Highscore to beat: "
strGues:.asciiz "(?) Shuffle (!) Resign\nGuess: "
strOver:.asciiz "Time is up.\n"
strRes:	.asciiz "Resigned.\n"
strNHi: .asciiz "***New Highscore***\n"
strWho:	.asciiz "Input name (15 letters max): "
strList:.asciiz " letters: "
strGood:.asciiz "Word Found, Seconds +"
strGoo2:.asciiz ", Score +"
strLeft:.asciiz "Words Left: "

inBuff:	.space	10
.text

##
#	void printLn: helper function for line return
##
printLn:
	li	$v0, 11	# print char
	la	$a0, 10	# linefeed
	syscall
	jr	$ra

##
# 	void printTitleInfo(): title menu
##
printTitleInfo:
	li	$v0, 4
	la	$a0, infoSt
	syscall
	la	$a0, infoRs
	syscall
	la	$a0, infoQu
	syscall
	jr	$ra

##
#	void printHighscore(score, holder):
##
# a0 - highscore
# a1 - address of highscorer
##
printHighscore:
	move	$t0, $a0	# save to temporary while printing info
	move	$t1, $a1
	li	$v0, 4
	la	$a0, infoHi
	syscall
	move	$a0, $t0	# print score
	li	$v0, 1
	syscall
	la	$a0, infoBy
	li	$v0, 4
	syscall
	move	$a0, $t1	# print holder
	syscall
	j	printLn

##
# 	char getUserChar(): read user choice (one character)
##
# 	returns v0: user choice char
##
getUserChar:
	li	$v0, 4
	la	$a0, strCmd
	syscall
	li	$v0, 12
	syscall
	move	$t0, $v0	# temp save read info
	li	$v0, 11		# print char
	li	$a0, 10		# linefeed
	syscall
	syscall
	move	$v0, $t0	# return info
	jr	$ra

##
#	void printTime(int time): prints time in seconds
##
# 	input a0: time in milli to print
##
printTime:
	sra	$t0, $a0, 10	# convert to seconds dividing roughly by 1024
	li	$v0, 4
	la	$a0, strTime
	syscall
	move	$a0, $t0
	li	$v0, 1
	syscall
	j	printLn
	
##
#	void printScore(int current, int high):
#		prints current score and target/high score
##
#	input a0: score to print
# 	input a1: score to beat
##
printScore:
	move	$t0, $a0
	move	$t1, $a1
	la	$a0, strScor
	li	$v0, 4
	syscall
	move	$a0, $t0	# current score
	li	$v0, 1
	syscall
	li	$v0, 11
	li	$a0, 10
	syscall
	la	$a0, strBeat
	li	$v0, 4
	syscall
	move	$a0, $t1	# score to beat
	li	$v0, 1
	syscall
	j	printLn
	

##
#	void printReadtInfo(): game generated, ready to start
##
printReadyInfo:
	li	$v0, 4
	la	$a0, infoRd
	syscall
	la	$a0, infoBa
	syscall
	jr	$ra
	
## 
#	String getUserString(): read user choice (10 letter guess)
## 
#	returns v0: user choice
##
getUserString:
	li	$v0, 4		# guess prompt
	la	$a0, strGues	# take user string, 9 char max
	syscall
	li	$v0, 8
	la	$a0, inBuff
	li	$a1, 10
	syscall
	li	$v0, 11
	li	$a0, 10	
	syscall
	syscall
	la	$v0, inBuff
	jr	$ra

## 
#	void printState(int numLetters, String[] state):
#		information about words guessed and to guess
##
#	input $a0: number of letters
#	input $a1: address of state
##
printState:
	li	$v0, 1		# print number
	syscall
	la	$a0, strList
	li	$v0, 4
	syscall
	
	move	$a0, $a1
	syscall
	
	j	printLn

##
#	void print3x3Word(String word):
#		prints 9 letter string in 3x3 square
##
#	input $a0: 9 letter string to print
##
print3x3Word:
	li	$t0, 3		# 3 lines
	move	$t1, $a0
print3x3Loop:
	li	$v0, 11		# printing chars
	li	$a0, 9		# char for tab
	syscall
	
	lb	$a0, 0($t1)	# next char
	subi	$a0, $a0, 32	# in upper case
	syscall
	addi	$t1, $t1, 1
	
	li	$a0, 32		# char for space between chars
	syscall
	
	lb	$a0, 0($t1)	# next char
	subi	$a0, $a0, 32
	syscall
	addi	$t1, $t1, 1
	
	li	$a0, 32		# another space
	syscall
	
	lb	$a0, 0($t1)	# print char
	subi	$a0, $a0, 32
	syscall
	addi	$t1, $t1, 1
	
	li	$a0, 10		# newline between rows
	syscall
	
	subi	$t0, $t0, 1	# 3 rows to print
	beqz	$t0, print3x3Finish
	j	print3x3Loop
print3x3Finish:	
	jr	$ra

##
#	void printTimeLose(): game over (time ran out)
##
printTimeLose:
	la	$a0, strOver
	li	$v0, 4
	syscall
	jr	$ra

##
#	void printResignLose(): game over (resigned)
##
printResignLose:
	la	$a0, strRes
	li	$v0, 4
	syscall
	jr	$ra

##
#	void printGood(int moreTime, int moreScore):
#		display increase in time(seconds) and score
##			
#	input $a0: how much time was added in milliseconds
#	input $a1: how much score was added
##
printGood:
	move	$t0, $a0	# store in temp
	move	$t1, $a1
	la	$a0, strGood
	li	$v0, 4
	syscall
	div	$a0, $t0, 1000	# convert to seconds
	li	$v0, 1		# time that was added
	syscall
	la	$a0, strGoo2
	li	$v0, 4
	syscall
	move	$a0, $t1	# score that was added
	li	$v0, 1
	syscall
	j	printLn

##
#	void printLeftover(String[] missingWords, int finalScore):
#		prints remaining words and final score
##
# 	input $a0: leftover words
# 	input $a1: final score
##
printLeftover:
	move	$t0, $a0	# store in temp
	move	$t1, $a1
	la	$a0, strLeft
	li	$v0, 4
	syscall
	move	$a0, $t0
	syscall
	li	$v0, 11
	li	$a0, 10
	syscall
	la	$a0, strScor
	li	$v0, 4
	syscall
	move	$a0, $t1
	li	$v0, 1
	syscall
	j	printLn

##
#	void printNewHigh(): notification of new high score
##
printNewHigh:
	la	$a0, strNHi
	li	$v0, 4
	syscall
	la	$a0, strWho
	syscall
	jr	$ra

##
#	void getWho(String holder): gets name of high score holder	
## 
#	input a0: address to store name
##
getWho:
	li	$v0, 8
	li	$a1, 16		# 15 char + null
	syscall
	j	printLn
