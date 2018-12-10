%include "video.mac"
%include "keyboard.mac"
%include "map.mac"
%include "move.mac"
%include "shot.mac"

section .data
ship_shots_amount db 3
alien_shots_amount db 10
aliens_amount dd 30
cartel db "\
@******************************************************************************@\
*                                                                              *\
*                                                                              *\
*    ************   ************  ***********   ***********   ***********      *\
*    *              *          *  *         *   *             *                *\
*    *              *          *  *         *   *             *                *\
*    *              *          *  *         *   *             *                *\
*    ************   ************  ***********   *             ***********      *\
*               *   *             *         *   *             *                *\
*               *   *             *         *   *             *                *\
*               *   *             *         *   *             *                *\
*    ************   *             *         *   ***********   ***********      *\
*                                                                              *\
*                                                                              *\
*                                  EPILEPSIA                                   *\
*                                                                              *\
*                                 NORMAL  GAME                                 *\
*                                                                              *\
*                                 CRAZY  MODE                                  *\
*                                                                              *\
*                                                                              *\
*                                                                              *\
*                                                                              *\
*                                                                              *\
@******************************************************************************@", 0
cartel_game_over db "\
@******************************************************************************@\
*                                                                              *\
*                                                                              *\
*           ***********   ***********   *         *   ***********              *\
*           *             *         *   **       **   *                        *\
*           *             *         *   *  *   *  *   *                        *\
*           *             *         *   *    *    *   *                        *\
*           *    ******   ***********   *         *   ***********              *\
*           *         *   *         *   *         *   *                        *\
*           *         *   *         *   *         *   *                        *\
*           ***********   *         *   *         *   ***********              *\
*                                                                              *\
*           ***********   *         *   ***********   ***********              *\
*           *         *   *         *   *             *         *              *\
*           *         *   *         *   *             *         *              *\
*           *         *   *         *   *             *         *              *\
*           *         *     *     *     ***********   ***********              *\
*           *         *      *   *      *             *       *                *\
*           *         *       * *       *             *        *               *\
*           ***********        *        ***********   *         *              *\
*                                                                              *\
*                                                                              *\
*                        ENTER YOUR NAME: ___ POINTS:                          *\
*                                                                              *\
@******************************************************************************@", 0



section .bss
map resb 8000
ship resd 2
ship2 resd 2
alien resd 90
points resd 2
lives resd 2

ini_fill_screen resd 2
index_cartel resd 2
ini_wallpaper resd 3
ini_drawables resd 5
index resd 1

end_wallpaper resd 5
name resd 1
puntuation resd 20
fill_puntuation resd 2
puntuation_drawables resd 5
end_drawables resd 5

living_aliens resd 1

bool_for_random resb 1
random resd 1

;0 easy, 1 medium, 2 hard
;3 crazy_aliens, 4 space_shooter, 5 arcade
;6 two players
mode resb 1

; shots: function to paint
; shots+4: row, shots+5:col
; shots + 6: bool for crashed
; shots + 7:direction of movement(1 up, 0 down)
ship_shots resd 6
alien_shots resd 20

wallpaper resd 2
drawables resd 48

timer_alien resd 2
timer_shot resd 2
timer_alien_shooting resd 2
timer_wallpaper_ini resd 2
timer_wallpaper_end resd 2

