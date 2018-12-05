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

global change_direction
change_direction:
  INI
  %define object [ebp + 8]
  mov eax, object
  cmp byte [eax + 7], 1
  je decre
  cmp byte [eax + 7], 0
  je cre
  jump:
  %undef object
  END
  ret

  cre:
  inc byte [eax + 7]
  jmp jump

  decre:
  dec byte [eax + 7]
  jmp jump

global move_diag_right_up
move_diag_right_up:
  INI
  %define object [ebp + 8]
  mov eax, object
  cmp byte [eax + 4], 0
  je fin
  cmp byte [eax + 5], 79
  je fin
  dec byte [eax + 4]
  inc byte [eax + 5]
  fin:
  %undef object
  END
  ret

global move_diag_left_up
move_diag_left_up:
  INI
  %define object [ebp + 8]
  mov eax, object
  cmp byte [eax + 4], 0
  je .end
  cmp byte [eax + 5], 0
  je .end
  dec byte [eax + 4]
  dec byte [eax + 5]
  .end:
  %undef object
  END
  ret
