# maze-game
CS2340 Computer Architecture Bitmap Project

Name: Che Blankenship
April 25th, 2021

1. Idea
I decided to make a maze game using MIPS assembly with a bitmap/keyboard tool.
My purpose in making this game is (1) To review my understanding of basic MIPS
programming by implementing functions, loops, and syscalls. (2) Learn how 2-dimensional
array works in MIPS, and how to access each element dynamically by calling a function.

2. The Implementation
The code is around 650 – 700 ish. Tried to get a shorter line of code by implementing loops and
functions.

3. The logic (list of logics I implemented in this program)
- 2D array manipulation.
    - Generate “outer moat” function
    - Generate “path” function
    - Display maze function
- Game logic
    - Set start and goal coordinate
    - Verify user next move

4. Logic overview.
    a. 2D array manipulation
To generate a maze, I used one of the famous/basic algorithms called “Maze-Bar Algorithm”. To efficiently generate a maze and every time change the maze route, I had to set up a 2D array with same number of row and columns. In addition, it had to be an odd number array (for example, 13x13, 7x7, 25x25, and row=column>=5). I divided the algorithm into two major steps. First, I generated the outer moat, in other words, the wall that's around. Second, I generated the path by using syscall 42 with range from 1<= n <=12. Then I divided it into 4 cases to randomly generate walls inside the maze to make no passages. In the end, I called a function to iterate through the whole 2D array, and display the walls on the bitmap.
    b. Game logic
To dynamically handle which direction the user can go next, I used the location on the bitmap and the 2D array x,y coordinates. The user can only go up, down, left, right; hence, I divide the move cases and see if the next move that the user wants to take is valid by checking the 2D array next moving index element. I set “open path” = 0, and “wall” = 1. So if the next move index element in the array is 1, I set the program not to make the user move. Since the maze generating algorithm is basic logic, I had to manually set the start/goal, and that location is always at the same point. Start=(1,0) and goal=(13,14). When the user successfully reaches this index, x=13, and y=14, then I display a message saying “Goal!” The message is manually hard coded.

5. How to run the program
    1. Open maze.asm on Mars.
    2. Open “Bitmap Display” from “Tools” and click “Connect to MIPS”. Setup the setting as the image.
    	<img src="https://raw.githubusercontent.com/cheblankenshipUTD/maze-game/main/img/settings.png" width="400" height="200">&nbsp;
    3. Open “Keyboard and Display MMIO” from “Tools” and click “Connect to MIPS”.
    	<img src="https://raw.githubusercontent.com/cheblankenshipUTD/maze-game/main/img/maze1.png" width="300" height="300">&nbsp;
    4. Compile the program and start running the program.
    	<img src="https://raw.githubusercontent.com/cheblankenshipUTD/maze-game/main/img/maze2.png" width="300" height="300">&nbsp;
    5. You will see a randomly generated maze. You can see that at the top-left, there is a red pixel that shows your current location. At the right bottom of the maze, you will see the goal.
    6. Use the keyboard w=”up”, s=”down”, a=”left”, and d=”right” to reach the goal. Whenever you successfully move to the next point, the maze will track your path history with black. The image below shows right before it reaches the goal.
    	<img src="https://raw.githubusercontent.com/cheblankenshipUTD/maze-game/main/img/maze3.png" width="300" height="300">&nbsp;
    7. When you exit the maze successfully, you will see this image and the program will finish.


