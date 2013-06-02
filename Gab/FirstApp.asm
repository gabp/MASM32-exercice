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

        ;;;;;;Imports/Exports;;;;;;;

        ;hFile dd ?
        hMapping dd ?
        pMapping dd ?
        ;bufferIE dd 10000 dup(?)
        temp dd 512 dup(?)
        numberOfNames dd ?
        base dd ?
        
    .data
        processWalk db "pw",0
        driveWalk db "dw",0
        choice1 db "1",0
        choice2 db "2",0

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

        ;;;;;Imports/Exports;;;;;

        bcnt dd 10000
        var dd ?
        NameTemplate db "  %s",0 
        OrdinalTemplate db "  %u",0 
        fileNameIE dd 200 dup (0)
        clear dd 200 dup (0)
    
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
       print "-------------------------------------",13,10
       print "Process Walk (pw) / Drive Walk (dw): "
       invoke StdIn, addr buffer, sizeof buffer
   
       invoke lstrcmp, addr buffer, addr processWalk
   
       .if eax == 0
           call processWalk1
           call menu
       .else
           invoke lstrcmp, addr buffer, addr driveWalk
           .if eax == 0
               call driveWalk1
               call menu
           .endif   
       .endif
   .endw
    ret
main endp

menu proc
    print   "------------------------------------------",13,10
    print   "1 - copy imports/exports of API 1 in API 2", 13, 10
    print   "2 - parse imports/exports of a file", 13, 10
    print   "choice (1,2): "
    invoke  StdIn, addr buffer, sizeof buffer

    print   "------------------------------------------",13,10
    
    invoke lstrcmp, addr buffer, addr choice1
    .if eax == 0 ;choice1
        print   "Currently not available.", 13, 10
    .endif
    invoke lstrcmp, addr buffer, addr choice2
    .if eax == 0 ;choice2
        print   "File path: "
        invoke  StdIn, addr buffer, sizeof buffer
        invoke  lstrcpy, addr fileNameIE, addr clear
        invoke  lstrcpy, addr fileNameIE, addr buffer
        print   "1 - Parse imports",13,10
        print   "2 - Parse exports",13,10
        print   "choice (1,2):"
        invoke  StdIn, addr buffer, sizeof buffer
        call    ParseImportsExports
    .endif

    ret
menu endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

driveWalk1 proc

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
    pop   eax
    ret

driveWalk1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processWalk1 proc

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


RVAToOffset PROC uses edi esi edx ecx pFileMap:DWORD,RVA:DWORD 
   mov esi,pFileMap 
   assume esi:ptr IMAGE_DOS_HEADER 
   add esi,[esi].e_lfanew 
   assume esi:ptr IMAGE_NT_HEADERS 
   mov edi,RVA ; edi == RVA 
   mov edx,esi 
   add edx,sizeof IMAGE_NT_HEADERS 
   mov cx,[esi].FileHeader.NumberOfSections 
   movzx ecx,cx 
   assume edx:ptr IMAGE_SECTION_HEADER 
   .while ecx>0 ; check all sections 
     .if edi>=[edx].VirtualAddress 
       mov eax,[edx].VirtualAddress 
       add eax,[edx].SizeOfRawData 
       .if edi<eax ; The address is in this section 
         mov eax,[edx].VirtualAddress 
         sub edi,eax
         mov eax,[edx].PointerToRawData 
         add eax,edi ; eax == file offset 
         ret 
       .endif 
     .endif 
     add edx,sizeof IMAGE_SECTION_HEADER 
     dec ecx 
   .endw 
   assume edx:nothing 
   assume esi:nothing 
   mov eax,edi 
   ret 
RVAToOffset endp 

