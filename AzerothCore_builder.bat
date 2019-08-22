@echo off
:start
SET mainfolder=%CD%
SET msbuildpath="%mainfolder%\Tools\VisualStudio\MSBuild\15.0\Bin\msbuild.exe"
SET cmake=3.12.2
set database=MySQL-5.7.26
set database_lib=libmysql
set openssl=1.1.0
SET BOOST_ROOT="%mainfolder%\Tools\boost"
SET BOOST_LIBRARYDIR="%mainfolder%\Tools\boost\lib32-msvc-14.1"
SET GIT_EXECUTABLE="%mainfolder%\Tools\Git\bin"
SET dynamic_linking=0
set sourcepath=AzerothCore
set repo=https://github.com/azerothcore/azerothcore-wotlk.git
set branch=master
set arch=
set archpath=Win32

mkdir "%mainfolder%\Repack"
mkdir "%mainfolder%\Repack\Database"
mkdir "%mainfolder%\Repack\dbc"
mkdir "%mainfolder%\Repack\maps"
mkdir "%mainfolder%\Repack\vmaps"
mkdir "%mainfolder%\Repack\mmaps"

if not exist Build mkdir Build
if not exist Source mkdir Source

if exist "%mainfolder%\Tools\vs_ok.txt" goto git_clone
if not exist %msbuildpath% goto install_vs_community
goto git_clone

:msbuild_not_found
cls
echo MSBuild.exe not found here: 
echo %msbuildpath%
echo.
echo Do you have Visual Studio 2017 on your PC?
echo.
echo 1 - No, please install Visual Studio 2017 Community Edition (recommend)
echo 2 - Yes
echo.
set /P menu=Enter a number: 
if "%menu%"=="1" (goto install_vs_community)
if "%menu%"=="2" (goto vs_use_own)

:vs_use_own
echo using own vs2017>Tools\vs_ok.txt
goto git_clone

:install_vs_community
cls
"%CD%\Tools\vs_community.exe" -p --installPath "%CD%\Tools\VisualStudio" --add Microsoft.VisualStudio.Component.VC.Tools.14.12 --add Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended
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
"%mainfolder%\Tools\Git\bin\git.exe" clone %repo% "%mainfolder%/Source/%sourcepath%"
goto git_clone_finish

:git_clone_branch
"%mainfolder%\Tools\Git\bin\git.exe" clone %repo% --single-branch -b %branch% "%mainfolder%/Source/%sourcepath%"
goto git_clone_finish

:git_clone_finish
echo.
echo Downloading submodules if available...
echo.
cd "%mainfolder%\Source\%sourcepath%"
"%mainfolder%\Tools\Git\bin\git.exe" submodule update --init --recursive
cd "%mainfolder%"
goto git_pull

:git_pull
echo.
echo Pull the commits from %repo% %branch%
echo.
cd "%mainfolder%\Source\%sourcepath%"
"%mainfolder%\Tools\Git\bin\git.exe" pull %repo%
goto git_pull_finish

:git_pull_branch
"%mainfolder%\Tools\Git\bin\git.exe" pull %repo% %branch%
goto git_pull_finish

:git_pull_finish
echo.
echo Updating submodules if available...
echo.
"%mainfolder%\Tools\Git\bin\git.exe" submodule update --init --recursive
"%mainfolder%\Tools\Git\bin\git.exe" submodule update --recursive --remote
goto menu

:menu
cd "%mainfolder%"
cls
echo #######################################################
echo # Single Player Project - AzerothCore repack builder
echo # https://www.patreon.com/conan513                    
echo #######################################################
echo.
echo 1 - Start the build process
echo 2 - Open the modules folder
echo.
set /P choose_menu=Choose a number: 
if "%choose_menu%"=="1" (goto build)
if "%choose_menu%"=="2" (goto open_modules)
if "%choose_menu%"=="" (goto menu)
goto open_modules

:open_modules
cls
echo Copy AzerothCore module folders here.
echo.
explorer "%mainfolder%\Source\%sourcepath%\modules"
ping -n 10 127.0.0.1>nul
goto menu

:build
cls
set /P cpu_cores=How many CPU core(s) you want to use for compile: 
mkdir "%mainfolder%\Build\%sourcepath%_%archpath%"
cd "%mainfolder%\Build\%sourcepath%_%archpath%"
echo.
echo Checking core to create compatible cmake options...
echo.
if exist "%mainfolder%\Source\%sourcepath%\contrib\sunstrider\generate_script_loader.php" SET dynamic_linking=0
echo.
echo Generate cmake...
echo.
"%mainfolder%\Tools\cmake\%cmake%\bin\cmake.exe" "%mainfolder%/Source/%sourcepath%" -G "Visual Studio 15 2017%arch%" -DOPENSSL_ROOT_DIR="%mainfolder%/Tools/openssl/%openssl%-%archpath%" -DOPENSSL_INCLUDE_DIR="%mainfolder%/Tools/openssl/%openssl%-%archpath%/include" -DMYSQL_LIBRARY="%mainfolder%/Tools/database/%database%-%archpath%/lib/%database_lib%.lib" -DMYSQL_INCLUDE_DIR="%mainfolder%/Tools/database/%database%-%archpath%/include" -DGIT_EXECUTABLE="%mainfolder%/Tools/Git/bin/git.exe" -DTOOLS=1 -DPLAYERBOT=1 -DPLAYERBOTS=1 -DSCRIPT_LIB_ELUNA=0 -DELUNA=0 -DBUILD_EXTRACTORS=1 -DWITH_CPR=1 -DWITH_DYNAMIC_LINKING=%dynamic_linking% -DSCRIPTS=static -DBUILD_TEST=%ike3_test% -DBUILD_IMMERSIVE=%ike3_immersive%
echo.
echo Start building...
echo.
if exist "%mainfolder%\Tools\vs_ok.txt" goto manual_vs_build
%msbuildpath% /p:CL_MPCount=%cpu_cores% ALL_BUILD.vcxproj /p:Configuration=Release
echo.
echo Copy required dll files into bin folder
copy "%mainfolder%\Tools\database\%database%-%archpath%\lib\%database_lib%.dll" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release"
copy "%mainfolder%\Tools\openssl\%openssl%-%archpath%\*.dll" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release"
echo.
cls
REM if not exist "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\authserver.conf" goto copy_conf
goto finalize

