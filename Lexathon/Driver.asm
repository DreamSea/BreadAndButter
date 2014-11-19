.data
infoSt:	.asciiz	"(N)ew game\n"
infoQu:	.asciiz	"(Q)uit\n"
infoCmd:.asciiz "Command: "
strTime:.asciiz	"Time Left (s):"
_nl:	.asciiz	"\n"
inBuff:	.space	10
testStr:.asciiz	"gg\n\ngg\n\nlgg\n\nggSUPERLONGONELINESUPERLONGONELINESUPERLONGONELINESUPERLONGONELINESUPERLONGONELINE"
.text
main:
start:
	## start menu
	li	$v0, 4
	la	$a0, infoSt
	syscall
	la	$a0, infoQu
	syscall
	la	$a0, infoCmd
	syscall
	
	## read command
	li	$v0, 12
	syscall
	
	li	$v0, 54
	la	$a0, testStr
	la	$a1, inBuff
	la	$a2, 10
	syscall
	
quit:
	li	$v0, 10
	syscall