# maze

# array size 15 * 15
# index 0 ~ 14
.data
mdArray:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

arrSize:	.word 15

NEW_LINE: 	.asciiz "\n"

# Each data size
.eqv	DATA_SIZE     4

.eqv	ARRSIZE		15

# screen size
.eqv 	SCREEN_WIDTH	64
.eqv 	SCREEN_HEIGHT 	64

# each dot is using 4 so 64/4 = 16
.eqv	PIXEL_WIDTH	16
.eqv	PIXEL_HEIGHT	16

# Maze start
.eqv	MAZE_START_X	1
.eqv	MAZE_START_Y	0

# Maze Goal
.eqv	MAZE_GOAL_X	13
.eqv	MAZE_GOAL_Y	14

# start
.eqv	START_X	0
.eqv	START_Y 0

# colors
.eqv	RED 	0x00FF0000
.eqv	GREEN 	0x0000FF00
.eqv	BLUE 	0x000000FF
.eqv	WHITE 	0x00FFFFFF
.eqv	YELLOW 	0x00FFFF00
.eqv	CYAN 	0x0000FFFF
.eqv	MAGENTA 0x00FF00FF


.text
main:
	# set up starting position
	addi 	$a0, $0, START_X    	# a0 = X = zero index
	sra 	$a0, $a0, 1
	addi 	$a1, $0, START_Y   	# a1 = Y = zero index
	sra 	$a1, $a1, 1
	addi 	$a2, $0, WHITE  	# a2 = color
	
loop1:
	beq	$a0, PIXEL_WIDTH, check_Y	# if x location is 16, check if y is also 16
	beq	$a1, PIXEL_HEIGHT, next		# if only y at 16, reset x location and draw next
	jal	draw_pixel			#
	addi	$a0, $a0, 1			# x++
	j	loop1				# keep looping until x = 16


check_Y:
	beq	$a1, PIXEL_HEIGHT, next
	move	$a0, $zero
	addi	$a1, $a1, 1
	j	loop1
	
next:
	li	$s0, 0		# i = 0
	li	$s1, 250	# i < 250
	
loop2:
	addi	$s0, $s0, 1
	beq	$s0, $s1, maze_process
	j	loop2
	
maze_process:
	# TEST 1 #
	la	$a0, mdArray
	lw	$a1, arrSize
	jal	generate_maze_outer_moat
	# TEST 2 #
	la	$a0, mdArray
	lw	$a1, arrSize
	jal	generate_maze_street
	# TEST 3 #
	la	$a0, mdArray
	lw	$a1, arrSize
	jal	draw_maze
	# TEST 4 #
	j	user_location
	

exit:
	#
	# move	$a0, $v0
	# li	$v0, 1
	# syscall
	li	$v0, 10
	syscall







#################################################
# subroutine to draw a pixel
# $a0 = X
# $a1 = Y
# $a2 = color
draw_pixel:
	# pixel address = $gp + 4*(x + y*width)
	mul	$t9, $a1, PIXEL_WIDTH   # y * WIDTH
	add	$t9, $t9, $a0	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	jr 	$ra
	


#################################################
# draw_maze 
# $a0 = array address
# $a1 = array size
draw_maze:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$s0, 0			# return value
	li	$t0, 0			# t0 as index i
	li	$t1, 0			# t1 as index j
draw_Loop1:
	blt	$t1, $a1, draw_Loop2	# if (int j=0; j < 15; j++)
	move	$v0, $s0		# reutrn value
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
draw_Loop2:
	# Define the 2D index address #
	mul	$t2, $t1, $a1		# t1 = rowIndex * colSize
	add	$t2, $t2, $t0		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	# get element of arr index and save to $t3 #
	lw	$t3, 0($t2)
	# Draw blue pixel if element equals to 1
	move	$t5, $a0		# temporary save array address
	move	$t6, $a1		# temporary save array address		
	beq	$t3, $zero, skip	
	add 	$a0, $0, $t0    	# a0 = x-coordinate
	add 	$a1, $0, $t1   		# a1 = y-coordinate
	addi 	$a2, $0, BLUE  		# a2 = color
	jal	draw_pixel			
							
