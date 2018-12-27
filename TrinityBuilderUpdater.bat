@echo off
"%CD%\Tools\wget" --no-check-certificate https://raw.githubusercontent.com/conan513/TrinityBuilder/master/TrinityBuilder.bat
del "%CD%\Tools\TrinityBuilder.bat"
move "TrinityBuilder.bat.1" "%CD%\Tools\TrinityBuilder.bat"
cls
"%CD%\Tools\TrinityBuilder.bat"
