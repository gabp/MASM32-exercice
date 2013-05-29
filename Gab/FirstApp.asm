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
        buffer dd 100 dup(?)


        ;;;;;;DriveWalk;;;;;;
        
        fileData WIN32_FIND_DATA <>
        hFile HANDLE ?
        ErrorCode DWORD ?     
        CurrentDirectory db ?

        ;;;;;;ProcessWalk;;;;

        hProc dd ?
        ErrorCodeP DWORD ?
        bytesNeeded dd ?
        fileName db 500 dup(?)
        processName db 100 dup(?)
        hMods dd 500 dup(?)


    .data
        processWalk db "pw",0
        driveWalk db "dw",0

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

        ;;;;;ProcessWalk;;;;;

        processID DWORD 0 
        
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
   .while 1
       cls
       print "Process Walk (pw) / Drive Walk (dw): "
       invoke crt_gets, addr buffer
   
       invoke lstrcmp, addr buffer, addr processWalk
   
       .if eax == 0
           call processWalk1
           inkey
       .else
           invoke lstrcmp, addr buffer, addr driveWalk
           .if eax == 0
               call driveWalk1
               inkey
           .endif        
       .endif
   .endw
    ret
main endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

driveWalk1 proc

    ;cls
    invoke  lstrcpy, addr array[0], addr backslash
    invoke  GetCurrentDirectory, 0, 00h
    invoke  GetCurrentDirectory, eax, addr CurrentDirectory
    print   " ", 13, 10
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
                ;print   addr CurrentDirectory
                ;mov     edx, index
                ;print   addr array[edx]
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
    pop   eax
    ret

driveWalk1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processWalk1 proc

    cls
    mov processID, 0
GetModules:
    invoke SetLastError, 0
    
    mov eax, 0
    invoke OpenProcess, PROCESS_ALL_ACCESS, 0, processID
    mov hProc, eax

    invoke GetLastError
    mov ErrorCodeP, eax

    .if ErrorCodeP != 0
        ;print "Error opening process", 13, 10
        jmp NoHandle
    .endif
    
    invoke EnumProcessModules, hProc, offset hMods, sizeof hMods, offset bytesNeeded

    invoke GetLastError
    mov ErrorCodeP, eax

    .if ErrorCodeP != 0
        ;print "Error with module handle", 13, 10
        jmp NoHandle
    .endif

    mov esi, OFFSET hMods

    invoke GetModuleBaseName, hProc, 0, addr processName, sizeof processName
    print addr processName, 13, 10

    mov eax, 0
    push eax
   innerloop:
     cmp DWORD PTR [esi], NULL
     jz interloop
     invoke GetModuleFileNameEx, hProc, [esi], ADDR fileName, SIZEOF fileName
     print "   "
     print addr fileName, 13, 10
     add esi, DWORD
     pop eax
     inc eax
     push eax

    imul eax, 4
     .if eax >= bytesNeeded
        jmp interloop
     .endif 
     jmp innerloop
   interloop:

    pop eax
    
NoHandle:
    mov eax, processID
    inc eax
    mov processID, eax   

    mov hProc, 0
    mov hMods, 0
    mov bytesNeeded, 0

    .if processID < 100000
        jmp GetModules
    .endif

    ret

processWalk1 endp


; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
