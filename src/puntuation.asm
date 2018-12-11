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

global paint_punctuation
paint_punctuation:
    INI
    %define punt_map[ebp + 12]
    %define punt_punctuations[ebp + 8]

    mov esi, punt_map
    mov eax, punt_punctuations
    mov edi, [eax + 4]
    add esi, 960
    mov ecx, 9
    ciclo:
        mov eax, ecx
        add eax, ecx
        mov ebx, 80
        mul ebx
        mov ebx, 4
        mul ebx
        add eax, 20
        mov dl, cl
        add dl, '0'
        mov [esi + eax], byte dl
        add eax, 4
        mov [esi + eax], byte '-'
        add eax, 80
        ;print name
        mov dl, [edi]
        mov [esi + eax], byte '#';dl
        add eax, 4
        mov dl, [edi + 1]
        mov [esi + eax], byte '#';dl
        add eax, 4
        mov dl, [edi + 2]
        mov [esi + eax], byte '#';dl
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
            xor edx, edx  ; make edx = 0
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
    %undef punt_punctuations
    ret

global add_punctuation
add_punctuation:
    INI
    %define punt_punctuations [ebp + 8]
    %define punt_new_punctuation [ebp + 12]

    mov esi, punt_new_punctuation
    mov ebx, [esi + 4]
    mov edi, punt_punctuations
    cmp [edi + 76], ebx
    jle end

    mov eax, punt_punctuations
    mov ecx, [ebx]
    mov [eax + 72], ecx
    mov ecx, [ebx + 4]
    mov [eax + 76], ecx

    mov ecx, 10
    ciclo_swap:
        mov eax, ecx
        mov ebx, 8
        mul ebx

        mov ebx, [esi + eax + 4]
        cmp [esi + eax - 4], ebx
        jle end

        ;swap
        mov edx, [esi + eax]
        push edx
        mov edx, [esi + eax + 4]
        push edx

        mov edx, [esi + eax - 8]
        mov [esi + eax], edx
        mov edx, [esi + eax - 4]
        mov [esi + eax + 4], edx

        pop edx
        mov [esi + eax - 8], edx
        pop edx
        mov [esi + eax - 4], edx

    loop ciclo_swap

    end:
    END
    %undef punt_punctuations
    %undef punt_new_punctuation
    ret