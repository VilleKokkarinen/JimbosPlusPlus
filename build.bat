@echo off

set name=Jimbos++

xcopy /s /y .\%name%\ %Appdata%\Balatro\Mods\%name%\*

exit