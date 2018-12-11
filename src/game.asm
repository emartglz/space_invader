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

surprise_box resd 2
drop_box resb 1 ;bool for dropping the surprise box
timer_box resd 2 ; timer to move the surprise box
timer_for_dropping resd 2 ; timer to drop the box

ini_fill_screen resd 2
index_cartel resd 2
ini_wallpaper resd 3
ini_drawables resd 5
index resd 1

end_wallpaper resd 5
name resd 1
punctuation resd 20
fill_punctuation resd 2
punctuation_drawables resd 5
end_drawables resd 5

living_aliens resd 1

bool_for_random resb 1
random resd 1

;0 easy, 1 medium, 2 hard
;3 crazy_aliens, 4 space_shooter, 5 arcade
;6 two players, 7 mirror_mode
mode resb 1

; shots: function to paint
; shots+4: row, shots+5:col
; shots + 6: bool for crashed
; shots + 7:direction of movement(0 down, 1 up, 2 dru, 3 dlu, 4 right, 5 left)
ship_shots resd 6
ship2_shots resd 6
alien_shots resd 20

wallpaper resd 2
drawables resd 52

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
extern create_box

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
  ini_punctuation:
    mov eax, ecx
    mov ebx, 8
    mul ebx
    mov [punctuation + eax - 8], dword 0
    mov [punctuation + eax - 4], dword 0
  loop ini_punctuation
    mov [name], dword 0

  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

  ;jmp punctuation_screen

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
  mov [mode], byte 7


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
  mov ebx, ship2_shots
  mov cl, [ship_shots_amount]
  init_ship_shots:
    mov [eax], dword paint_shot
    mov [ebx], dword paint_shot
    mov [eax + 6], byte 1
    mov [ebx + 6], byte 1
    add eax, 8
    add ebx, 8
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

  mov eax, ship2_shots
  mov ebx, drawables
  xor ecx, ecx
  mov cl, [ship_shots_amount]
  m_ship2_shots:
  mov [ebx + edx], eax
  add eax, 8
  add edx, 4
  loop m_ship2_shots

  xor ecx, ecx
  mov eax, alien_shots
  mov cl, [alien_shots_amount]
  m_alien_shots:
  mov [ebx + edx], eax
  add eax, 8
  add edx, 4
  loop m_alien_shots

;initializing other things
  mov [wallpaper], dword fill_map

  mov [ship], dword paint_ship
  mov [ship + 4], byte 0b0001_1000
  mov [ship + 5], byte 0b0011_0010

  mov [ship2], dword paint_ship2
  mov [ship2 + 4], byte 0b0001_1000
  mov [ship2 + 5], byte 0b0001_0100

  call decide_mode_lives

  mov [points], dword paint_points
  mov [points + 4], dword 0
  mov [drawables + 192], dword points

  mov [lives], dword paint_lives
  mov [lives + 4], dword ship
  mov [drawables + 196], dword lives

  mov [drawables + 200], dword ship2

  mov [surprise_box], dword paint_box
  mov [surprise_box + 6], byte 1
  mov [drawables + 204], dword surprise_box
  mov [drop_box], byte 1

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

;moving all the shots
      push dword 70
      push timer_shot
      call delay
      add esp, 8
      cmp eax, 0
      jne move_all_shots
      move_shots_ret:
      DESTROY_SHOTS points, alien_shots_amount, ship_shots_amount, alien_shots, ship_shots
      DESTROY_SHOTS points, alien_shots_amount, ship_shots_amount, alien_shots, ship2_shots
      DESTROY_ALIEN points, living_aliens, alien, ship_shots, ship_shots_amount
      DESTROY_ALIEN points, living_aliens, alien, ship2_shots, ship_shots_amount
      DESTROY_SHIP alien_shots_amount, alien_shots, ship
      DESTROY_SHIP alien_shots_amount, alien_shots, ship2

      cmp [ship + 6], byte 0
      je game_over_screen
      cmp [living_aliens], dword 0
      je game_over_screen