game_start resb 1


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

  mov ecx, 10
  ini_puntuation:
    mov eax, ecx
    mov ebx, 8
    mul ebx
    mov [puntuation + eax - 8], dword 0
    mov [puntuation + eax - 4], dword 0
  loop ini_puntuation
    mov [name], dword 0

  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

  ;jmp puntuation_screen

  mov [game_start], byte 0

  mov [ini_fill_screen], dword fill_map

  mov [ini_wallpaper], dword fill_ini_screen
  mov [ini_wallpaper + 4], dword cartel
  mov [ini_wallpaper + 8], byte 1

  mov [index_cartel], dword paint_cartel
  mov [index_cartel + 4], dword index
  mov [index], byte 16
  mov [index + 1], byte 16
  mov [index + 2], byte 20

  mov [ini_drawables], dword ini_fill_screen
  mov [ini_drawables + 4], dword index_cartel
  mov [ini_drawables + 8], dword ini_wallpaper

  intro_game_loop:
  call get_input_first_screen

  cmp [game_start], byte 1
  je game_loop_beging

  push dword 1000
  push timer_wallpaper_ini
  call delay
  cmp eax, 0
  jne change_wallpaper_ini
  ret_change_walpaper_ini:

  add esp, 8

  REFRESH_MAP map, ini_drawables, 3
  PAINT_MAP map

  jmp intro_game_loop
  game_loop_beging:

  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  xor esi, esi
  xor edi, edi


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

  mov [ship2], dword paint_ship2
  mov [ship2 + 4], byte 0b0001_1000
  mov [ship2 + 5], byte 0b0001_0100
  mov [ship2 + 6], byte 3

  mov [points], dword paint_points
  mov [points + 4], dword 0
  mov [drawables + 180], dword points

  mov [lives], dword paint_lives
  mov [lives + 4], dword ship
  mov [drawables + 184], dword lives

  mov [drawables + 188], dword ship2

  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx


; Main loop
  game.loop:

    .input:
      call get_input

      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx

      push dword 70
      ;push dword 1000
      push timer_shot
      call delay
      add esp, 8
      cmp eax, 0
      jne move_shots
      move_shots_ret:
      DESTROY_SHOTS points, alien_shots_amount, ship_shots_amount, alien_shots, ship_shots
      DESTROY_ALIEN points, living_aliens, alien, ship_shots, ship_shots_amount
      DESTROY_SHIP alien_shots_amount, alien_shots, ship

      cmp [ship + 6], byte 0
      je game_over_screen
      cmp [living_aliens], dword 0
      je game_over_screen

      push dword 200
      push timer_alien
      call delay
      add esp, 8

      mov ecx, 30
      mov esi, alien
      cmp eax, 0
      jne decide_game_mode
      
      move_alien_ret:

      ; cmpcmp byte [mode], 5
      ; jne continue6
      ; cmp eax, 0
      ; jne generate_alienscmp byte [mode], 5
      ; jne continue6
      ; cmp eax, 0
      ; jne generate_aliens byte [mode], 5
      ; jne continue6
      ; cmp eax, 0
      ; jne generate_aliens


      continue6:
      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx


  ; random shots for the aliens

      cmp byte[bool_for_random], 1
      jne timer

      rdtsc
      xor edx, edx
      mov [bool_for_random], byte 0
      xor ebx, ebx
      mov bl, [living_aliens]
      div ebx
      mov [random], edx
      ; call rtcs
      ; mov [bool_for_random], byte 0
      ; mov bl, [living_aliens]
      ; div bl
      ; mov ebx, 0
      ; mov bl, ah
      ; mov [random], ebx

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
      ; mov eax, [random]
      ; inc eax; just in case random is 0
      ; shl eax, 7
      ;push eax
      push dword 1000
      push timer_alien_shooting
      call delay
      add esp, 8
      cmp eax, 0
      je continue3

      mov [bool_for_random], byte 1

      continue3:


      REFRESH_MAP map, drawables, 48


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

puntuation_screen:
  mov [ini_fill_screen], dword fill_map
  mov [fill_puntuation], dword paint_puntuation
  mov [fill_puntuation + 4], dword puntuation
  mov [puntuation_drawables], dword ini_fill_screen
  mov [puntuation_drawables + 4], dword fill_puntuation

  puntuation_screen_loop:
    REFRESH_MAP map, puntuation_drawables, 2
    PAINT_MAP map
  jmp puntuation_screen_loop


