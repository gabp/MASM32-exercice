; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
    
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
        CommandLine LPSTR ?
        pArrayCount DWORD ?
        pArrayOrigin LPSTR ?
        arg1 byte 12 DUP(?)     ; ProcessWalk / DriveWalk
        arg2 byte 100 DUP(?)    ; SHOULD CHANGE THIS CONSTANT 100
        arg3 byte 100 DUP(?)    ; SHOULD CHANGE THIS CONSTANT 100
        arg4 byte 7 DUP(?)      ; Import / Export

    .data
        processString byte  "ProcessWalk",0
        driveString   byte  "DriveWalk",0
        
    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    call init
    call main
    print "Exit Program",13,10
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc
    ; Compare string - Verify if we have to do Process Walk or Drive Walk
    push    esi
    push    edi
    mov     esi,offset arg1
    mov     edi,offset processString
    mov     ecx,sizeof processString
    repz    cmpsb
    pop     edi
    pop     esi
    jz      processWalk
    push    esi
    push    edi
    mov     esi,offset arg1
    mov     edi,offset driveString
    mov     ecx,sizeof driveString
    repz    cmpsb
    pop     edi
    pop     esi
    jz      driveWalk
    print   "Your first argument is not correct (DriveWalk/ProcessWalk). Please verify the syntax", 13, 10
    ret
    
    processWalk:
        print "Put your processWalk code here", 13, 10
        jmp finishWalk
            
    driveWalk: 
        print   "Put your driveWalk code here", 13, 10

    finishWalk:
    
    ; Process search and replace
    print   "This is your search String:"
    print   addr arg2,13,10
    print   "This is your replace String:"
    print   addr arg3,13,10


    ; Process import/export section
    print   "Import or export:"
    print   addr arg4,13,10
    ret
main endp


; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

; *************************************************************************
;   Function name: init
;   Description: Parse the commanline to get different arguments. 
;                   Exit the program if user put invalid parameter
; *************************************************************************
init proc

    cls

    invoke GetCommandLineW  ;get CommandLine
    mov CommandLine, eax
    
    ;---------------------------------------------------------------------------;

    ; parse commandline - FAILED
    invoke CommandLineToArgvW, CommandLine, addr pArrayCount
    mov pArrayOrigin, eax

    ; Quit programm if user dont put 4 parameters
    .IF pArrayCount != 5 
        print "The programm need 4 parameters: DriveWalk/ProcessWalk APINameSearch APINameReplace Import/Export", 13, 10
        ret
    .ENDIF

    Invoke  lstrcpy, addr arg1, cmd$(1)
    Invoke  lstrcpy, addr arg2, cmd$(2)
    Invoke  lstrcpy, addr arg3, cmd$(3)
    Invoke  lstrcpy, addr arg4, cmd$(4)

    ret
init endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
