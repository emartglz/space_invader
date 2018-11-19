%include "video.mac"
%include "keyboard.mac"
%include "presentation.asm"

section .bss
map resb 8000
ship resw 1
ship_map resd 1

section .text

extern clear
extern putc
extern scan
extern calibrate

%macro PAINT_MAP 1
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx

  %%jump:
  push dword [%1 + edx]
  call putc
  add esp, 4
  add edx, 4
  cmp edx, 8000
  jl %%jump
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
%endmacro

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


  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

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


  ; Snakasm main loop
  game.loop:

    PAINT_MAP map

    .input:
      call get_input

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx

      ;call refresh_map

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

  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  ret



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



get_input:
    call scan
    push ax
    ; The value of the input is on 'word [esp]'
    ;MOVE move_up, move_right, move_down, move_left
    ; Your bindings here

    bind KEY.UP, move_up
    bind KEY.DOWN, move_down
    bind KEY.RIGHT, move_right
    bind KEY.LEFT, move_left
    
    add esp, 2 ; free the stack

    ret
