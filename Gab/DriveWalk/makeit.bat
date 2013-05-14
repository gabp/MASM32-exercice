@echo off

    if exist "DriveWalk.obj" del "DriveWalk.obj"
    if exist "DriveWalk.exe" del "DriveWalk.exe"

    \masm32\bin\ml /c /coff "DriveWalk.asm"
    if errorlevel 1 goto errasm

    \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "DriveWalk.obj"
    if errorlevel 1 goto errlink
    dir "DriveWalk.*"
    goto TheEnd

  :errlink
    echo _
    echo Link error
    goto TheEnd

  :errasm
    echo _
    echo Assembly Error
    goto TheEnd
    
  :TheEnd

pause