skip:											
	move	$a0, $t5		# reset
	move	$a1, $t6		# reset
	add	$s0, $s0, $t3		# sum = sum + mdArray[i][j]
	
	addi	$t0, $t0, 1		# i++
	blt	$t0, $a1, draw_Loop2	# if (i < 15) --> loop again
	addi	$t1, $t1, 1		# j++
	move	$t0, $zero		# reset i = 0
	move	$t5, $a0
	li	$v0, 4
	la	$a0, NEW_LINE
	syscall
	move	$a0, $t5		# reset
	j	draw_Loop1
		
	
	


#################################################
# Generate maze outer moat
# $a0 = array address
# $a1 = array size
# 
generate_maze_outer_moat:
# top/buttom outer moat
top_btm:
	li	$t0, 0		# index x = 0
	li	$s0, 0		# top y 
	li	$s1, 14		# btm y
	li	$t4, 1
t_b_loop: 				# for(x=0; x<max_x; x++)
	# Define the 2D index address #
	# top
	mul	$t2, $s0, $a1		# t1 = rowIndex * colSize
	add	$t2, $t2, $t0		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	sw	$t4, 0($t2)		# store 1 into the wall
	# bottom
	mul	$t2, $s1, $a1		# t1 = rowIndex * colSize
	add	$t2, $t2, $t0		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	sw	$t4, 0($t2)		# store 1 into the wall
	addi	$t0, $t0, 1		# i++
	bne	$t0, $a1, t_b_loop	# keep looping until x = 15
# left/right outer moat
left_right:
	# $s0 is used as left x and $s1 is used as right x
	move	$t0, $zero		# j = 0
l_r_loop:
	# Define the 2D index address #
	# left
	mul	$t2, $t0, $a1		# t1 = rowIndex * colSize
	add	$t2, $t2, $s0		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	sw	$t4, 0($t2)		# store 1 into the wall
	# right
	mul	$t2, $t0, $a1		# t1 = rowIndex * colSize
	add	$t2, $t2, $s1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	sw	$t4, 0($t2)		# store 1 into the wall
	
	addi	$t0, $t0, 1		# j++
	bne	$t0, $a1, l_r_loop	# keep looping until x = 15
	
	jr	$ra


#################################################
# Generate maze street
# $a0 = array address
# $a1 = array size
generate_maze_street:
	li	$t0, 2			# j = 2
	li	$t1, 2			# i = 2
	li	$s0, 14			# arrSize - 1 = max_y = max_x
	li	$s1, 1			# wall or prop
	li	$s3, 3
	li	$s4, 6
	li	$s5, 9
	
maze_st_loop1:				# for(y=4; y<max_y-1; y+2)
	beq	$t0, $s0, check_x_location
	j	maze_st_loop2
	
check_x_location:
	beq	$t1, $s0, end_maze_st_loop

maze_st_loop2:				# for(x=2; x<max_x-1; x+2)
	# Drop a prop for the wall
	mul	$t2, $t0, $a1		# t2 = rowIndex * colSize
	add	$t2, $t2, $t1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	sw	$s1, 0($t2)		# store 1 into the wall
	
	# Generate random integer between range 1 ~ 12
	li	$t9, 0			# RANDOM INT value
	move	$t5, $a0		# save $a0 temporary
	move	$t6, $a1		# save $a1 temporary
	li	$v0, 42 		# syscall 42 = generate random int
	li 	$a1, 11 		# $a1 = upper bound
	syscall     			# $a0 = reutrn value
	addi 	$t9, $a0, 1		# random int + 1 
	move	$a0, $t5		# reset
	move	$a1, $t6		# reset
	
	
	# Case 1: 1  <= random int  <= 3
	sle   	$t7, $t9, $s3
	bne	$t7, $zero, case1
	# Case 2: 4  <= random int  <= 6
	sle	$t7, $t9, $s4
	bne	$t7, $zero, case2
	# Case 3: 7  <= random int  <= 9
	sle	$t7, $t9, $s5
	bne	$t7, $zero, case3
	# Case 4: 10 <= random int  <= 12
	j	case4
	

case1:
	# get element at array[x][y-1]
	addi	$t0, $t0, -1
	mul	$t2, $t0, $a1		# t2 = rowIndex * colSize
	add	$t2, $t2, $t1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	lw	$t3, 0($t2)		# get the element
	addi	$t0, $t0, 1		# reset
	bne	$t3, $zero, reverse_x_index_by_two
	sw	$s1, 0($t2)
	j	next_x_index

