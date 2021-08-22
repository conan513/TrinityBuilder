@echo off
:start
SET mainfolder=%CD%
SET msbuildpath="%mainfolder%\Tools\VisualStudio\MSBuild\Current\Bin\msbuild.exe"
SET cmake=3.21.1
set database=MySQL-5.7.35
set database_lib=libmysql
set openssl=1.1.0
SET BOOST_ROOT="%mainfolder%\Tools\boost"
SET BOOST_LIBRARYDIR="%mainfolder%\Tools\boost\lib64-msvc-14.2"
SET boost_INCLUDE_DIR="%mainfolder%\Tools\boost"
set "GIT_EXEC_PATH=%mainfolder%\tools\Git\bin"
SET dynamic_linking=0
set sourcepath=AzerothCore
set repo=https://github.com/azerothcore/azerothcore-wotlk.git
set branch=master
set arch=
set archpath=Win64

:beginning
cd "%mainfolder%"
mkdir"%mainfolder%\Tools\modules"
mkdir "%mainfolder%\Repack"
mkdir "%mainfolder%\Repack\Database"
mkdir "%mainfolder%\Repack\dbc"
mkdir "%mainfolder%\Repack\maps"
mkdir "%mainfolder%\Repack\vmaps"
mkdir "%mainfolder%\Repack\mmaps"
mkdir "%mainfolder%\Repack\lua_scripts"
mkdir "%mainfolder%\Repack\modules_sql"
mkdir "%mainfolder%\Repack\configs"
mkdir "%mainfolder%\Repack\configs\modules"

if not exist Build mkdir Build
if not exist Source mkdir Source

if exist "%mainfolder%\Tools\VisualStudio\MSBuild\Current\Bin\MSBuild.exe" goto git_clone
if not exist %msbuildpath% goto install_vs_community
goto git_clone

:install_vs_community
cls
"%CD%\Tools\vs_community.exe" -p --installPath "%CD%\Tools\VisualStudio" --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended
echo.
echo Restart the tool when the install is done.
ping -n 10 127.0.0.1>nul
exit

goto git_clone

:git_clone
cls
if exist "%mainfolder%\Source\%sourcepath%\README.md" goto git_pull
echo Get the source from %repo% %branch%
echo.
"%GIT_EXEC_PATH%\git.exe" clone %repo% "%mainfolder%/Source/%sourcepath%"
goto git_clone_finish

:git_clone_branch
"%GIT_EXEC_PATH%\git.exe" clone %repo% --single-branch -b %branch% "%mainfolder%/Source/%sourcepath%"
goto git_clone_finish

:git_clone_finish
echo.
echo Downloading submodules if available...
echo.
cd "%mainfolder%\Source\%sourcepath%"
"%GIT_EXEC_PATH%\git.exe" submodule update --init --recursive
cd "%mainfolder%"
goto git_pull

:git_pull
echo.
echo Pull the commits from %repo% %branch%
echo.
cd "%mainfolder%\Source\%sourcepath%"
"%GIT_EXEC_PATH%\git.exe" pull %repo%
goto git_pull_finish

:git_pull_branch
"%GIT_EXEC_PATH%\git.exe" pull %repo% %branch%
goto git_pull_finish

:git_pull_finish
echo.
echo Updating submodules if available...
echo.
"%GIT_EXEC_PATH%\git.exe" submodule update --init --recursive
"%GIT_EXEC_PATH%\git.exe" submodule update --recursive --remote
goto menu

