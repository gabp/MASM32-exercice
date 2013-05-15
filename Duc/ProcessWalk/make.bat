@echo off

    if exist "ProcessWalk.obj" del "ProcessWalk.obj"
    if exist "ProcessWalk.exe" del "ProcessWalk.exe"

    \masm32\bin\ml /c /coff "ProcessWalk.asm"
    if errorlevel 1 goto errasm

    \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "ProcessWalk.obj"
    if errorlevel 1 goto errlink
    dir "ProcessWalk.*"
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
