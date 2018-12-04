
%macro INI 0
  push ebp
  mov ebp, esp
  pusha
%endmacro

%macro END 0
  popa
  mov esp, ebp
  pop ebp
%endmacro


section .text


global destroy_ship
destroy_ship:
  INI
  %define punt_ship [ebp + 8]
  %define punt_shots [ebp + 12]
  %define punt_amount_shots [ebp + 16]

  mov edi, punt_ship ; ship
  cmp byte [edi + 6], 0
  je finish

  mov edx, punt_amount_shots
  mov ecx, 0
  mov cl, [edx] ; amount of shots
  mov ebx, punt_shots

  ciclo3:
    cmp byte [ebx + 6], 0
    jne continue3
    push dword 0
    ; mov edx, 0
    ; mov dx, [ebx + 4] ; row and column of the shot
    ; push edx
    ; mov edx, 0
    ; mov dx, [edi + 4] ; row and column of the ship
    ; push edx
    push ebx
    push edi
    call destroy
    add esp, 12
    cmp eax, 1
    je it_crashed
    continue3:
    add ebx, 8
  loop ciclo3
  jmp finish


  it_crashed:
    mov [ebx + 6], byte 1
    dec byte [edi + 6]
    cmp byte [edi + 6], 0
    je finish
    jmp continue3

  finish:
    END
    %undef punt_ship
    %undef punt_shots
    %undef punt_amount_shots
    ret





;destroy(pos1, pos2, type)
;pos1: object to be destroyed
;pos2: object that destroys
;type: indicates the kind of object to be destroyed
;      0 ship
global destroy
destroy:
  mov esi, [esp + 4]
  mov edx, [esp + 8]
  mov eax, 0
  mov al, [edx + 4]
  cmp [esi + 4], al
  jne did_not_match
  mov esi, [esp + 12]
  cmp dword [esi], 0
  je destroying_a_ship

  end_destroying:
  ret

  did_not_match:
    mov eax, 0
    jmp end_destroying

  destroying_a_ship:
    mov al, [esi + 5]
    mov dl, [edx + 5]
    sub al, 2
    cmp al, dl
    ja did_not_match
    add al, 4
    cmp al, dl
    jb did_not_match
    mov eax, 1
    jmp end_destroying










global destroy_alien
destroy_alien:
  INI
  %define punt_amount_shots [ebp + 8]
  %define punt_shot [ebp + 12]
  %define punt_alien [ebp + 16]
  %define punt_living_aliens [ebp + 20]

  mov eax, punt_amount_shots
  mov ecx, 0
  mov cl, [eax]
  mov eax, punt_shot
  ciclo:
    mov dh, [eax + 6]
    cmp dh, 1
    je continue1
    mov ebx, punt_alien
    mov esi, ecx
    mov ecx, 30
    ciclo2:
      mov dh, [ebx + 6]
      cmp dh, 1
      je continue2
      mov dl, [ebx + 4]
      cmp dl, [eax + 4]
      je same_row
      same_row_ret:
      continue2:
      add ebx, 12
    loop ciclo2
    mov ecx, esi
    continue1:
    add eax, 8
  loop ciclo
  jmp end


  same_row:
  mov dl, [ebx + 5]
  add dl, 2
  cmp [eax + 5], dl
  jbe same_row_correct
  jmp same_row_ret

  same_row_correct:
  mov dl, [ebx + 5]
  sub dl, 2
  cmp [eax + 5], dl
  jae same_row_correct2
  jmp same_row_ret

  same_row_correct2:
  mov [ebx + 6], byte 1
  mov [eax + 6], byte 1
  
  pusha
  mov eax, punt_living_aliens
  mov ebx, 0
  mov bl, [eax]
  dec bl
  mov [eax], bl
  popa

  jmp same_row_ret


  end:
  END
  %undef punt_shot
  %undef punt_alien
  %undef punt_amount_shots
  %undef punt_living_aliens
  ret

global paint_shot
paint_shot:
    INI
    %define punt_map [ebp + 12]
    %define punt_shot [ebp + 8]

    mov edx, punt_shot

    mov al, [edx + 6]
    mov bl, 1
    cmp al, bl
    je .end
    xor eax, eax
    xor ebx, ebx

    mov al, [edx + 4]
    mov bl, 80
    mul bl
    xor ebx, ebx
    mov bl, [edx + 4 + 1]
    add eax, ebx
    mov ebx, 4
    mul ebx
    add eax, punt_map

    mov [eax], byte 4
    mov [eax + 1], byte 7

    .end:
    END
    %undef punt_map
    %undef punt_alien
    ret
