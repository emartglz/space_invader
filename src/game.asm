%include "video.mac"
%include "keyboard.mac"
%include "map.mac"

%include "presentation.asm"
;%include "keyboard.asm"

section .bss
tecla resb 1
map resb 8000
ship resw 1
ship_map resw 1
drawables resd 100

section .text

extern clear
extern putc
extern scan
extern calibrate


; Bind a key to a procedure
%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  %%next:
%endmacro

; Fill the screen with the given background color
%macro FILL_SCREEN 1
  push word %1
  call clear
  add esp, 2
%endmacro

global game
game:
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx

  ;push map
  ;push dword 0
  ;call fill_map
  ;add esp, 8
  
  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

  mov [drawables], dword 0
  mov [drawables + 4], dword fill_map
  mov [drawables + 8], dword ship
  mov [drawables + 12], dword paint_ship
  
  mov [ship], word 0b0000_0010_0000_0000

  ; Snakasm main loop
  game.loop:
    
    .input:
      call get_input

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx

      REFRESH_MAP map, drawables, 16

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

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx
      
    ; Main loop.

    ; Here is where you will place your game logic.
    ; Develop procedures like paint_map and update_content,
    ; declare it extern and use here.

    jmp game.loop

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

draw.red:
  FILL_SCREEN BG.RED
  ret


draw.green:
  FILL_SCREEN BG.GREEN
  ret


get_input:
    call scan
    mov edi, tecla
    stosb
    push ax
    ; The value of the input is on 'word [esp]'
    ; Your bindings here

    bind KEY.UP, move_up
    bind KEY.DOWN, move_down
    bind KEY.RIGHT, move_right
    bind KEY.LEFT, move_left
    
    add esp, 2 ; free the stack

    ret
