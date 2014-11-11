.data
testword: .asciiz "acclimate"
printword: .asciiz "@@@@@@@@@" #use this to generate a random number stored in $a0 btween 0 and 8

.text
la $a2,testword
la $a3,printword
li $t4,0

prodceRandom:
li $a1, 9
li $v0, 42
syscall


move $t3, $a3
add $t3,$t3,$a0

lb $t1, 0($t3)
beq $t1,64,printLetter 
j prodceRandom


printLetter:
addi $t4,$t4,1
sb $a0,0($t3)

add $t2,$a2,$a0
lb $t1,0($t2)
li $v0,11
move $a0,$t1
syscall
beq $t4,3,printline
beq $t4,6,printline
beq $t4,9 end
j prodceRandom


printline:
li $v0,11
li $a0,10
syscall
j prodceRandom


end:
li $v0,10
syscall


