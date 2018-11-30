
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
