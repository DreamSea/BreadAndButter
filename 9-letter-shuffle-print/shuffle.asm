 #change the value in line 18 and 88 to channge the space in front of each line
 #change the value in line 72 to change the space between letters
.data
testword: .asciiz "acclimate"
printword: .asciiz "@@@@@@@@@" #use this to generate a random number stored in $a0 btween 0 and 8

.text
la $a0,testword
jal shuffle

li $v0,10
syscall

shuffle:
move $t7,$a0
la $a3,printword
li $t4,0
li $t5,10            #control the number of space of first letter
shufflespace4:
li $v0,11
li $a0,32
syscall
subi $t5,$t5,1
beq $t5,0,shufflecontinue4
j shufflespace4

shufflecontinue4:

prodceRandom:
li $a1, 9   #product random n from 0 to 8
li $v0, 42
syscall
beq $a0,4,prodceRandom  #if random=4, middle number, re-produce random number 
move $t3, $a3        #t3 is the address of printword
add $t3,$t3,$a0      # to get the nth letter of printword
lb $t1, 0($t3)       #read nth letter of printword
beq $t1,64,printLetter   #if nth letter =@, go to printLetter
j prodceRandom


printLetter:
addi $t4,$t4,1            #counter of prints
beq $t4,5,printCenter      # if counter=5, print the center letter
sb $a0,0($t3)              #store the random on printword

add $t2,$t7,$a0            
lb $t1,0($t2)                   #load the nth letter of testword
li $v0,11   
move $a0,$t1                   
syscall                         #print the nth letter 
li $t5,5

shufflespace1:
li $v0,11
li $a0,32
syscall
subi $t5,$t5,1
beq $t5,0,shufflecontinue1
j shufflespace1

shufflecontinue1:
beq $t4,3,printline             #counter=3, change line
beq $t4,6,printline            #counter=6, change line
beq $t4,9 shuffleend                  #counter =9, end shuffle program
j prodceRandom

printCenter:
lb $t1,4($t7)        #print center letter
li $v0,11
move $a0,$t1
syscall
li $t5,5                       #control the number of spaces between letters
shufflespace2:
li $v0,11
li $a0,32
syscall
subi $t5,$t5,1
beq $t5,0,shufflecontinue2
j shufflespace2


shufflecontinue2:
j prodceRandom
printline:
li $v0,11
li $a0,10
syscall
li $t5,10                   #control the number of space of 2nd and 3rd line
shufflespace3:
li $v0,11
li $a0,32
syscall
subi $t5,$t5,1
beq $t5,0,shufflecontinue3
j shufflespace3

shufflecontinue3:
j prodceRandom

shuffleend:
jr $ra



