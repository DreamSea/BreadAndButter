.globl	printTitleInfo getUserChar printLn printTime
.globl	printReadyInfo getUserString print3x3Word
.globl	printGameOver
.data
infoSt:	.asciiz	"(n)ew game\n"
infoQu:	.asciiz	"(q)uit\n"
infoRd:	.asciiz "(r)eady\n"
infoBa:	.asciiz "(b)ack\n"
strCmd:	.asciiz "Command: "
strTime:.asciiz	"Time Left (s): "
strGues:.asciiz "Guess: "
strOver:.asciiz "Time is up.\n"
_tab:	.asciiz	"\t"
#_left:	.asciiz " ["
#_right:	.asciiz	"] "
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
	la	$a0, infoQu
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
	move	$t0, $v0	# temp save read info
	li	$v0, 4
	la	$a0, _nl	
	syscall
	syscall
	move	$v0, $t0
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
printGameOver:
	la	$a0, strOver
	li	$v0, 4
	syscall
	jr	$ra