game_over_screen:
  mov [ini_fill_screen], dword fill_map
  mov [end_wallpaper], dword fill_end_screen
  mov [end_wallpaper + 4], dword cartel_game_over
  mov [end_wallpaper + 8], byte 1
  mov [end_wallpaper + 12], dword name
  mov [end_wallpaper + 16], dword points
  mov [end_drawables], dword ini_fill_screen
  mov [end_drawables + 4], dword end_wallpaper

  game_over_screen_loop:
  call get_input_game_over_screen
  cmp [game_start], byte 0
  je puntuation_screen

  push dword 1000
  push dword timer_wallpaper_end
  call delay
  cmp eax, 0
  jne change_wallpaper_end
  ret_change_walpaper_end:

  add esp, 8

  REFRESH_MAP map, end_drawables, 2
  PAINT_MAP map

  jmp game_over_screen_loop

decide_game_mode:
  cmp [index], byte 16
    je move_alien
  cmp [index], byte 18
    je move_alien_randomly

change_wallpaper_end:
  inc byte [end_wallpaper + 8]
  cmp byte [end_wallpaper + 8], 16
  je  mod_16_end
  ret_mod_16_end:
  jmp ret_change_walpaper_end


mod_16_end:
  mov [end_wallpaper + 8], byte 1
  jmp ret_mod_16_end

change_wallpaper_ini:
  inc byte [ini_wallpaper + 8]
  cmp byte [ini_wallpaper + 8], 16
  je  mod_16_ini
  ret_mod_16_ini:
  jmp ret_change_walpaper_ini

mod_16_ini:
  mov [ini_wallpaper + 8], byte 1
  jmp ret_mod_16_ini

generate_aliens:
  



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


;moving aliens in a line
;esi aliens
;ecx amount of aliens
move_alien:
  ;pusha
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
  ;popa
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




;moving aliens randomly
; esi pointer to aliens
; ecx total amount of aliens
move_alien_randomly:
  ;pusha
  xor eax, eax
  xor ebx, ebx
  xor edx, edx
  mov ebx, 4
  rdtsc
  ;mov eax, 736546
  xor edx, edx

  foreach:
    cmp byte [esi + 6], 1
    je continue5
    div ebx
    cmp edx, 0
    je try_move_down
    cmp edx, 1
    je try_move_up
    cmp edx, 2
    je try_move_right
    cmp edx, 3
    je try_move_left
    continue5:
    add esi, 12
  loop foreach

  ;popa
  jmp move_alien_ret

  try_move_down:
    cmp byte [esi + 4], 22
    je not_possible_down
    MOVE_DOWN esi
    jmp continue5
    not_possible_down:
    jmp try_move_up

  try_move_up:
    cmp byte [esi + 4], 1
    je not_possible_up
    MOVE_UP esi
    jmp continue5
    not_possible_up:
    jmp try_move_down

  try_move_right:
    cmp byte [esi + 5], 77
    je not_possible_right
    MOVE_RIGHT esi
    jmp continue5
    not_possible_right:
    jmp try_move_down

  try_move_left:
    cmp byte [esi + 5], 2
    je not_possible_left
    MOVE_LEFT esi
    jmp continue5
    not_possible_left:
    jmp try_move_down







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
  je ultrashot_end
  mov dl, 3
  mov cl, [ship_shots_amount]
  mov eax, ship_shots
  yes:
    cmp byte [eax + 6], 1
    jne .continue
    dec dl
    cmp dl, 0
    je yes_end
    .continue:
    add eax, 8
  loop yes
  cmp dl, 0
  jne ultrashot_end
  yes_end:

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

  ultrashot_end:
  ret

add_lives:
  cmp byte [ship + 6], 10
  jae .end
  add [ship + 6], byte 3
  .end:
  ret

enter_game:
  mov [game_start], byte 1
  ret

restart_game:
 mov [game_start], byte 0
 ret


get_input_game_over_screen:
  call scan
  push ax

  bind KEY.ENTER,restart_game   

  add esp, 2
  ret

get_input_first_screen:
  call scan
  push ax

  bind_move KEY.UP, MOVE_UP_CARTEL, index
  bind_move KEY.DOWN, MOVE_DOWN_CARTEL, index
  bind KEY.ENTER, enter_game
  add esp, 2

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

    bind KEY.1, add_lives

    add esp, 2 ; free the stack

    ret