:menu
"%GIT_EXEC_PATH%\git.exe" config --global user.name "SPP User"
"%GIT_EXEC_PATH%\git.exe" config --global user.email spp-user@spp-forum.de
cd "%mainfolder%"
if exist "%mainfolder%\Source\%sourcepath%\SoloLFG.txt" set sololfg_status=Installed
if not exist "%mainfolder%\Source\%sourcepath%\SoloLFG.txt" set sololfg_status=Not installed
if exist "%mainfolder%\Source\%sourcepath%\Robot_and_Marketer.txt" set robot_status=Installed
if not exist "%mainfolder%\Source\%sourcepath%\Robot_and_Marketer.txt" set robot_status=Not installed
cls
echo #######################################################
echo # Single Player Project - %sourcepath% repack builder
echo # https://singleplayerproject.com
echo #######################################################
echo.
echo 1 - Start the build process
echo 2 - Open the modules folder
echo 0 - Delete local %sourcepath% source (reinstall)
echo.
REM echo ---[ CUSTOM STUFF ]---
REM echo.
REM echo 3 - SoloLFG                                (%sololfg_status%)
REM echo 4 - Robot and Marketer bots from jokerlfm  (%robot_status%)
REM echo.
set /P choose_menu=Choose a number: 
if "%choose_menu%"=="1" (goto build)
if "%choose_menu%"=="2" (goto open_modules)
REM if "%choose_menu%"=="3" (goto install_sololfg)
REM if "%choose_menu%"=="4" (goto install_robot)
if "%choose_menu%"=="0" (goto reinstall_source)
if "%choose_menu%"=="B" (goto build)
if "%choose_menu%"=="" (goto menu)
goto open_modules

:install_sololfg
set module_name=SoloLFG
if exist "%mainfolder%\Source\%sourcepath%\%module_name%.txt" goto module_installed
cd "%mainfolder%\Source\%sourcepath%"
cls
echo Downloading %module_name% source into %sourcepath%...
echo.
"%GIT_EXEC_PATH%\git.exe" fetch https://github.com/SinglePlayerProject/azerothcore-wotlk.git lfg.solomode
"%GIT_EXEC_PATH%\git.exe" cherry-pick d89092f148c0623f665d8285334df33c492d593a
echo.
echo %module_name% mode added into %sourcepath%.
echo %module_name%>"%mainfolder%\Source\%sourcepath%\%module_name%.txt"
echo.
ping -n 5 127.0.0.1>nul
goto menu

:install_robot
set module_name=Robot_and_Marketer
if exist "%mainfolder%\Source\%sourcepath%\%module_name%.txt" goto module_installed
cd "%mainfolder%\Source\%sourcepath%"
cls
echo Downloading %module_name% source into %sourcepath%...
echo.
"%GIT_EXEC_PATH%\git.exe" pull https://github.com/jokerlfm/azerothcore-wotlk.git
echo.
echo %module_name% mode added into %sourcepath%.
echo %module_name%>"%mainfolder%\Source\%sourcepath%\%module_name%.txt"
echo.
ping -n 5 127.0.0.1>nul
goto menu

:module_installed
cls
echo %module_name% code already included in the local %sourcepath% code.
echo.
ping -n 5 127.0.0.1>nul
goto menu

:reinstall_source
cls
echo Deleting the local %sourcepath% source...
echo.
rmdir /Q /S "%mainfolder%\Source\%sourcepath%"
echo.
echo %sourcepath% source deleted, starting download the fresh source...
echo.
ping -n 5 127.0.0.1>nul
goto beginning

:open_modules
start "" https://www.azerothcore.org/catalogue.html
cls
echo Copy %sourcepath% module folders here.
echo.
explorer "%mainfolder%\Source\%sourcepath%\modules"
ping -n 10 127.0.0.1>nul
goto menu

:build
cls
echo Do you want to build the core?
echo.
echo 1 - Build
echo 0 - Skip
echo.
set /P choose_menu=Choose a number: 
if "%choose_menu%"=="1" (goto build_yes)
if "%choose_menu%"=="0" (goto copy_conf)
if "%choose_menu%"=="" (goto build)

