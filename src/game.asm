%include "video.mac"
%include "keyboard.mac"
%include "map.mac"
%include "move.mac"
%include "shot.mac"

;%include "presentation.asm"
;%include "keyboard.asm"

section .data
ship_shots_amount db 10



section .bss
map resb 8000
ship resd 2
alien resd 90
shots resd 20
; shots: function to paint
; shots+4: row, shots+5:col
; shots + 6: bool for crashed
; shots + 7:direction of movement(1 up, 0 down)
wallpaper resd 2
drawables resd 42
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

;Only to create the shots of the ship
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

  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

;initializing aliens of type 1
  mov ecx, 10
  mov eax, alien
  mov dl, 3
  ciclo:
  mov [eax], dword paint_alien
  mov [eax + 4], byte 3
  mov [eax + 5], dl
  mov [eax + 6], byte 0
  mov [eax + 7], byte 1
  mov [eax + 8], byte 1
  add edx, 8
  add eax, 12
  loop ciclo

  xor edx, edx
  xor eax, eax

;initializing aliens of type 2
  mov ecx, 10
  mov eax, alien
  add eax, 120
  mov dl, 3
  ciclo4:
  mov [eax], dword paint_alien
  mov [eax + 4], byte 5
  mov [eax + 5], dl
  mov [eax + 6], byte 0
  mov [eax + 7], byte 1
  mov [eax + 8], byte 2
  add edx, 8
  add eax, 12
  loop ciclo4

  xor edx, edx
  xor eax, eax

;initializing aliens of type 3
  mov ecx, 10
  mov eax, alien
  add eax, 240
  mov dl, 3
  ciclo5:
  mov [eax], dword paint_alien
  mov [eax + 4], byte 7
  mov [eax + 5], dl
  mov [eax + 6], byte 0
  mov [eax + 7], byte 1
  mov [eax + 8], byte 3
  add edx, 8
  add eax, 12
  loop ciclo5

  xor edx, edx
  xor eax, eax  


;initializing shots
  mov eax, shots
  mov ecx, [ship_shots_amount]
  init_shots:
    mov [eax], dword paint_shot
    mov [eax + 6], byte 1
    add eax, 8
    loop init_shots


  mov [drawables], dword wallpaper
  mov [drawables + 4], dword ship

  ;moving aliens to drawables
  mov ecx, 30
  mov edx, drawables
  add edx, 8
  mov eax, alien
  mov ebx, 0
  ciclo3:
  mov [edx + ebx], dword eax
  add eax, 12
  add ebx, 4
  loop ciclo3

  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx

  ;moving shots to drawables
  mov eax, shots
  mov ebx, drawables
  mov edx, 128
  mov ecx, [ship_shots_amount]
  m_shots:
  mov [ebx + edx], eax
  add eax, 8
  add edx, 4
  loop m_shots


  mov [wallpaper], dword fill_map

  mov [ship], dword paint_ship
  mov [ship + 4], word 0b0011_0010_0001_1000




  ; Main loop
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
      jne move_shots
      move_shots_ret:
      DESTROY_ALIEN alien, shots

      push dword 50
      push timer_alien
      call delay
      add esp, 8

      mov ecx, 30
      mov esi, alien
      cmp eax, 0
      jne move_alien
      move_alien_ret:

      REFRESH_MAP map, drawables, 168

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






move_shots:
  mov eax, shots
  mov ecx, [ship_shots_amount]
  find:
  cmp byte [eax + 6], 0
  jne continue
  push eax
  call move_shot
  add esp, 4
  continue:
  add eax, 8
  loop find
  jmp move_shots_ret


  move_shot:
    mov ebx, [esp + 4]
    cmp byte [ebx + 7], 1
    jne alien_shot
    cmp byte [ebx + 4], 0
    je it_crashed
    MOVE_UP ebx
    jmp finish

    alien_shot:
    cmp byte [ebx + 4], 24
    je it_crashed
    MOVE_DOWN ebx
    jmp finish

    it_crashed:
    mov byte [ebx + 6], 1

    finish:
    xor ebx, ebx
    ret




move_alien:
  cmp byte [esi + 5], 77
  je jump_change_direction
  cmp byte [esi + 5], 2
  je jump_change_direction
  jump:
  cmp byte [esi + 7], 1
  je jump_move_right
  cmp byte [esi + 7], 0
  je jump_move_left

  ciclo2:
  add esi, 12
  loop move_alien
  xor esi, esi
  jmp move_alien_ret
  ret
  
  jump_change_direction:
  CHANGE_DIRECTION esi
  inc byte [esi + 4]
  jmp jump

  jump_move_right:
  MOVE_RIGHT esi
  jmp ciclo2

  jump_move_left:
  MOVE_LEFT esi
  jmp ciclo2








;esp + 4 memory direction of the ship that shot
;esp + 8 direction of the shot (1 up, 0 down)
create_shot:
  mov ecx, [ship_shots_amount]
  mov eax, shots
  find_available_shot:
  cmp byte [eax + 6], 1
  je create
  add eax, 8
  loop find_available_shot
  shot_finished:
  ret

  create:
  mov ebx, [esp + 4]
  mov ecx, [esp + 8]
  mov dx, [ebx + 4]
  mov [eax + 4], dx
  mov [eax + 6], byte 0
  mov [eax + 7], cl
  jmp shot_finished





get_input:
    call scan
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
