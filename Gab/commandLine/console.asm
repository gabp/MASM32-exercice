; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
      value dd ?
      nbrChars DWORD ?
      fileData WIN32_FIND_DATA <>
      fileName BYTE 100 dup(?)

      hFile HANDLE ?
      ErrorCode DWORD ?
      array BYTE 1 DUP (?)
      CurrentDirectory LPTSTR ?
      
    .data
      item dd 0
      TempDirectory BYTE "\", 0
      FindFirstFileError BYTE "FindFirstFile() failed with code %d", 0
      fileTypeAll BYTE "*", 0
      backslash BYTE "\", 0
      tmp BYTE " ", 0
      null BYTE 00h, 0
      
      
    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call main
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc

    cls
    invoke lstrcpy, addr array[0], addr backslash
    invoke lstrcat, addr array[0], addr null
    invoke GetCurrentDirectory, 0, 00h
    invoke GetCurrentDirectory, eax, addr CurrentDirectory
    print addr CurrentDirectory, 13, 10
    print "-----------------------------", 13, 10

FindDirectories:
    invoke lstrcpy, addr tmp, addr CurrentDirectory
    invoke lstrcat, addr tmp, addr TempDirectory
    invoke lstrcat, addr tmp, addr fileTypeAll

    invoke FindFirstFile, addr tmp, addr fileData    

    mov hFile, eax
    mov ecx, 0
    push ecx ;number of elem in array
    mov edx, 0

    .while ErrorCode != ERROR_NO_MORE_FILES
        .if fileData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
            .if fileData.cFileName != 46

                    pop ecx
                    push ecx
                    invoke lstrcpy, addr tmp, addr array[edx]
                    ;print addr tmp, 13, 10
                    invoke lstrcat, addr tmp, addr fileData.cFileName
                    ;print addr tmp, 13, 10
                    pop ecx
                    push ecx
                    invoke lstrcpy, addr array[ecx], addr tmp

                    pop ecx
                    push ecx
                    print addr array[ecx], 13, 10

                    pop ecx
                    inc ecx
                    push ecx
            .endif
        .endif
        invoke FindNextFile, hFile, addr fileData
        
        invoke  GetLastError
        mov     ErrorCode, eax
    .endw
print "-----------------------------", 13, 10
    print addr array[0], 13, 10
    print "-----------------------------", 13, 10
    pop ecx
    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