:build_yes
echo.
set /P cpu_cores=How many CPU core(s) you want to use for compile: 
cls
echo Prepare to build process...
echo Servers shutting down...
echo.
taskkill /f /im authserver.exe
taskkill /f /im worldserver.exe
"%mainfolder%\Tools\database\%database%-%archpath%\bin\mysqladmin.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" shutdown
rmdir /Q /S "%mainfolder%\Build"
mkdir "%mainfolder%\Build\%sourcepath%_%archpath%"
cd "%mainfolder%\Build\%sourcepath%_%archpath%"
echo.
echo Checking core to create compatible cmake options...
echo.
if exist "%mainfolder%\Source\%sourcepath%\contrib\sunstrider\generate_script_loader.php" SET dynamic_linking=0
echo.
echo Generate cmake...
echo.
"%mainfolder%\Tools\cmake\%cmake%\bin\cmake.exe" "%mainfolder%/Source/%sourcepath%" -G "Visual Studio 16 2019%arch%" -DBoost_DIR="%mainfolder%\Tools\boost" -DBoost_INCLUDE_DIR="%mainfolder%\Tools\boost" -DOPENSSL_ROOT_DIR="%mainfolder%/Tools/openssl/%openssl%-%archpath%" -DOPENSSL_INCLUDE_DIR="%mainfolder%/Tools/openssl/%openssl%-%archpath%/include" -DMYSQL_LIBRARY="%mainfolder%/Tools/database/%database%-%archpath%/lib/%database_lib%.lib" -DMYSQL_INCLUDE_DIR="%mainfolder%/Tools/database/%database%-%archpath%/include" -DGIT_EXECUTABLE="%mainfolder%/Tools/Git/bin/git.exe" -DTOOLS=1 -DPLAYERBOT=1 -DPLAYERBOTS=1 -DBUILD_EXTRACTORS=1 -DWITH_CPR=1 -DSCRIPTS=static
echo.
echo Start building...
echo.
%msbuildpath% /p:CL_MPCount=%cpu_cores% ALL_BUILD.vcxproj /p:Configuration=Release
echo.
echo Copy required dll files into bin folder
copy "%mainfolder%\Tools\database\%database%-%archpath%\lib\%database_lib%.dll" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release"
copy "%mainfolder%\Tools\openssl\%openssl%-%archpath%\*.dll" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release"
echo.
pause
cls
REM if not exist "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\authserver.conf" goto copy_conf
goto finalize

:copy_conf
REM copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf.dist" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf"
REM copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf"
REM copy "%mainfolder%\Source\%sourcepath%\src\server\game\Robot\robot.conf" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\robot.conf"
REM copy "%mainfolder%\Source\%sourcepath%\src\server\game\\Marketer\marketer.conf" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\marketer.conf"
goto finalize

:finalize
echo Setup databse and modifying config files...
echo
type "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf.dist" | "%mainfolder%\Tools\repl.bat" "127.0.0.1;3306;acore;acore;acore_auth" "127.0.0.1;3310;root;123456;acore_auth" > "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf.dist1"
type "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf.dist1" | "%mainfolder%\Tools\repl.bat" "Updates.EnableDatabases = 1" "Updates.EnableDatabases = 0" > "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf"

type "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist" | "%mainfolder%\Tools\repl.bat" "127.0.0.1;3306;acore;acore;acore_auth" "127.0.0.1;3310;root;123456;acore_auth" > "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist1"
type "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist1" | "%mainfolder%\Tools\repl.bat" "127.0.0.1;3306;acore;acore;acore_world" "127.0.0.1;3310;root;123456;acore_world" > "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist2"
type "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist2" | "%mainfolder%\Tools\repl.bat" "127.0.0.1;3306;acore;acore;acore_characters" "127.0.0.1;3310;root;123456;acore_characters" > "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist3"
type "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist3" | "%mainfolder%\Tools\repl.bat" "Updates.EnableDatabases = 7" "Updates.EnableDatabases = 0" > "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf"


echo @echo off>"%mainfolder%\Repack\Database.bat"
REM echo set mainfolder=%CD%>>"%mainfolder%\Repack\Database.bat"
REM echo "%mainfolder%\Database\bin\mysqld" --defaults-file="%mainfolder%\Database\SPP-Database.ini" --console --standalone --log_syslog=0 --explicit_defaults_for_timestamp --sql-mode="">>"%mainfolder%\Repack\Database.bat"
echo "Database\bin\mysqld" --defaults-file="Database\SPP-Database.ini" --console --standalone --log_syslog=0 --explicit_defaults_for_timestamp --sql-mode="">>"%mainfolder%\Repack\Database.bat"
echo exit>>"%mainfolder%\Repack\Database.bat"

cls
echo Starting the database server...
if exist "%mainfolder%\Repack\Database\share\bulgarian\errmsg.sys" goto finalize_db
xcopy /s "%mainfolder%\Tools\database\%database%-%archpath%" "%mainfolder%\Repack\Database"
goto finalize_db

