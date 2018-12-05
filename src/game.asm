%include "video.mac"
%include "keyboard.mac"
%include "map.mac"
%include "move.mac"
%include "shot.mac"

section .data
ship_shots_amount db 3
alien_shots_amount db 10



section .bss
map resb 8000
ship resd 2
alien resd 90
points resd 2
lives resd 2

living_aliens resd 1

bool_for_random resb 1
random resd 1

; shots: function to paint
; shots+4: row, shots+5:col
; shots + 6: bool for crashed
; shots + 7:direction of movement(1 up, 0 down)
ship_shots resd 6
alien_shots resd 20

wallpaper resd 2
drawables resd 47

timer_alien resd 2
timer_shot resd 2
timer_alien_shooting resd 2




section .text


extern clear
extern putc
extern scan
extern calibrate
extern delay
extern rtcs

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

; ;Only to create the shots of the ship
; %macro bind_shot 1
;   cmp byte [esp], %1
;   jne %%next
;   push ship_shots_amount
;   push ship_shots
;   push dword 1
;   push ship
;   call create_shot
;   add esp, 16
;   %%next:
; %endmacro


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

  mov [living_aliens], dword 30
  mov [bool_for_random], byte 1

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
  mov [eax + 9], word 300
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
  mov [eax + 9], word 200
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
  mov [eax + 9], word 100
  add edx, 8
  add eax, 12
  loop ciclo5


  xor edx, edx
  xor eax, eax
  xor ecx, ecx

;initializing ship_shots and alien_shots
  mov eax, ship_shots
  mov cl, [ship_shots_amount]
  init_ship_shots:
    mov [eax], dword paint_shot
    mov [eax + 6], byte 1
    add eax, 8
    loop init_ship_shots

  xor ecx, ecx
  xor eax, eax
  xor ebx, ebx

  mov eax, alien_shots
  mov cl, [alien_shots_amount]
  init_alien_shots:
    mov [eax], dword paint_shot
    mov [eax + 6], byte 1
    add eax, 8
    loop init_alien_shots


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
  mov eax, ship_shots
  mov ebx, drawables
  mov edx, 128
  mov cl, [ship_shots_amount]
  m_ship_shots:
  mov [ebx + edx], eax
  add eax, 8
  add edx, 4
  loop m_ship_shots

  mov ecx, 0
  mov eax, alien_shots
  ;mov edx, 140
  mov cl, [alien_shots_amount]
  m_alien_shots:
  mov [ebx + edx], eax
  add eax, 8
  add edx, 4
  loop m_alien_shots


  mov [wallpaper], dword fill_map

  mov [ship], dword paint_ship
  mov [ship + 4], byte 0b0001_1000
  mov [ship + 5], byte 0b0011_0010
  mov [ship + 6], byte 3

  mov [points], dword paint_points
  mov [points + 4], dword 0
  mov [drawables + 180], dword points

  mov [lives], dword paint_lives
  mov [lives + 4], dword ship
  mov [drawables + 184], dword lives



  ; Main loop
  game.loop:

    .input:
      call get_input

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx

      push dword 70
      push timer_shot
      call delay
      add esp, 8
      cmp eax, 0
      jne move_shots
      move_shots_ret:
      DESTROY_ALIEN points, living_aliens, alien, ship_shots, ship_shots_amount
      DESTROY_SHIP alien_shots_amount, alien_shots, ship

      push dword 50
      push timer_alien
      call delay
      add esp, 8

      mov ecx, 30
      mov esi, alien
      cmp eax, 0
      jne move_alien
      move_alien_ret:

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx


  ; random shots for the aliens

      cmp byte[bool_for_random], 1
      jne timer

      call rtcs
      mov [bool_for_random], byte 0
      mov bl, [living_aliens]
      div bl
      mov ebx, 0
      mov bl, ah
      mov [random], ebx

      push dword [random]
      call alien_shooting
      add esp, 4

      push alien_shots_amount
      push alien_shots
      push dword 0
      push eax
      call create_shot
      add esp, 16

      timer:
      mov eax, [random]
      inc eax; just in case random is 0
      shl eax, 7
      push eax
      push timer_alien_shooting
      call delay
      add esp, 8
      cmp eax, 0
      je continue3

      mov [bool_for_random], byte 1

      continue3:


      REFRESH_MAP map, drawables, 47


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
  mov eax, ship_shots
  mov ecx, 0
  mov cl, [ship_shots_amount]
  find1:
  cmp byte [eax + 6], 0
  jne continue1
  push eax
  call move_shot
  add esp, 4
  continue1:
  add eax, 8
  loop find1

  mov eax, alien_shots
  mov ecx, 0
  mov cl, [alien_shots_amount]
  find2:
  cmp byte [eax + 6], 0
  jne continue2
  push eax
  call move_shot
  add esp, 4
  continue2:
  add eax, 8
  loop find2
  jmp move_shots_ret

