%include "video.mac"
%include "keyboard.mac"
%include "map.mac"
%include "move.mac"

%include "presentation.asm"
<<<<<<< HEAD
=======
;%include "keyboard.asm"
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192

section .bss
map resb 8000
ship resd 2
alien resd 2
wallpaper resd 2
drawables resd 100
timer_alien resd 2

section .text

extern clear
extern putc
extern scan
extern calibrate
extern delay


; Bind a key to a procedure
%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  %%next:
%endmacro

<<<<<<< HEAD
=======
;%1 tecla, %2 macro that move, %3object to move
%macro bind_move 3
  cmp byte [esp], %1
  jne %%next
  %2 %3
  %%next:
%endmacro

>>>>>>> c400b1afba87286e57ec0e9701041f017041c192
; Fill the screen with the given background color
%macro FILL_SCREEN 1
  push word %1
  call clear
  add esp, 2
%endmacro

<<<<<<< HEAD







=======
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192
global game
game:
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx

<<<<<<< HEAD

=======
  ;push map
  ;push dword 0
  ;call fill_map
  ;add esp, 8
  
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192
  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

<<<<<<< HEAD
  call fill_map

  mov eax, map
  push eax
  call presentation
  add esp, 4



  ; mov [ship], word 0b0000_0010_0000_0000
  ; mov eax, map + 8
  ; mov [ship_map], eax
  ; mov eax, [ship_map]
  ; ;mov [eax + 1], byte 6
  ; ;mov [eax], byte '#'
=======
  ;mov [drawables], dword 0
  mov [drawables], dword wallpaper
  mov [drawables + 4], dword ship
  mov [drawables + 8], dword alien
  ;mov [drawables + 12], dword paint_ship
  
  mov [wallpaper], dword fill_map

  mov [alien], dword paint_alien
  mov [alien + 4], word 0b000_0010_0000_0110
  mov [alien + 6], byte 0
  mov [alien + 7], byte 1
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192

  mov [ship], dword paint_ship
  mov [ship + 4], word 0b0000_0010_0000_0000

  ; Snakasm main loop
  game.loop:
    
    .input:
      call get_input

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx

<<<<<<< HEAD
      ;call refresh_map
=======

      push dword 50
      push timer_alien
      call delay
      add esp, 8

      cmp eax, 0
      jne move_alien
      move_alien_ret:

      REFRESH_MAP map, drawables, 12

      ;push map
      ;push dword 0
      ;call fill_map
      ;add esp, 8

      ; push map
      ; push ship
      ; call paint_ship
      ; add esp, 8

      ; push map
      ; call paint_map
      ; add esp, 4

      PAINT_MAP map

      ;call draw.green
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx
<<<<<<< HEAD

=======
      
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192
    ; Main loop.

    ; Here is where you will place your game logic.
    ; Develop procedures like paint_map and update_content,
    ; declare it extern and use here.

    jmp game.loop

<<<<<<< HEAD











move_up:
  dec byte [ship]
  cmp byte [ship], 0
  jge move_up.next
  mov [ship], byte 0
  move_up.next:
  ret

move_down:
  inc byte [ship]
  cmp byte [ship], 24
  jle move_down.next
  mov [ship], byte 24
  move_down.next:
  ret

move_left:
  dec byte [ship + 1]
  cmp byte [ship + 1], 2
  jge move_left.next
  mov [ship + 1], byte 2
  move_left.next:
  ret

move_right:
  inc byte [ship + 1]
  cmp byte [ship + 1], 77
  jle move_right.next
  mov [ship + 1], byte 77
  move_right.next:
  ret




refresh_map:
  mov edx, [ship_map]
  ;mov [edx + 1], byte 6
  mov [edx], byte 0
  ;mov [edx - 4 + 1], byte 6
  mov [edx - 4], byte 0
  ;mov [edx -8 + 1], byte 6
  mov [edx - 8], byte 0
  ;mov [edx + 4 + 1], byte 6
  mov [edx + 4], byte 0
  ;mov [edx +8 + 1], byte 6
  mov [edx + 8], byte 0

  mov al, [ship]
  mov bl, 80
  mul bl
  mov cl, byte[ship + 1]
  add eax, ecx
  mov ebx, 4
  mul ebx
  add eax, map
  mov [ship_map], eax
  mov edx, [ship_map]
  mov [edx + 1], byte 5
  mov [edx], byte '_'
  mov [edx - 4 + 1], byte 3
  mov [edx - 4], byte '*'
  mov [edx -8 + 1], byte 7
  mov [edx - 8], byte '('
  mov [edx + 4 + 1], byte 3
  mov [edx + 4], byte '*'
  mov [edx +8 + 1], byte 7
  mov [edx + 8], byte ')'

=======
move_alien:
  cmp byte [alien + 5], 77
  je jump_change_direction
  cmp byte [alien + 5], 2
  je jump_change_direction
  jump:
  cmp byte [alien + 7], 1
  je jump_move_right
  cmp byte [alien + 7], 0
  je jump_move_left
  ciclo2:
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192
  xor eax, eax
  jmp move_alien_ret
  ret
<<<<<<< HEAD



fill_map:
  mov ebx, 0
  mov ah, 0
  mov al, 0

  fill_map.jump:
  mov [map + ebx + 3], al
  mov [map + ebx + 2], ah
  mov [map + ebx + 1], byte 2
  mov [map + ebx], byte 0

  add ebx, 4
  cmp ebx, 8000
  je fill_map.end
  inc al
  cmp al, 80
  je fill_map.incfil
  jmp fill_map.jump

  fill_map.incfil:
  mov al, 0
  inc ah
  cmp ah, 25
  je fill_map.end
  jmp fill_map.jump

  fill_map.end:
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  ret

=======
  
  jump_change_direction:
  CHANGE_DIRECTION alien
  jmp jump

  jump_move_right:
  MOVE_RIGHT alien
  jmp ciclo2

  jump_move_left:
  MOVE_LEFT alien
  jmp ciclo2

draw.red:
  FILL_SCREEN BG.RED
  ret


draw.green:
  FILL_SCREEN BG.GREEN
  ret
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192


get_input:
    call scan
<<<<<<< HEAD
=======
    ;stosb
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192
    push ax
    ; The value of the input is on 'word [esp]'
    ; Your bindings here

<<<<<<< HEAD
    bind KEY.UP, move_up
    bind KEY.DOWN, move_down
    bind KEY.RIGHT, move_right
    bind KEY.LEFT, move_left
=======
    bind_move KEY.UP, MOVE_UP, ship
    bind_move KEY.DOWN, MOVE_DOWN, ship
    bind_move KEY.RIGHT, MOVE_RIGHT, ship
    bind_move KEY.LEFT, MOVE_LEFT, ship
>>>>>>> c400b1afba87286e57ec0e9701041f017041c192
    
    add esp, 2 ; free the stack

    ret