:finalize_db
cd "%mainfolder%\Repack"
start /MIN "" "%mainfolder%\Repack\Database.bat"
ping -n 10 127.0.0.1>nul
goto db_select

:db_select
cls
echo What do you want to do with the database: 
echo.
echo 1 - Wipe and install the fresh database
echo 2 - Install only the updates
echo.
echo 0 - Do nothing
echo.
set /P database_choose=Select a number: 
if "%database_choose%"=="1" (goto database_creation)
if "%database_choose%"=="2" (goto database_updates)
if "%database_choose%"=="0" (goto finish)
if "%database_choose%"=="" (goto db_select)

:database_creation
cls
echo Starting and setup the database...
echo.

"%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 < "%mainfolder%\Repack\Database\create_database.sql"
for %%i in ("%mainfolder%\Source\%sourcepath%\data\sql\base\db_auth\*sql") do if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_auth\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_auth\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_auth\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_auth < %%i
for %%i in ("%mainfolder%\Source\%sourcepath%\data\sql\base\db_characters\*sql") do if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_characters\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_characters\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_characters\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_characters < %%i
for %%i in ("%mainfolder%\Source\%sourcepath%\data\sql\base\db_world\*sql") do if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_world\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_world\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\base\db_world\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_world < %%i
goto database_updates

:database_updates
echo.
echo Installing database updates...
echo.
for %%i in ("%mainfolder%\Source\%sourcepath%\data\sql\updates\db_auth\*sql") do if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_auth\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_auth\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_auth\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_auth < %%i
for %%i in ("%mainfolder%\Source\%sourcepath%\data\sql\updates\db_characters\*sql") do if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_characters\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_characters\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_characters\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_characters < %%i
for %%i in ("%mainfolder%\Source\%sourcepath%\data\sql\updates\db_world\*sql") do if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_world\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_world\*sql" if %%i neq "%mainfolder%\Source\%sourcepath%\data\sql\updates\db_world\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_world < %%i
echo.
goto finish

:finish
set /p wow_path=<"%mainfolder%\wow_path.txt"
cd "%mainfolder%\Source\%sourcepath%\modules"
echo Collecting modules SQL files...
for /r %%d in (*.sql) do copy "%%d" "%mainfolder%\Repack\modules_sql" /Y
echo.
echo Installing modules SQL files into the database....
echo
for %%i in ("%mainfolder%\Repack\modules_sql\*sql") do if %%i neq "%mainfolder%\Repack\modules_sql\*sql" if %%i neq "%mainfolder%\Repack\modules_sql\*sql" if %%i neq "%mainfolder%\Repack\modules_sql\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_auth < %%i
for %%i in ("%mainfolder%\Repack\modules_sql\*sql") do if %%i neq "%mainfolder%\Repack\modules_sql\*sql" if %%i neq "%mainfolder%\Repack\modules_sql\*sql" if %%i neq "%mainfolder%\Repack\modules_sql\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_characters < %%i
for %%i in ("%mainfolder%\Repack\modules_sql\*sql") do if %%i neq "%mainfolder%\Repack\modules_sql\*sql" if %%i neq "%mainfolder%\Repack\modules_sql\*sql" if %%i neq "%mainfolder%\Repack\modules_sql\*sql" echo %%i & "%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_world < %%i
"%mainfolder%\Tools\database\%database%-%archpath%\bin\mysql.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" --default-character-set=utf8 --database=acore_world < "%mainfolder%\Source\%sourcepath%\src\server\game\Robot\robot_names.sql"
cd "%mainfolder%"
cls
if exist "%mainfolder%\wow_path.txt" goto extract_data
echo Enter your World of Warcraft game folder path
echo to extract dbc, maps, vmaps and mmaps.
echo.
echo Example: C:\Games\World of Warcraft
echo Current WoW path: %wow_path%
echo.
set /P wow_path=Path: 
if "%wow_path%"=="" (goto finish)
goto extract_data

:wow_path_empty
cls
echo Enter your World of Warcraft game folder path
echo to extract dbc, maps, vmaps and mmaps.
echo.
echo Example: C:\Games\World of Warcraft
echo Current WoW path: %wow_path%
echo
set /P wow_path=Path: 
goto extract_data