ShowTheImports proc uses esi ecx ebx pNTHdr:DWORD
    mov edi, pNTHdr
    assume edi:ptr IMAGE_NT_HEADERS
    mov edi, [edi].OptionalHeader.DataDirectory[sizeof IMAGE_DATA_DIRECTORY].VirtualAddress
    invoke RVAToOffset, pMapping, edi
    mov edi, eax
    add edi, pMapping
    assume edi:ptr IMAGE_IMPORT_DESCRIPTOR
    .while !([edi].OriginalFirstThunk==0 && [edi].TimeDateStamp==0 && [edi].ForwarderChain==0 && [edi].Name1==0 && [edi].FirstThunk==0) 
      invoke RVAToOffset, pMapping, [edi].Name1
      mov edx,eax 
      add edx,pMapping
      pushad
      print edx, 13, 10
      popad
 
      .if [edi].OriginalFirstThunk==0 
         mov esi,[edi].FirstThunk 
      .else 
         mov esi,[edi].OriginalFirstThunk 
      .endif
 
      invoke RVAToOffset,pMapping,esi 
      add eax,pMapping 
      mov esi,eax
 
      .while dword ptr [esi]!=0 
         test dword ptr [esi],IMAGE_ORDINAL_FLAG32 
         jnz ImportByOrdinal 
         invoke RVAToOffset,pMapping,dword ptr [esi] 
         mov edx,eax 
         add edx,pMapping 
         assume edx:ptr IMAGE_IMPORT_BY_NAME 
         mov cx, [edx].Hint 
         movzx ecx,cx 
         invoke wsprintf,addr temp,addr NameTemplate,addr [edx].Name1 
         jmp ShowTheText 
  ImportByOrdinal: 
         mov edx,dword ptr [esi] 
         and edx,0FFFFh 
         invoke wsprintf,addr temp,addr OrdinalTemplate,edx  
  ShowTheText: 
         pushad
         print addr temp, 13, 10
         popad
         add esi,4 
      .endw
      add edi,sizeof IMAGE_IMPORT_DESCRIPTOR
    .endw
    ret
ShowTheImports endp


ShowTheExports proc uses esi ecx ebx pNTHdr:DWORD
    mov edi, pNTHdr
    assume edi:ptr IMAGE_NT_HEADERS
    mov edi, [edi].OptionalHeader.DataDirectory.VirtualAddress   
    .if edi==0 
      print "No exports.", 13, 10 
      ret 
    .endif 
    
    invoke RVAToOffset, pMapping, edi
    mov edi, eax
    add edi, pMapping

    assume edi:ptr IMAGE_EXPORT_DIRECTORY

    invoke RVAToOffset, pMapping, [edi].nName
    mov edx, eax
    add edx, pMapping
    print edx, 13, 10 ;print name of module

    push [edi].NumberOfNames
    pop numberOfNames

    invoke RVAToOffset,pMapping,[edi].AddressOfNames 
    mov esi,eax 
    add esi, pMapping

    .while numberOfNames > 0
        invoke RVAToOffset,pMapping,dword ptr [esi] 
        add eax, pMapping
        
        pushad
          invoke wsprintf,addr temp,addr NameTemplate,eax
          print addr temp, 13, 10
        popad

        dec numberOfNames
        add esi, 4
    .endw
  ret
ShowTheExports endp



ParseImportsExports proc

    invoke CreateFile,addr fileNameIE,GENERIC_READ,NULL,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL ;ouverture du fichier
    .if eax != INVALID_HANDLE_VALUE
      mov hFile, eax
      invoke CreateFileMapping, hFile, NULL, PAGE_READONLY,0,0,0  ;cree un objet de type fileMap
      .if eax != NULL
        mov hMapping, eax
        invoke MapViewOfFile,hMapping,FILE_MAP_READ,0,0,0   ;load l'objet de type fileMap dans la plage d'addresse de notre process
        .if eax!=NULL 
          mov pMapping,eax
          mov edi, pMapping
          assume edi:ptr IMAGE_DOS_HEADER
          .if [edi].e_magic==IMAGE_DOS_SIGNATURE  ;if MZ (== exe ou dll)
            add edi, [edi].e_lfanew 
            assume edi:ptr IMAGE_NT_HEADERS
            .if [edi].Signature==IMAGE_NT_SIGNATURE
                push edi
                invoke lstrcmp, addr buffer, addr choice1
                .if eax == 0; (i)mports
                  pop edi
                  push edi
                  invoke ShowTheImports, edi
                  invoke CloseHandle, hFile
                  invoke CloseHandle, hMapping
                .endif
                invoke lstrcmp, addr buffer, addr choice2
                .if eax == 0; (e)xports
                  pop edi
                  push edi
                  invoke ShowTheExports, edi
                  invoke CloseHandle, hFile
                  invoke CloseHandle, hMapping
                .endif
                pop edi
            .endif
          .endif
        .endif
      .endif
    .elseif
      print "Could not open "
      print addr fileNameIE, 13, 10
    .endif

    ret

ParseImportsExports endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
