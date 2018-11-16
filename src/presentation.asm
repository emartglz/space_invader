 

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
    add eax, 3; if the character is the last byte
    ret



;esp + 4:string
;esp + 8:map
; esp + 12: string.length
write:
    mov esi, [esp + 4]
    mov edi, [esp + 8]
    mov ecx, [esp + 12]
    ciclo:
        movsb
        add edi, 3
        dec ecx
        cmp ecx, 0
        jne ciclo
    ret
