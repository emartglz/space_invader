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
global paint_cartel
paint_cartel:
    INI
    %define punt_map [ebp + 12]
    %define punt_cartel [ebp + 8]

    mov eax, punt_cartel
    mov edi, [eax + 4]

    mov ecx, 3
    ciclo2:
        xor eax, eax
        mov al, [edi]
        sub eax, 2
        add eax, ecx

        mov esi, punt_map
        mov ebx, 80
        mul ebx
        mov ebx, 4
        mul ebx
        add esi, eax
        push ecx
        add esi, 100
        mov ecx, 30
        ciclo3:
            mov [esi], byte ' '
            mov [esi + 1], byte 0b0100_0000
            add esi, 4
        loop ciclo3
        pop ecx
        
    loop ciclo2

    END
    %undef punt_map
    %undef punt_cartel
    ret

global fill_ini_screen
fill_ini_screen:
    INI
    %define punt_map [ebp + 12]
    %define punt_wallpaper [ebp + 8]

    mov esi, punt_map
    mov eax, punt_wallpaper
    mov bl, [eax + 8]
    mov edx, [eax + 4]
    mov ecx, 2000
    ciclo:
    mov al, [edx]
    cmp al, ' '
    je next
    mov [esi], al
    cmp [esi + 1], byte 0b0100_0000
    je next
    mov [esi + 1], bl
    next:
    inc edx
    add esi, 4
    loop ciclo

    end:
    END
    %undef punt_map
    %undef punt_wallpaper
    ret