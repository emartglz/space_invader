

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

global paint_ship
paint_ship:
  INI
  %define punt_map [ebp + 12]
  %define punt_ship [ebp + 8]

  mov edx, punt_ship
  mov al, [edx + 4]
  mov bl, 80
  mul bl
  xor ebx, ebx
  mov bl, [edx + 4 + 1]
  add eax, ebx
  mov ebx, 4
  mul ebx
  add eax, punt_map

  mov [eax + 1], byte 5
  mov [eax], byte '8'
  mov [eax - 4 + 1], byte 5
  mov [eax - 4], byte '/'
  mov [eax - 8 + 1], byte 7
  mov [eax - 8], byte '<'
  mov [eax + 4 + 1], byte 5
  mov [eax + 4], byte '\'
  mov [eax + 8 + 1], byte 7
  mov [eax + 8], byte '>'

  END

  %undef punt_map
  %undef punt_ship
  ret