;moving all the aliens
      xor eax, eax
      call decide_aliens_velocity
      push eax
      push timer_alien
      call delay
      add esp, 8

      mov ecx, 30
      mov esi, alien
      cmp eax, 0
      jne decide_alien_movement
      move_alien_ret:

      call infinite_move

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

      push dword [random]
      call alien_shooting
      add esp, 4

      cmp byte [mode], 4
      je intelligent_aliens

      push alien_shots_amount
      push alien_shots
      push dword 0
      push eax
      call create_shot
      add esp, 16

      intelligent_aliens_ret:


      timer:
      xor eax, eax
      call timer_for_shooting
      push eax
      push timer_alien_shooting
      call delay
      add esp, 8
      cmp eax, 0
      je continue3

      mov [bool_for_random], byte 1

      continue3:

; random for dropping the surprise boxes
      cmp byte [drop_box], 1
      je random_dropping
      random_dropping_end:

      push dword 500
      push timer_box
      call delay
      add esp, 8
      cmp eax, 0
      jne move_box
      move_box_end:
      DESTROY_SHOTS points, dword 1, ship_shots_amount, surprise_box, ship_shots
      DESTROY_SHOTS points, dword 1, ship_shots_amount, surprise_box, ship2_shots
      ; DESTROY_BOX ship_shots_amount, ship_shots, surprise_box
      ; DESTROY_BOX ship_shots_amount, ship2_shots, surprise_box

      cmp byte [drop_box], 0
      je check_status
      check_end:

      REFRESH_MAP map, drawables, 52


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

punctuation_screen:
  mov [ini_fill_screen], dword fill_map
  mov [fill_punctuation], dword paint_punctuation
  mov [fill_punctuation + 4], dword punctuation
  mov [punctuation_drawables], dword ini_fill_screen
  mov [punctuation_drawables + 4], dword fill_punctuation

  punctuation_screen_loop:
    REFRESH_MAP map, punctuation_drawables, 2
    PAINT_MAP map
  jmp punctuation_screen_loop


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
  je punctuation_screen

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

; the movement of the aliens depend on the chosen mode
decide_alien_movement:
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


; generate aliens so the game will never end
generate_aliens:
  mov ecx, [aliens_amount]
  mov edi, alien
  ciclo7:
    cmp byte [edi + 6], 0
    je continue7
    rdtsc
    xor edx, edx
    mov ebx, 75
    div ebx
    mov [edi + 4], byte 1
    mov [edi + 5], dl
    mov [edi + 6], byte 0
    inc dword [living_aliens]
    continue7:
    add edi, 12
    loop ciclo7
  jmp generate_aliens_ret


move_all_shots:
  MOVE_SHOTS alien_shots_amount, alien_shots
  MOVE_SHOTS ship_shots_amount, ship2_shots
  MOVE_SHOTS ship_shots_amount, ship_shots
  jmp move_shots_ret



;moving aliens in a line
;esi aliens
;ecx amount of aliens
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




;moving aliens randomly
; esi pointer to aliens
; ecx total amount of aliens
move_alien_randomly:
  pusha
  xor eax, eax
  xor ebx, ebx
  xor edx, edx
  mov ebx, 4
  rdtsc
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

  popa
  jmp move_alien_ret

  try_move_down:
    cmp byte [esi + 4], 22
    je not_possible_down
    MOVE_DOWN esi
    jmp continue5
    not_possible_down:
    cmp byte [mode], 4
    je alien_disappears
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

  alien_disappears:
    mov [esi + 6], byte 1
    dec dword [living_aliens]
    cmp dword [points + 4], 100
    jb not_enough_points
    sub dword [points + 4], 100
    jmp continue5
    not_enough_points:
    mov [points + 4], dword 0
    jmp continue5





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


