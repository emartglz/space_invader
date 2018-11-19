
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

global paint_alien
paint_alien:
  INI
  %define punt_map [ebp + 12]
  %define punt_alien [ebp + 8]

  mov edx, punt_alien

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

  mov [eax + 1], byte 6
  mov [eax], byte 'o'
  mov [eax - 4 + 1], byte 3
  mov [eax - 4], byte 'o'
  mov [eax - 8 + 1], byte 8
  mov [eax - 8], byte '('
  mov [eax + 4 + 1], byte 3
  mov [eax + 4], byte 'o'
  mov [eax + 8 + 1], byte 8
  mov [eax + 8], byte ')'

  .end:
  END
  %undef punt_map
  %undef punt_alien
  ret