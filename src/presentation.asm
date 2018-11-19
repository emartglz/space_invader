%include "video.mac"

 section .data
 headline db "Proyecto de PMI 2018-2019\n"
 name1 db "Carmen Irene Cabrera Rodríguez\n"
 name2 db "Enrique Martínez González\n"
 ending db "Press any key to continue...\n"


section .text

;esp + 4: memory adress of the string
;esp + 8: max length of the string
string_length:
    mov edi, [esp + 4]
    mov eax, dword '\n'
    mov ecx, [esp + 8]
    repne scasb
    mov eax, [esp + 8]
    sub eax, ecx
    dec eax
    ret

;esp + 4: string.length
;esp + 8: amount of cells in a row/column
to_center:
    mov eax, [esp + 8]
    sub eax, [esp + 4]
    shr eax, 1
    ret

;esp + 4: row, esp + 8: column
pos_map:
    mov eax, 320
    mul dword [esp + 4]
    mov ebx, eax
    mov eax, [esp + 8]
    mov ecx, 4
    mul ecx
    add eax, ebx
    ;add eax, 3; if the character is the last byte
    ret



;esp + 4:string
;esp + 8:map
;esp + 12: string.length
write:
    mov esi, [esp + 4]
    mov edi, [esp + 8]
    add edi, 2
    mov ecx, [esp + 12]
    mov eax, FG.RED
    ciclo:
        stosb
        movsb
        add edi, 2
        dec ecx
        cmp ecx, 0
        jne ciclo
    ret



    global present
    present:
        mov eax, 80
        push eax
        push headline
        xor eax, eax
        call string_length
        add esp, 8

        mov ecx, eax
        mov eax, 80
        push eax
        xor eax, eax
        push ecx
        call to_center
        add esp, 8
        mov ebx, eax
        mov eax, 25
        push eax
        mov eax, 3
        push eax
        xor eax, eax
        call to_center
        add esp, 8

        mov edx, eax ;row where we should start writing

        push ebx
        push edx
        call pos_map
        add esp, 8

        add eax, [esp + 4]
        push ecx
        push eax
        push headline
        call write
        add esp, 12

        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor edx, edx
        ret