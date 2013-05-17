; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
    include \masm32\include\psapi.inc
    includelib \masm32\lib\psapi.lib
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
        hProc dd ?
        ErrorCodeP DWORD ?
        bytesNeeded dd ?
        processName db ?
        hMods dd 1000 dup(?)
        fileList dword 500000 dup(?)
        MAX_ARRAY_SIZE  dd  ?

    .data
        processID DWORD 0
        countProcess DWORD 0
        countModules  DWORD   0
        position  DWORD   0
        countTmp DWORD 0

        MAX_STRING_LENGTH dd 200

    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call main
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc

    cls
    ; Init some variables
    mov     edi, 0
    mov     eax, sizeof fileList
    mov     MAX_ARRAY_SIZE, eax

GetModules:
    invoke SetLastError, 0

    ; Get the process from processID
    mov eax, 0
    invoke OpenProcess, PROCESS_ALL_ACCESS, 0, processID
    mov hProc, eax

    invoke GetLastError
    mov ErrorCodeP, eax

    .if ErrorCodeP != 0
        ;print "Error opening process", 13, 10
        jmp NoHandle
    .endif

    ; Increment the countProcess
    push    eax
    mov     eax, countProcess
    inc     eax
    mov     countProcess, eax
    pop     eax
    
    ; Get all modules of the selected process, store it in hMods array
    invoke EnumProcessModules, hProc, offset hMods, sizeof hMods, offset bytesNeeded

    invoke GetLastError
    mov ErrorCodeP, eax

    .if ErrorCodeP != 0
        ;print "Error with module handle", 13, 10
        jmp NoHandle
    .endif

    mov esi, OFFSET hMods

    mov eax, 0
    push eax
    
innerloop:
    .if     edi > MAX_ARRAY_SIZE
        print   "OUT OF MEMORY - "
        print   str$(edi), 13, 10
        jmp     interloop
    .endif

    cmp     DWORD PTR [esi], NULL
    jz      interloop
    invoke  GetModuleFileNameEx, hProc, [esi], addr fileList[edi], 100

    ;print   addr fileList[edi], 13, 10

    add     esi, DWORD
    pop     eax
    inc     eax
    push    eax
    
    imul    eax, 4
    .if     eax >= bytesNeeded
        jmp interloop
    .endif 

    ;   Increment countModules
    mov     eax,    countModules
    inc     eax
    mov     countModules, eax
    ;   Increment edi counter
    add     edi,    MAX_STRING_LENGTH
    jmp     innerloop
    
interloop:
    pop eax
    
NoHandle:
    mov     eax,    processID
    inc     eax
    mov     processID, eax   

    mov     hProc,  0
    mov     hMods,  0
    mov     bytesNeeded, 0

    .if     edi > MAX_ARRAY_SIZE
        print "OUT OF MEMORY 2",13,10
        jmp ShowResult
    .endif

    .if processID < 100000
        jmp GetModules
    .endif

ShowResult: ; Testing purpose only, we can remove it in integration
    mov     edi, 0
    mov     ecx, 0
    .WHILE  ecx < countModules
        push    ecx
        mov     eax,    ecx
        print   str$(eax)
        print   "-"
        print   addr fileList[edi],13, 10
        pop     ecx
        
        add     edi, MAX_STRING_LENGTH
        inc     ecx
    .ENDW

    print   str$(countProcess), 13, 10
    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