case2:
	# get element at array[x][y+1]
	addi	$t0, $t0, 1
	mul	$t2, $t0, $a1		# t2 = rowIndex * colSize
	add	$t2, $t2, $t1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	lw	$t3, 0($t2)		# store 1 into the wall
	addi	$t0, $t0, -1		# reset
	bne	$t3, $zero, reverse_x_index_by_two
	sw	$s1, 0($t2)
	j	next_x_index

case3:
	# get element at array[x-1][y]
	addi	$t1, $t1, -1
	mul	$t2, $t0, $a1		# t2 = rowIndex * colSize
	add	$t2, $t2, $t1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	lw	$t3, 0($t2)		# store 1 into the wall
	addi	$t1, $t1, 1		# reset
	bne	$t3, $zero, reverse_x_index_by_two
	sw	$s1, 0($t2)
	j	next_x_index

case4:
	# get element at array[x+1][y]
	addi	$t1, $t1, 1
	mul	$t2, $t0, $a1		# t2 = rowIndex * colSize
	add	$t2, $t2, $t1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	lw	$t3, 0($t2)		# store 1 into the wall
	addi	$t1, $t1, -1		# reset
	bne	$t3, $zero, reverse_x_index_by_two
	sw	$s1, 0($t2)
	j	next_x_index

reverse_x_index_by_two:
	addi	$t1, $t1, -2
	#j	maze_st_loop2

next_x_index:
	# if
	addi	$t1, $t1, 2		# i + 2
	beq	$t1, $s0, check_y_location	# if (i == 14) -> check y and move or exit function
	j	maze_st_loop2
	


check_y_location:
	addi	$t0, $t0, 2		# j + 2
	li	$t1, 2			# reset i = 2
	beq	$t0, $s0, end_maze_st_loop
	j	maze_st_loop1
	
end_maze_st_loop:
	# call to set start and goal point
	# start
	li	$t1, MAZE_START_X	# x
	li	$t0, MAZE_START_Y	# y
	mul	$t2, $t0, $a1		# t2 = rowIndex * colSize
	add	$t2, $t2, $t1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	sw	$zero, 0($t2)		# make a hole
	# goal
	li	$t1, MAZE_GOAL_X	# x
	li	$t0, MAZE_GOAL_Y	# y
	mul	$t2, $t0, $a1		# t2 = rowIndex * colSize
	add	$t2, $t2, $t1		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $a0		# add base address
	sw	$zero, 0($t2)		# make a hole
	
	jr	$ra
	


#########################################
# Show Current location of the user
#
user_location:
	# set up starting position
	addi	$a0, $zero, 1		# column = 1
	addi	$a1, $zero, 0		# row = 0
	addi 	$a2, $0, RED  		# a2 = red (ox00RRGGBB)
	lw	$s6, arrSize		# colSize	
	la	$s7, mdArray		# array base address
loop_user_location:
	jal 	draw_pixel
	
	# check for input
	lw $t0, 0xffff0000  #t1 holds if input available
    	beq $t0, 0, loop_user_location   #If no input, keep displaying
	
	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit	# input space
	beq	$s1, 119, up 	# input w
	beq	$s1, 115, down 	# input s
	beq	$s1, 97, left  	# input a
	beq	$s1, 100, right	# input d
	# invalid input, ignore
	j	loop_user_location

# process valid input	
up:
	# Check if you are allowed to go to that location
	beq	$a1, $zero, skip_move_up
	addi	$t4, $a1, -1			# y-1 as "up"
	#beq	$t4, $t3, skip_move_up	# if y == 0, no change
	# check if next move is a wall or path
	# get element at array[x][y-1]
	mul	$t2, $t4, $s6		# t2 = rowIndex * colSize
	add	$t2, $t2, $a0		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $s7		# add base address
	lw	$t3, 0($t2)		# get the elment
	bne	$t3, $zero, skip_move_up	# if element not zero, skip and reset
	#
	li	$a2, 0		# black out the pixel
	jal	draw_pixel
	addi	$a1, $a1, -1
	addi 	$a2, $0, RED
	jal	draw_pixel
skip_move_up:
	j	loop_user_location
	

