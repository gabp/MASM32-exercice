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

        ;;;;;;DriveWalk;;;;;;
        
        fileData WIN32_FIND_DATA <>
        hFile HANDLE ?
        ErrorCode DWORD ?     
        CurrentDirectory db ?

        ;;;;;;;;;;;;;;;;;;;;;

    .data
        processString byte  "ProcessWalk",0
        driveString   byte  "DriveWalk",0

        ;;;;;;DriveWalk;;;;;;

        index dd 0
        fileTypeAll BYTE "*", 0
        fileTypeExe BYTE "*.exe", 0
        fileTypeDll BYTE "*.dll", 0
        printExe dd 1
        printDll dd 1
        done dd 0
        backslash BYTE "\", 0
        tmp BYTE 10000 dup(0)
        array BYTE 100000 DUP (0)
        filePathSize dd 100
        counter dd 0
        nbrElem dd 0

        ;;;;;;;;;;;;;;;;;;;;;
        
    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    ;call init
    call main
    print "Exit Program",13,10
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc
    call    init
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
        ;print   "Put your driveWalk code here", 13, 10
        call driveWalk1
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

driveWalk1 proc

    ;cls
    invoke  lstrcpy, addr array[0], addr backslash
    invoke  GetCurrentDirectory, 0, 00h
    invoke  GetCurrentDirectory, eax, addr CurrentDirectory
    print   addr CurrentDirectory, 13, 10
    print   "---------------------------------------", 13, 10

    mov edx, 0
    mov counter, edx   
    mov ecx, 1
    mov nbrElem, ecx

FindDirectories:

    invoke  lstrcpy, addr tmp, addr CurrentDirectory
    mov     eax, counter
    mov     edx, filePathSize
    imul    edx, eax
    invoke  lstrcat, addr tmp, addr array[edx]
    invoke  lstrcat, addr tmp, addr fileTypeAll

    invoke  FindFirstFile, addr tmp, addr fileData    
    mov     hFile, eax

    invoke  GetLastError
    mov     ErrorCode, eax
    
    .while ErrorCode != ERROR_NO_MORE_FILES
        .if fileData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
            .if fileData.cFileName != 46
                    mov     edx, counter
                    mov     eax, filePathSize
                    imul    eax, edx
 
                    invoke  lstrcpy, addr tmp, addr array[eax]
                    
                    invoke  lstrcat, addr tmp, addr fileData.cFileName
                    invoke  lstrcat, addr tmp, addr backslash

                    mov     ecx, nbrElem
                    mov     eax, filePathSize
                    imul    eax, ecx
                    invoke  lstrcpy, addr array[eax], addr tmp

                    mov     ecx, nbrElem
                    inc     ecx
                    mov     nbrElem, ecx
            .endif
        .endif
        
        invoke  FindNextFile, hFile, addr fileData      
        invoke  GetLastError
        mov     ErrorCode, eax
    .endw
    
    invoke  FindClose, hFile
    invoke  SetLastError, 0
    
    mov     eax, counter
    inc     eax
    mov     counter, eax
    mov     ecx, nbrElem

    .if eax < ecx
        jmp FindDirectories
    .endif

GoThroughArray:
    mov     ecx, nbrElem
    mov     eax, 0
    push    eax
    
    .while eax < ecx   
notDoneYet:        
        invoke  lstrcpy, addr tmp, addr CurrentDirectory
        pop     eax
        push    eax
        mov     edx, filePathSize
        imul    edx, eax  
        mov     index, edx   
        invoke  lstrcat, addr tmp, addr array[edx]

        .if printExe == 1
            invoke  lstrcat, addr tmp, addr fileTypeDll
            mov     printExe, 0
        .elseif printDll == 1
            invoke  lstrcat, addr tmp, addr fileTypeExe
            mov     printDll, 0
        .else
            mov     done, 1
        .endif

        invoke  FindFirstFile, addr tmp, addr fileData
        mov     hFile, eax
        
        invoke  GetLastError
        mov     ErrorCode, eax

        .if ErrorCode == 0
            .while ErrorCode == 0
                print   addr CurrentDirectory
                mov     edx, index
                print   addr array[edx]
                print   addr fileData.cFileName, 13, 10
                
                invoke  FindNextFile, hFile, addr fileData

                invoke  GetLastError
                mov     ErrorCode, eax
            .endw
        .endif

        invoke  FindClose, hFile
        invoke  SetLastError, 0

        .if done == 0        
            jmp notDoneYet
        .endif

        mov     printExe, 1
        mov     printDll, 1
        mov     done, 0
        
        pop     eax
        inc     eax
        push    eax
        mov     ecx, nbrElem
    .endw

    print " ", 13, 10
    print "***********************", 13, 10
    print "* Done getting files! *", 13, 10
    print "***********************", 13, 10

    pop   eax
    ret

driveWalk1 endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
