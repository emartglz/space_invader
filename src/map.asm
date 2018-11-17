%define MAP_ASM

%include "map.mac"

section .text

global refresh_map
refresh_map:
  %define punt_ship [esp + 8]
  %define punt_map [esp + 4]

  mov edx, punt_ship
  mov al, [edx]
  mov bl, 80
  mul bl
  xor ebx, ebx
  mov bl, [edx + 1]
  add eax, ebx
  mov ebx, 4
  mul ebx
  add eax, punt_map

  mov [eax + 1], byte 5
  mov [eax], byte '8'
  mov [eax - 4 + 1], byte 5
  mov [eax - 4], byte '/'
  mov [eax -8 + 1], byte 7
  mov [eax - 8], byte '<'
  mov [eax + 4 + 1], byte 5
  mov [eax + 4], byte '\'
  mov [eax +8 + 1], byte 7
  mov [eax + 8], byte '>'
  
  %undef punt_map
  %undef punt_ship
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  ret

global fill_map
fill_map:
  %define punt_map [esp + 4]

  mov ebx, 0
  mov ah, 0
  mov al, 0

  fill_map.jump:  
  mov esi, punt_map
  mov [esi + ebx + 3], al
  mov [esi + ebx + 2], ah
  mov [esi + ebx + 1], byte 2
  mov [esi + ebx], byte '#'
  
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
  %undef punt_map
  xor esi, esi
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  ret
