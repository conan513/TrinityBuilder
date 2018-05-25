@echo off
%CD%\Tools\wget --no-check-certificate https://raw.githubusercontent.com/conan513/TrinityBuilder/master/TrinityBuilder.bat
del Tools\TrinityBuilder.bat
move TrinityBuilder.bat.1 Tools\TrinityBuilder.bat
cls
%CD%\Tools\TrinityBuilder.bat
