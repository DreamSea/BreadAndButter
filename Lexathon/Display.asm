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
strWho:	.asciiz "Input name (4 letters): "
strList:.asciiz " letters: "
strGood:.asciiz "Word Found, Seconds +"
strGoo2:.asciiz ", Score +"
strLeft:.asciiz "Words Left: "
_tab:	.asciiz	"\t"
_gap:	.asciiz "  "
_nl:	.asciiz	"\n"

inBuff:	.space	10
.text

## prints newline
printLn:
	li	$v0, 4
	la	$a0, _nl
	syscall
	jr	$ra

## title menu
printTitleInfo:
	li	$v0, 4
	la	$a0, infoSt
	syscall
	la	$a0, infoRs
	syscall
	la	$a0, infoQu
	syscall
	jr	$ra

## current highscore
# a0 - highscore
# a1 - address of highscorer
printHighscore:
	move	$t0, $a0
	move	$t1, $a1
	li	$v0, 4
	la	$a0, infoHi
	syscall
	move	$a0, $t0
	li	$v0, 1
	syscall
	la	$a0, infoBy
	li	$v0, 4
	syscall
	move	$a0, $t1
	syscall
	li	$a0, 10
	li	$v0, 11
	syscall
	jr	$ra

## read user choice (one character)
# returns v0: user choice
getUserChar:
	li	$v0, 4
	la	$a0, strCmd
	syscall
	li	$v0, 12
	syscall
	move	$t0, $v0	# temp save read info
	li	$v0, 4
	la	$a0, _nl	
	syscall
	syscall
	move	$v0, $t0
	jr	$ra

## prints time in seconds
# input a0: time in milli to print		
printTime:
	div	$t0, $a0, 1000
	li	$v0, 4
	la	$a0, strTime
	syscall
	move	$a0, $t0
	li	$v0, 1
	syscall
	li	$v0, 4
	la	$a0, _nl
	syscall
	jr	$ra
# input a0: score to print
# input a1: score to beat
printScore:
	move	$t0, $a0
	move	$t1, $a1
	la	$a0, strScor
	li	$v0, 4
	syscall
	move	$a0, $t0
	li	$v0, 1
	syscall
	li	$v0, 4
	la	$a0, _nl
	syscall
	la	$a0, strBeat
	li	$v0, 4
	syscall
	move	$a0, $t1
	li	$v0, 1
	syscall
	li	$v0, 4
	la	$a0, _nl
	syscall
	
	jr	$ra
	

## title menu
printReadyInfo:
	li	$v0, 4
	la	$a0, infoRd
	syscall
	la	$a0, infoBa
	syscall
	jr	$ra
	
## read user choice (10 letter guess)
# returns v0: user choice
getUserString:
	li	$v0, 4		# guess prompt
	la	$a0, strGues	# take user string, 9 char max
	syscall
	li	$v0, 8
	la	$a0, inBuff
	li	$a1, 10
	syscall
	li	$v0, 4
	la	$a0, _nl	
	syscall
	syscall
	la	$v0, inBuff
	jr	$ra

## for printing state of guessed words
# input $a0: number of letters
# input $a1: address of state
printState:
	li	$v0, 1		# print number
	syscall
	la	$a0, strList
	li	$v0, 4
	syscall
	
	move	$a0, $a1
	syscall
	
	la	$a0, _nl
	syscall
	jr	$ra

## prints 9 letter string in 3x3 square
# input $a0: 9 letter string to print
print3x3Word:
	li	$t0, 3		# 3 lines
	move	$t1, $a0
print3x3Loop:
	la	$a0, _tab	# first tab
	li	$v0, 4
	syscall
	
	lb	$a0, 0($t1)	# print char
	li	$v0, 11
	syscall
	addi	$t1, $t1, 1
	
	la	$a0, _gap	# print space between char
	li	$v0, 4
	syscall
	
	lb	$a0, 0($t1)	# print char
	li	$v0, 11
	syscall
	addi	$t1, $t1, 1
	
	la	$a0, _gap	# print space between char
	li	$v0, 4
	syscall
	
	lb	$a0, 0($t1)	# print char
	li	$v0, 11
	syscall
	addi	$t1, $t1, 1
	
	la	$a0, _nl	# newline between rows
	li	$v0, 4
	syscall
	
	subi	$t0, $t0, 1
	beqz	$t0, print3x3Finish
	j	print3x3Loop
print3x3Finish:	
	jr	$ra

## game over (time ran out)
printTimeLose:
	la	$a0, strOver
	li	$v0, 4
	syscall
	jr	$ra

## game over (resigned)
printResignLose:
	la	$a0, strRes
	li	$v0, 4
	syscall
	jr	$ra
			
## print string for +time
# input $a0: how much time was added
# input $a1: how much score was added
printGood:
	move	$t0, $a0
	move	$t1, $a1
	la	$a0, strGood
	li	$v0, 4
	syscall
	div	$a0, $t0, 1000
	li	$v0, 1
	syscall
	la	$a0, strGoo2
	li	$v0, 4
	syscall
	move	$a0, $t1
	li	$v0, 1
	syscall
	
	la	$a0, _nl
	li	$v0, 4
	syscall
	jr	$ra

## prints leftover words
# input $a0: leftover words
# input $a1: final score
printLeftover:
	move	$t0, $a0
	move	$t1, $a1
	la	$a0, strLeft
	li	$v0, 4
	syscall
	move	$a0, $t0
	syscall
	la	$a0, _nl
	syscall
	la	$a0, strScor
	li	$v0, 4
	syscall
	move	$a0, $t1
	li	$v0, 1
	syscall
	li	$v0, 4
	la	$a0, _nl
	syscall
	jr	$ra

printNewHigh:
	la	$a0, strNHi
	li	$v0, 4
	syscall
	la	$a0, strWho
	syscall
	jr	$ra
	
# a0: address to store name
getWho:
	li	$v0, 8
	li	$a1, 5
	syscall
	li	$v0, 11
	li	$a0, 10
	syscall
	jr	$ra