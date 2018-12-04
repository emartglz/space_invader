
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
  %define punt_shot [ebp + 8]
  %define punt_alien [ebp + 12]
  %define punt_points [ebp + 16]
  
  mov ecx, 10
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
      je same_fil
      same_fil_ret:
      continue2:
      add ebx, 12
    loop ciclo2
    mov ecx, esi
    continue1:
    add eax, 8
  loop ciclo
  jmp end


  same_fil:
  mov dl, [ebx + 5]
  add dl, 2
  cmp [eax + 5], dl
  jbe same_fil_correct
  jmp same_fil_ret

  same_fil_correct:
  mov dl, [ebx + 5]
  sub dl, 2
  cmp [eax + 5], dl
  jae same_fil_correct2
  jmp same_fil_ret

  same_fil_correct2:
  push ecx
  push edx

  mov [ebx + 6], byte 1
  mov [eax + 6], byte 1
  mov ecx, punt_points
  xor edx, edx
  mov dx, word [ebx + 9]
  add [ecx + 4], edx

  pop edx
  pop ecx
  jmp same_fil_ret


  end:
  END
  %undef punt_shot
  %undef punt_alien
  %undef punt_points
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
