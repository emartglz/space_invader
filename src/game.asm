%include "video.mac"
%include "keyboard.mac"
%include "map.mac"
%include "move.mac"

;%include "presentation.asm"
;%include "keyboard.asm"


section .bss
map resb 8000
ship resd 2
alien resd 2
shot resd 2
wallpaper resd 2
drawables resd 100
timer_alien resd 2
timer_shot resd 2


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

;%1 tecla, %2 macro that move, %3object to move
%macro bind_move 3
  cmp byte [esp], %1
  jne %%next
  %2 %3
  %%next:
%endmacro

%macro bind_shot 1
  cmp byte [esp], %1
  jne %%next
  push dword 1
  push ship
  call create_shot
  add esp, 8
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

  ;mov [drawables], dword 0
  mov [drawables], dword wallpaper
  mov [drawables + 4], dword ship
  mov [drawables + 8], dword alien
  mov [drawables + 12], dword shot
  ;mov [drawables + 12], dword paint_ship

  mov [wallpaper], dword fill_map

  mov [alien], dword paint_alien
  mov [alien + 4], word 0b000_0010_0000_0110
  mov [alien + 6], byte 0
  mov [alien + 7], byte 1

  mov [ship], dword paint_ship
  mov [ship + 4], word 0b0000_0010_0000_0000

  mov [shot], dword paint_shot
  mov [shot + 6], byte 1   ;bool for crashed

  ; Snakasm main loop
  game.loop:

    .input:
      call get_input

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx

      push dword 25
      push timer_shot
      call delay
      add esp, 8
      cmp eax, 0
      jne move_shot
      move_shot_ret:


      push dword 50
      push timer_alien
      call delay
      add esp, 8

      cmp eax, 0
      jne move_alien
      move_alien_ret:

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


move_shot:
  cmp byte [shot + 6], 1
  je finish
  cmp byte [shot + 7], 1
  jne alien_shot
  cmp byte [shot + 4], 0
  je it_crashed
  MOVE_UP shot
  jmp finish

  alien_shot:
  cmp byte [shot + 4], 24
  je it_crashed
  MOVE_DOWN shot
  jmp finish

  it_crashed:
  mov byte [shot + 6], 1

  finish:
  xor eax, eax
  jmp move_shot_ret
  ret

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
  xor eax, eax
  jmp move_alien_ret
  ret
  
  jump_change_direction:
  CHANGE_DIRECTION alien
  jmp jump

  jump_move_right:
  MOVE_RIGHT alien
  jmp ciclo2

  jump_move_left:
  MOVE_LEFT alien
  jmp ciclo2


;esp + 4 memory direction of the ship that shot
;esp + 8 direction of the shot (1 up, 0 down)
create_shot:
  mov eax, [esp + 4]
  mov ecx, [esp + 8]
  cmp byte [shot + 6], 1
  jne .end
  mov bx, [eax + 4]
  mov [shot + 4], bx
  mov [shot + 6], byte 0
  mov [shot + 7], cl

  .end:
  ret




get_input:
    call scan
    ;stosb
    push ax
    ; The value of the input is on 'word [esp]'
    ; Your bindings here

    bind_move KEY.UP, MOVE_UP, ship
    bind_move KEY.DOWN, MOVE_DOWN, ship
    bind_move KEY.RIGHT, MOVE_RIGHT, ship
    bind_move KEY.LEFT, MOVE_LEFT, ship

    bind_shot KEY.Spc

    add esp, 2 ; free the stack

    ret