;this method tells the aliens where to shoot in space_shooter mode
intelligent_aliens:
  xor edx, edx
  mov dl, [ship + 4]
  cmp [eax + 4], dl
  ja shoot_up
  jb shoot_down
  xor edx, edx
  mov dl, [ship + 5]
  cmp [eax + 5], dl
  ja shoot_left
  jmp shoot_right
  .end:
  jmp intelligent_aliens_ret

  shoot_up:
  push alien_shots_amount
  push alien_shots
  push dword 1
  push eax
  call create_shot
  add esp, 16
  jmp intelligent_aliens.end

  shoot_down:
  push alien_shots_amount
  push alien_shots
  push dword 0
  push eax
  call create_shot
  add esp, 16
  jmp intelligent_aliens.end

  shoot_right:
  push alien_shots_amount
  push alien_shots
  push dword 4
  push eax
  call create_shot
  add esp, 16
  jmp intelligent_aliens.end

  shoot_left:
  push alien_shots_amount
  push alien_shots
  push dword 5
  push eax
  call create_shot
  add esp, 16
  jmp intelligent_aliens.end





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


;this function is only called when our ship was the one who shot
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

the_ship_shot_down:
  cmp byte [ship + 6], 0
  je .end
  push ship_shots_amount
  push ship_shots
  push dword 0
  push ship
  call create_shot
  add esp, 16
  .end:
  ret

the_ship_shot_left:
  cmp byte [ship + 6], 0
  je .end
  push ship_shots_amount
  push ship_shots
  push dword 5
  push ship
  call create_shot
  add esp, 16
  .end:
  ret

the_ship_shot_right:
  cmp byte [ship + 6], 0
  je .end
  push ship_shots_amount
  push ship_shots
  push dword 4
  push ship
  call create_shot
  add esp, 16
  .end:
  ret

;this function will only be called in the two_players mode
the_ship2_shot:
  cmp byte [ship2 + 6], 0
  je .end
  push ship_shots_amount
  push ship2_shots
  push dword 1
  push ship2
  call create_shot
  add esp, 16
  .end:
  ret

; Special weapon
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

;this is for cheating
add_lives:
  cmp byte [ship + 6], 10
  jae .end
  add [ship + 6], byte 3
  .end:
  ret



decide_mode_lives:
  cmp byte [mode], 0 ; easy mode
  je easy_lives
  cmp byte [mode], 1 ; medium mode
  je medium_lives
  cmp byte [mode], 2 ; hard mode
  je hard_lives
  cmp byte [mode], 3 ; crazy aliens mode
  je medium_lives
  cmp byte [mode], 4 ; space_shooter
  je medium_lives
  cmp byte [mode], 5 ; arcade mode
  je medium_lives
  cmp byte [mode], 6 ; two players mode
  je two_players_lives
  cmp byte [mode], 7 ; mirror mode
  je two_players_lives
  .end:
  ret

  easy_lives:
  mov [ship + 6], byte 5
  jmp decide_mode_lives.end

  medium_lives:
  mov [ship + 6], byte 3
  jmp decide_mode_lives.end

  hard_lives:
  mov [ship + 6], byte 1
  jmp decide_mode_lives.end

  two_players_lives:
  mov [ship + 6], byte 3
  mov [ship2 + 6], byte 3