down:
	addi	$t4, $a1, 1			# y+1 as "down"
	li	$t5, 13
	li	$t6, 15
	# check if next move is a wall or path
	# get element at array[x][y+1]
	mul	$t2, $t4, $s6		# t2 = rowIndex * colSize
	add	$t2, $t2, $a0		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $s7		# add base address
	lw	$t3, 0($t2)		# get the elment
	bne	$t3, $zero, skip_move_down	# if element not zero, skip and reset
	##
	li	$a2, 0		# black out the pixel
	jal	draw_pixel
	addi	$a1, $a1, 1
	addi 	$a2, $0, RED
	jal	draw_pixel
	# Check If User Reached Goal
	# Goal coordinate : x = 14, y = 16
	bne	$a0, $t5, skip_move_down
	beq	$a1, $t6, goal_reached
skip_move_down:
	j	loop_user_location
	
	
left:	
	addi	$t4, $a0, -1			# x-1 as "left"
	#beq	$t4, $t3, skip_move_up	# if y == 0, no change
	# check if next move is a wall or path
	# get element at array[x-1][y]
	mul	$t2, $a1, $s6		# t2 = rowIndex * colSize
	add	$t2, $t2, $t4		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $s7		# add base address
	lw	$t3, 0($t2)		# get the elment
	bne	$t3, $zero, skip_move_left	# if element not zero, skip and reset
	li	$a2, 0		# black out the pixel
	jal	draw_pixel
	addi	$a0, $a0, -1
	addi 	$a2, $0, RED
	jal	draw_pixel
skip_move_left:
	j	loop_user_location
	
right:	
	addi	$t4, $a0, 1			# x1 as "right"
	#beq	$t4, $t3, skip_move_up	# if y == 0, no change
	# check if next move is a wall or path
	# get element at array[x+1][y]
	mul	$t2, $a1, $s6		# t2 = rowIndex * colSize
	add	$t2, $t2, $t4		# 			 + colIndex
	mul	$t2, $t2, DATA_SIZE	# multiply by the data size
	add	$t2, $t2, $s7		# add base address
	lw	$t3, 0($t2)		# get the elment
	bne	$t3, $zero, skip_move_right	# if element not zero, skip and reset
	li	$a2, 0		# black out the pixel
	jal	draw_pixel
	addi	$a0, $a0, 1
	addi 	$a2, $0, RED
	jal	draw_pixel
skip_move_right:
	j	loop_user_location



##############################################
goal_reached:
	# Show message
	# Board
	li	$a0, 0	# x
	li	$a1, 0	# y
	addi 	$a2, $0, YELLOW
	li	$s0, 256	# stop
#loop_board1:
#	beq	$a0, $s0, exit
loop_board2:
	jal	draw_pixel
	addi	$a0, $a0, 1	#i++
	beq	$a0, $s0, completed_board
	j	loop_board2

#check_board_y:
#	addi	$a1, $a1, 1	#j++
#	j	loop_board1


completed_board:
	## GOAL! ##
	
	# G
	li	$a0, 1	#x
	li	$a1, 2	#y
	addi 	$a2, $0, RED
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	li	$a0, 1	# reset
	
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel

	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	
	
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	
	addi	$a0, $a0, -1
	jal	draw_pixel
	
	
	# O
	li	$a0, 8	#x
	li	$a1, 2	#y
	
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	
	
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	
	addi	$a0, $a0, -1
	jal	draw_pixel
	addi	$a0, $a0, -1
	jal	draw_pixel
	addi	$a0, $a0, -1
	jal	draw_pixel
	
	
	# A
	li	$a0, 1	#x
	li	$a1, 10	#y
	
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	
	addi	$a0, $a0, 3
	
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	addi	$a1, $a1, -1
	jal	draw_pixel
	
	addi	$a0, $a0, -1
	jal	draw_pixel
	addi	$a0, $a0, -1
	jal	draw_pixel
	addi	$a0, $a0, -1
	jal	draw_pixel
	
	addi	$a1, $a1, 2
	
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	
	# L
	li	$a0, 8	#x
	li	$a1, 10	#y
	
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	
	
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	addi	$a0, $a0, 1
	jal	draw_pixel
	
	
	# !
	li	$a0, 14	#x
	li	$a1, 10	#y
	
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 1
	jal	draw_pixel
	addi	$a1, $a1, 2
	jal	draw_pixel
	
	j	exit
