%define MOVE_ASM

%include "move.mac"

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


section.text
global move_up
move_up:
  INI
  %define object [ebp + 8]
  mov eax, object
  dec byte [eax + 4]
  cmp byte [eax + 4], 0
  jge move_up.next
  mov [eax + 4], byte 0
  move_up.next:
  %undef object
  END
  ret

global move_down
move_down:
  INI
  %define object [ebp + 8]
  mov eax, object
  inc byte [eax + 4]
  cmp byte [eax + 4], 24
  jle move_down.next
  mov [eax + 4], byte 24
  move_down.next:
  %undef object
  END
  ret

global move_left
move_left:
  INI
  %define object [ebp + 8]
  mov eax, object
  dec byte [eax + 4 + 1]
  cmp byte [eax + 4 + 1], 2
  jge move_left.next
  mov [eax + 4 + 1], byte 2
  move_left.next:
  %undef object
  END
  ret

global move_right
move_right:
  INI
  %define object [ebp + 8]
  mov eax, object
  inc byte [eax + 4 + 1]
  cmp byte [eax + 4 + 1], 77
  jle move_right.next
  mov [eax + 4 + 1], byte 77
  move_right.next:
  %undef object
  END
  ret