:copy_conf
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\authserver.conf.dist" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\authserver.conf"
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\worldserver.conf.dist" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\worldserver.conf"
goto finalize

:finalize
echo Setup databse and modifying config files...
echo
"%mainfolder%\Tools\fart.exe" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\authserver.conf.dist" 127.0.0.1;3306;acore;acore;acore_auth 127.0.0.1;3310;root;123456;acore_auth
"%mainfolder%\Tools\fart.exe" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\worldserver.conf.dist" 127.0.0.1;3306;acore;acore;acore_auth 127.0.0.1;3310;root;123456;acore_auth
"%mainfolder%\Tools\fart.exe" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\worldserver.conf.dist" 127.0.0.1;3306;acore;acore;acore_world 127.0.0.1;3310;root;123456;acore_world
"%mainfolder%\Tools\fart.exe" "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\worldserver.conf.dist" 127.0.0.1;3306;acore;acore;acore_characters 127.0.0.1;3310;root;123456;acore_characters

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
start "" "%mainfolder%\Repack\Database.bat"
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

echo DROP DATABASE IF EXISTS `acore_auth`;>"%mainfolder%\Repack\Database\create_database.sql"
echo DROP DATABASE IF EXISTS `acore_characters`;>>"%mainfolder%\Repack\Database\create_database.sql"
echo DROP DATABASE IF EXISTS `acore_world`;>>"%mainfolder%\Repack\Database\create_database.sql"
echo CREATE DATABASE IF NOT EXISTS `acore_auth` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;>>"%mainfolder%\Repack\Database\create_database.sql"
echo CREATE DATABASE IF NOT EXISTS `acore_characters` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;>>"%mainfolder%\Repack\Database\create_database.sql"
echo CREATE DATABASE IF NOT EXISTS `acore_world` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;>>"%mainfolder%\Repack\Database\create_database.sql"

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
cd "%mainfolder%"
cls
echo Enter your World of Warcraft game folder path
echo to extract dbc, maps, vmaps and mmaps.
echo.
echo Example: C:\Games\World of Warcraft
echo.
echo Enter 0 to skip this process.
echo.
set /P wow_path=Path: 
if "%wow_path%"=="0" (goto end)
if "%wow_path%"=="" (goto extract_data)

:extract_data
cls
echo Extracting data files from World of Warcraft...
echo.
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\mapextractor.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\mmaps_generator.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\vmap4assembler.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\vmap4extractor.exe" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\ace.dll" "%wow_path%" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\%database_lib%.dll" "%wow_path%" /Y
cd "%wow_path%"
cls
mkdir dbc
mkdir maps
mkdir vmaps
mkdir mmaps
cls
start /b /w mapextractor.exe
start /b /w vmap4extractor.exe
start /b /w vmap4assembler.exe Buildings vmaps
start /b /w mmaps_generator.exe

cd "%mainfolder%"

xcopy /s "%wow_path%\dbc" "%mainfolder%\Repack\dbc"
xcopy /s "%wow_path%\maps" "%mainfolder%\Repack\maps"
xcopy /s "%wow_path%\vmaps" "%mainfolder%\Repack\vmaps"
xcopy /s "%wow_path%\mmaps" "%mainfolder%\Repack\mmaps"

if exist "%wow_path%\Data\enUS\realmlist.wtf" echo set realmlist 127.0.0.1>"%wow_path%\Data\enUS\realmlist.wtf"
goto end

:end
"%mainfolder%\Tools\database\%database%-%archpath%\bin\mysqladmin.exe" --defaults-extra-file="%mainfolder%\Tools\database\%database%-%archpath%\connection.cnf" shutdown
echo Closing database server...
echo.

copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\*.dll" "%mainfolder%\Repack" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\authserver.exe" "%mainfolder%\Repack" /Y
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\worldserver.exe" "%mainfolder%\Repack" /Y

if exist "%mainfolder%\Repack\authserver.conf.dist" goto end_of_end
copy "%mainfolder%\Build\%sourcepath%_%archpath%\bin\release\*.dist" "%mainfolder%\Repack" /Y

:end_of_end
explorer "%mainfolder%\Repack"
exit