;move_shot(esp + 4: direction of the shot to move)
move_shot:
  push ebp
  mov ebp, esp
  pusha
  mov eax, [ebp + 8]
  cmp byte [eax + 7], 1
  je move_shot_up
  cmp byte [eax + 7], 0
  je move_shot_down
  cmp byte [eax + 7], 2
  je move_shot_dru
  cmp byte [eax + 7], 3
  je move_shot_dlu

finish:
  popa
  mov esp, ebp
  pop ebp
  ret

move_shot_up:
  cmp byte [eax + 4], 0
  je it_crashed
  MOVE_UP eax
  jmp finish

move_shot_down:
  cmp byte [eax + 4], 24
  je it_crashed
  MOVE_DOWN eax
  jmp finish

move_shot_dru:
  cmp byte [eax + 4], 0
  je it_crashed
  cmp byte [eax + 5], 79
  je it_crashed
  MOVE_DIAG_RIGHT_UP eax
  jmp finish

move_shot_dlu:
  cmp byte [eax + 4], 0
  je it_crashed
  cmp byte [eax + 5], 0
  je it_crashed
  MOVE_DIAG_LEFT_UP eax
  jmp finish

it_crashed:
  mov byte [eax + 6], 1
  jmp finish


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




;alien_shooting(esp + 4: pos of the alien who shot)
;returns the memory direction of the alien
alien_shooting:
  mov ecx, [esp + 4]
  inc ecx
  mov eax, alien
  mov ebx, 0
  ciclo6:
    cmp byte [eax + ebx + 6], 0
    jne continue4
    dec ecx
    continue4:
    add ebx, 12
    cmp ecx, 0
    ja ciclo6
  sub ebx, 12
  add eax, ebx
  ret


  ; mov ecx, [esp + 4]
  ; mov eax, alien
  ; mov ebx, 0
  ; ciclo6:
  ;   cmp byte [eax + ebx + 6], 0
  ;   jne continue4
  ;   dec ecx
  ;   continue4:
  ;   add ebx, 12
  ;   cmp ecx, 0
  ;   ja ciclo6
  ; sub ebx, 12
  ; add eax, ebx
  ; ret








;esp + 4 memory direction of the ship that shot
;esp + 8 direction of the shot (0 down, 1 up, 2 diag-right-up, 3 diag-left-up)
;esp + 12 direction of the array of shots
;esp + 16 length of the array
create_shot:
  mov eax, [esp + 16]
  mov ecx, 0
  mov cl, [eax]
  mov eax, [esp + 12]
  find_available_shot:
  cmp byte [eax + 6], 1
  je create
  add eax, 8
  loop find_available_shot
  shot_finished:
  ret

  create:
  mov ebx, [esp + 4] ; ship that shot
  mov ecx, [esp + 8] ; direction of the shot
  mov dx, [ebx + 4] ; row and col
  mov [eax + 4], dx
  mov [eax + 6], byte 0
  mov [eax + 7], cl
  jmp shot_finished



the_ship_shot:
  cmp byte [ship + 6], 0
  je .end
  push ship_shots_amount
  push ship_shots
  push dword 1
  push ship
  call create_shot
  add esp, 16
  .end:
  ret


ultrashot:
  cmp byte [ship + 6], 0
  je .end
  ;shot that goes up
  push ship_shots_amount
  push ship_shots
  push dword 1
  push ship
  call create_shot
  add esp, 16
  ;shot that goes to the right and up in diagonal direction
  push ship_shots_amount
  push ship_shots
  push dword 2
  push ship
  call create_shot
  add esp, 16
  ;shot that goes to the left and up in diagonal direction
  push ship_shots_amount
  push ship_shots
  push dword 3
  push ship
  call create_shot
  add esp, 16

  .end:
  ret

get_input:
    call scan
    push ax
    ; The value of the input is on 'word [esp]'
    ; Your bindings here

    bind_move KEY.UP, MOVE_UP, ship
    bind_move KEY.DOWN, MOVE_DOWN, ship
    bind_move KEY.RIGHT, MOVE_RIGHT, ship
    bind_move KEY.LEFT, MOVE_LEFT, ship

    bind KEY.Spc, the_ship_shot
    bind KEY.Q, ultrashot

    ;bind_shot KEY.Spc
    ;bind_ultrashot KEY.Q

    add esp, 2 ; free the stack

    ret