decide_aliens_velocity:
  cmp byte [mode], 0 ; easy mode
  je easy_velocity
  cmp byte [mode], 1 ; medium mode
  je medium_velocity
  cmp byte [mode], 2 ; hard mode
  je hard_velocity
  cmp byte [mode], 3 ; crazy aliens mode
  je medium_velocity
  cmp byte [mode], 4 ; space_shooter
  je easy_velocity
  cmp byte [mode], 5 ; arcade mode
  je easy_velocity
  cmp byte [mode], 6 ; two players mode
  je easy_velocity
  cmp byte [mode], 7 ; mirror mode
  je hard_velocity
  .end:
  ret

  easy_velocity:
  mov eax, 250
  jmp decide_aliens_velocity.end

  medium_velocity:
  mov eax, 250
  cmp dword [living_aliens], 20
  ja .continue
  mov eax, 100
  cmp dword [living_aliens], 8
  ja .continue
  mov eax, 50
  cmp dword [living_aliens], 3
  ja .continue
  mov eax, 25
  .continue:
  jmp decide_aliens_velocity.end

  hard_velocity:
  mov eax, 50
  cmp dword [living_aliens], 8
  ja .continue
  mov eax, 25
  .continue:
  jmp decide_aliens_velocity.end


timer_for_shooting:
  cmp byte [mode], 0 ; easy mode
  je easy_shot
  cmp byte [mode], 1 ; medium mode
  je easy_shot
  cmp byte [mode], 2 ; hard mode
  je hard_shot
  cmp byte [mode], 3 ; crazy aliens mode
  je hard_shot
  cmp byte [mode], 4 ; space_shooter
  je arcade_shot
  cmp byte [mode], 5 ; arcade mode
  je arcade_shot
  cmp byte [mode], 6 ; two players mode
  je hard_shot
  cmp byte [mode], 7 ; mirror mode
  je hard_shot
  .end:
  ret

  easy_shot:
  mov eax, 1000
  jmp timer_for_shooting.end

  hard_shot:
  mov eax, [random]
  inc eax; just in case random is 0
  shl eax, 7
  jmp timer_for_shooting.end

  arcade_shot:
  mov eax, 500
  jmp timer_for_shooting.end



infinite_move:
 cmp byte [mode], 5
 je infinite_mode
 cmp byte [mode], 4
 je infinite_mode
 .end:
 ret

 infinite_mode:
 cmp eax, 0
 jne generate_aliens
 generate_aliens_ret:
 jmp infinite_move.end



random_dropping:
  rdtsc
  xor edx, edx
  mov ebx, 1000
  div ebx
  ;mov edx, 34
  cmp edx, 10
  jb drop_it
  drop_it_end:
  mov [drop_box], byte 0
  jmp random_dropping_end


drop_it:
  push dword surprise_box
  call create_box
  add esp, 4
  jmp drop_it_end

move_box:
  MOVE_BOX surprise_box
  jmp move_box_end


check_status:
  cmp byte [surprise_box + 6], 1
  jne check_end
  mov byte [drop_box], 1
  jmp check_end


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

    cmp byte [mode], 7
    jne not_mirror_mode
    bind_move KEY.UP, MOVE_UP, ship2
    bind_move KEY.DOWN, MOVE_DOWN, ship2
    bind_move KEY.RIGHT, MOVE_LEFT, ship2
    bind_move KEY.LEFT, MOVE_RIGHT, ship2

    bind KEY.Spc, the_ship2_shot

    not_mirror_mode:

    cmp byte [mode], 4
    jne not_space_shooter_mode
    bind KEY.W, the_ship_shot
    bind KEY.S, the_ship_shot_down
    bind KEY.D, the_ship_shot_right
    bind KEY.A, the_ship_shot_left
    jmp it_was_ss_mode


    not_space_shooter_mode:
    bind KEY.Spc, the_ship_shot

    it_was_ss_mode:
    bind KEY.Q, ultrashot
    bind KEY.1, add_lives

    cmp byte [mode], 6
    jne not_two_players_mode

    ;this will only happen if it is two_players mode
    bind_move KEY.W, MOVE_UP, ship2
    bind_move KEY.S, MOVE_DOWN, ship2
    bind_move KEY.D, MOVE_RIGHT, ship2
    bind_move KEY.A, MOVE_LEFT, ship2

    bind KEY.E, the_ship2_shot

    not_two_players_mode:

    add esp, 2 ; free the stack

    ret