:wow_path_wrong
cls
echo Wow.exe not found in the specified WoW path.
echo Please try to set the game path again.
echo
set /P wow_path=Path: 
goto extract_data

:extract_data
if "%wow_path%"=="" (goto wow_path_empty)
if not exist "%wow_path%\wow.exe" goto wow_path_wrong
cls
echo %wow_path%>"%mainfolder%\wow_path.txt"
echo.
echo Do you want to extract the data files from the game?
echo.
echo 1 - Extract
echo 0 - Skip
echo.
echo x - Change WoW path
echo.
set /P choose_menu=Choose a number: 
if "%choose_menu%"=="1" (goto extract_data_yes)
if "%choose_menu%"=="0" (goto end)
if "%choose_menu%"=="x" (goto wow_path_empty)
if "%choose_menu%"=="X" (goto wow_path_empty)
if "%choose_menu%"=="" (goto extract_data)

:extract_data_yes
cls
echo Extracting data files from World of Warcraft...
echo.
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\mapextractor.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\mmaps_generator.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\vmap4assembler.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\vmap4extractor.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\ace.dll" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\%database_lib%.dll" "%wow_path%" /Y
%wow_path:~0,1%:
cd "%wow_path%"
cls
mkdir dbc
mkdir maps
mkdir vmaps
mkdir mmaps
cls

:dbc_maps
if exist "%wow_path%\maps\7242732.map" goto vmaps
start /b /w mapextractor.exe

:vmaps
if exist "%wow_path%\vmaps\Zulgurubtree05.m2.vmo" goto mmaps
start /b /w vmap4extractor.exe
start /b /w vmap4assembler.exe Buildings vmaps

:mmaps
if exist "%wow_path%\mmaps\598.mmap" goto extract_finish
start /b /w mmaps_generator.exe

:extract_finish
%mainfolder:~0,1%:
cd "%mainfolder%"

xcopy /s "%wow_path%\dbc" "%mainfolder%\Repack\dbc" /Y
xcopy /s "%wow_path%\maps" "%mainfolder%\Repack\maps" /Y
xcopy /s "%wow_path%\vmaps" "%mainfolder%\Repack\vmaps" /Y
xcopy /s "%wow_path%\mmaps" "%mainfolder%\Repack\mmaps" /Y

if exist "%wow_path%\Data\enUS\realmlist.wtf" echo set realmlist 127.0.0.1>"%wow_path%\Data\enUS\realmlist.wtf"
goto end

:end
"%mainfolder%\Tools\database\%database%-%archpath%\bin\mysqladmin.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" shutdown
echo Closing database server...
echo.
echo Copy config files into the repack...
echo
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\*.dll" "%mainfolder%\Repack" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\authserver.exe" "%mainfolder%\Repack" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\worldserver.exe" "%mainfolder%\Repack" /Y
xcopy /s "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\lua_scripts" "%mainfolder%\Repack\lua_scripts" /K /D /H /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf.dist" "%mainfolder%\Repack\configs" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf.dist" "%mainfolder%\Repack\configs" /Y
echo n | copy /-y "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\authserver.conf" "%mainfolder%\Repack\configs" /Y
echo n | copy /-y "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\configs\worldserver.conf" "%mainfolder%\Repack\configs" /Y
echo n | copy /-y "%mainfolder%\Source\%sourcepath%\src\server\game\Robot\robot.conf" "%mainfolder%\Repack"
echo n | copy /-y "%mainfolder%\Source\%sourcepath%\src\server\game\\Marketer\marketer.conf" "%mainfolder%\Repack"

cd "%mainfolder%\Source\%sourcepath%\modules"
for /r %%d in (*.conf.dist) do copy  "%%d" "%mainfolder%\Repack\configs\modules" /Y
for /r %%d in (*.conf.dist) do copy  "%%d" "%mainfolder%\Repack\modules_sql" /Y
cd "%mainfolder%\Repack\modules_sql"
ren *.dist *.
cd "%mainfolder%"
echo n | copy /-y "%mainfolder%\Repack\modules_sql\*.conf" "%mainfolder%\Repack\configs\modules"
ping -n 2 127.0.0.1>nul
rmdir /Q /S "%mainfolder%\Repack\modules_sql"

:end_of_end
explorer "%mainfolder%\Repack"
exit

