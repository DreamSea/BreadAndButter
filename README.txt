BreadAndButter
==============

CS 3340 Computer Architecture - Semester Project

Program Features: System Console I/O, Dictionary Generation, Timer, Scoring, Highscore Save/Load/Reset
OS Compatibility: Windows and Mac
Program Limitations:
-> Not sure about Linux
-> There is no 'winning' by guessing all the words. Because nobody wins.
-> Not all games are 'fair'. It is definitely easier to score in some games than others.
-> Smaller word list chosen to speed up game preparations, as such there are 'obvious' words missing

Lexathon Folder should contain files: Creation.asm, Display.asm, Driver.asm, Progress.asm, [WordLists].txt, and possibly zHighscore.txt

[WordLists] are 6 text files containing dictionaries of words with 4-9 letters accordingly.
ex. s4LetterWordList1967.txt with 4 being number of letters in word and 1967 being amount of words in dictionary. 

________User Guide________

To Compile and Run program:
-> Copy Mars4_4.jar file into Lexathon Folder 
-> Run in command-line with command: java -jar Mars4_4.jar 
-> In Mars Settings select 'Assemble all files in directory' and
   'Initialize Program Counter to global 'main' if defined'
-> Open Driver.asm
-> Press button to Build 
-> Press button to Run

During Execution:
--> Timer set to 60seconds per game

--> Main Menu consists of choices (n)ew game, (r)eset highscore, and (q)uit 
  -> Enter Character 'n' to start new game generating dictionary
  -> Enter Character 'r' to reset stored highscore
  -> Enter Character 'q' to quit
--> Begin Menu consists two more choices (r)eady and (b)ack
  -> Enter Character 'r' to start game
  -> Enter Character 'b' to return to main menu
--> Game begins 
  -> User can see each category from 4-9 letter words 
  -> User has to guess based on the 9 letter diagram given 
  -> Guess must contain middle letter in diagram
  -> Guess must be made in lowercase letters
--> User enters a guess
  -> If '?' entered, shuffle word and display again
  -> If '!' entered, give up current game
  -> If guess is correct the category containing the word length
     will show word guess to be correct
      -> Each correct guess will add 10 seconds to Timer
      -> Each correct guess will add points
          ->  (1024 * letter length) + time leftover (in seconds) at guess
  -> If guess is incorrect the game will go on decrementing Timer value
--> Time Up or Resign
  -> User can see the words that they missed
  -> If user has set a highscore, prompt for user's name/handle
  -> Return to Main Menu 
