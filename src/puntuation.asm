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

global paint_puntuation
paint_puntuation:
    INI
    %define punt_map[ebp + 12]
    %define punt_puntuations[ebp + 8]

    mov esi, punt_map
    mov eax, punt_puntuations
    mov edi, [eax + 4]
    add esi, 960
    mov ecx, 10
    ciclo:
        mov eax, 11
        sub eax, ecx
        mov ebx, 2
        mul ebx

        ;mov eax, ecx
        ;add eax, ecx
        mov ebx, 80
        mul ebx
        mov ebx, 4
        mul ebx
        add eax, 20
        mov dl, 11
        sub dl, cl
        add dl, '0'
        mov [esi + eax], byte dl
        add eax, 4
        mov [esi + eax], byte '-'
        add eax, 80
        ;print name
        mov dl, [edi + 1]
        mov [esi + eax], dl
        add eax, 4
        mov dl, [edi + 2]
        mov [esi + eax], dl
        add eax, 4
        mov dl, [edi + 3]
        mov [esi + eax], dl
        add eax, 80
        ;print points
        pusha
            mov ecx, eax
            mov eax, [edi + 4]
            mov edi, ecx
            mov ebx, 10
            mov ecx, 5
            ;mov edi, 32
            add edi, 20
            ciclo2:
            xor edx, edx  ; make edx = 0TAKE_NAME
            div ebx
            add dl, '0'
            mov [esi + edi], byte dl
            ;mov [esi + edi + 1], byte 13
            sub edi, 4
            loop ciclo2
        popa
        add edi, 8
    loop ciclo

    END
    %undef punt_map
    %undef punt_puntuations
    ret

global take_name
take_name:
    INI
    %define punt_name [ebp + 10]
    %define key [ebp + 8]

    xor eax, eax

    ;jmp take_name_end

    mov al, key
    cmp al, 0x02
    je l1
    cmp al, 0x03
    je l2
    cmp al, 0x04
    je l3
    cmp al, 0x05
    je l4
    cmp al, 0x06
    je l5
    cmp al, 0x07
    je l6
    cmp al, 0x08
    je l7
    cmp al, 0x09
    je l8
    cmp al, 0x0A
    je l9
    jmp take_name_end

;  KEY.Q               0x10
;  KEY.W               0x11
;  KEY.E               0x12
;  KEY.R               0x13
;  KEY.T               0x14
;  KEY.Y               0x15
;  KEY.U               0x16
;  KEY.I               0x17
;  KEY.O               0x18
;  KEY.P               0x19
;  KEY.A               0x1E
;  KEY.S               0x1F
;  KEY.D               0x20
;  KEY.F               0x21
;  KEY.G               0x22
;  KEY.H               0x23
;  KEY.J               0x24
;  KEY.K               0x25
;  KEY.L               0x26
;  KEY.Z               0x2C
;  KEY.X               0x2D
;  KEY.C               0x2E
;  KEY.V               0x2F
;  KEY.B               0x30
;  KEY.N               0x31
;  KEY.M               0x32

    l1:
    mov al, '1'
    jmp letra_ya
    l2:
    mov al, '2'
    jmp letra_ya
    l3:
    mov al, '3'
    jmp letra_ya
    l4:
    mov al, '4'
    jmp letra_ya
    l5:
    mov al, '5'
    jmp letra_ya
    l6:
    mov al, '6'
    jmp letra_ya
    l7:
    mov al, '7'
    jmp letra_ya
    l8:
    mov al, '8'
    jmp letra_ya
    l9:
    mov al, '9'
    jmp letra_ya

    letra_ya:

    mov ebx, punt_name
    cmp [ebx + 1], byte 0
    je ini1
    cmp [ebx + 2], byte 0
    je ini2
    cmp [ebx + 3], byte 0
    je ini3

    jmp take_name_end

    ini1:
    mov [ebx + 1], al
    jmp take_name_end
    ini2:
    mov [ebx + 2], al
    jmp take_name_end
    ini3:
    mov [ebx + 3], al
    jmp take_name_end

    

    take_name_end:

    END
    %undef punt_name
    %undef key
    ret

global add_puntuation
add_puntuation:
    INI
    %define punt_new_puntuation [ebp + 12]
    %define punt_puntuations [ebp + 8]

    mov esi, punt_new_puntuation
    mov edi, punt_puntuations
    mov eax, [esi + 4]
    cmp [edi + 76], eax
    ja end

    ;mov esi, punt_new_puntuation
    ;mov ebx, [esi + 4]
    ;mov edi, punt_puntuations
    ;cmp [edi + 76], ebx
    ;jb poner

    mov eax, [esi + 4]
    mov [edi + 76], eax
    mov eax, [esi]
    mov [edi + 72], eax

    mov ecx, 9
    ciclo_swap:
        mov eax, ecx
        mov ebx, 8
        mul ebx

        mov ebx, [edi + eax + 4]
        cmp [edi + eax - 4], ebx
        ja end

        ;swap
        mov edx, [edi + eax]
        push edx
        mov edx, [edi + eax + 4]
        push edx

        mov edx, [edi + eax - 8]
        mov [edi + eax], edx
        mov edx, [edi + eax - 4]
        mov [edi + eax + 4], edx

        pop edx
        mov [edi + eax - 4], edx
        pop edx
        mov [edi + eax - 8], edx

    loop ciclo_swap
    jmp end

    poner:
        mov esi, punt_new_puntuation
        mov ebx, [esi + 4]
        mov edi, punt_puntuations
        mov [edi + 20], ebx
        mov ebx, [esi]
        mov [edi + 16], ebx

    end:

    END
    %undef punt_puntuations
    %undef punt_new_puntuation
    ret