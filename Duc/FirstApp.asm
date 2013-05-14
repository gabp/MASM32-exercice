; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
    
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
      value dd ?
        CommandLine LPSTR ?
        pArrayCount DWORD ?
        pArrayOrigin LPSTR ?
        tmpString LPSTR ?

    .data
        item dd 0
        i BYTE 41h, 0
        testArray dword 10 dup(53)
        argv dword "ducd","abc", "abc", "abc"

    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    call main
    print "Exit Program",13,10
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc

    cls
    print "Start Main function",13,10

    invoke GetCommandLine  ;get CommandLine
    mov CommandLine, eax
    invoke StdOut, CommandLine

    ; print a linebreak
    mov eax, 0ah
    push eax
    invoke StdOut, esp
    pop eax
    
    ;---------------------------------------------------------------------------;

    ; parse commandline - FAILED
    invoke CommandLineToArgvW, CommandLine, addr pArrayCount
    mov pArrayOrigin, eax
    print str$(pArrayCount)

    ; print a linebreak
    mov eax, 0ah
    push eax
    invoke StdOut, esp
    pop eax

    ;---------------------------------------------------------------------------;

    ; iterate through array
    argc EQU LENGTHOF argv ; length of argument list
    push ecx
    mov ecx, 0
        .while ecx < argc
        push ecx
        mov ecx, argv[ecx]
        invoke dwtoa, ecx, addr tmpString
        invoke StdOut, offset tmpString
        print "end",13,10
        pop ecx
        add ecx, 1
    .endw
    pop ecx

    ;mov ecx, testArray[0]
    ;invoke dwtoa, ecx, addr tmpString
    ;invoke StdOut, offset tmpString

    

    

    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
