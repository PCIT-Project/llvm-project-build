@echo off
setlocal enabledelayedexpansion

goto begin


:usage
echo Help:
echo 	Script for building the LLVM Project for the PCIT Project
echo.
echo 	Usage:
echo 		build_llvm_release.bat --build ^<build^> [--git-repo ^<git-repo^>] [--version ^<version^>] [--skip-clone] [--skip-include]
echo.
echo 	Options:
echo 		--build:         [required] build option (debug^|release)
echo 		--git-repo:      path of git repo to clone (if not default)
echo 		--version:       version of the LLVM Project git repo to build (if not default)
echo 		--skip-clone:    use local git clone instead of cloning from GitHub
echo 		--skip-includes: skip copying the include files
echo 		--help:          display this help
echo.
echo 	Example:
echo 		build_llvm.windows.bat --build release
exit /b 1


:begin

:: =============================================================
:: parse args

set build=
set git-repo=https://github.com/PCIT-Project/llvm-project.git
set version=20.0.8
set skip-clone=
set skip-includes=
set help=

call :parse_args %*

if "%help%" NEQ "" goto usage


if "%build%" == "" (
	echo [36m^<PCIT Project - build LLVM^>[35m [31m--build option is required[0m
	goto usage
)
if not "%build%" == "debug" (
	if not "%build%" == "release" (
		echo [36m^<PCIT Project - build LLVM^>[35m [31minvalid --build option[0m
		goto usage	
	)
)

if "%version%" == "" (
	echo [36m^<PCIT Project - build LLVM^>[35m [31mgit repo is required[0m
	goto usage
)

if "%version%" == "" (
	echo [36m^<PCIT Project - build LLVM^>[35m [31mversion is required[0m
	goto usage
)



:: =============================================================
:: begin

echo [36m^<PCIT Project - build LLVM^>[35m Build x64 %build%[90m ^(^time started: %time%^)[0m

set package_version=%version%
set src_dir=%cd%\llvm_package_%package_version%\llvm-project
set build_dir=%cd%\llvm_package_%package_version%\%build%\build
set output_dir=%cd%\llvm_package_%package_version%\%build%\output

echo git repo:        %git-repo%
echo package version: %package_version%
echo src dir:         %src_dir%
echo build dir:       %build_dir%
echo output dir:      %output_dir%
echo.

if not exist llvm_package_%package_version% (
	mkdir llvm_package_%package_version%	
)

cd llvm_package_%package_version%


:: =============================================================
:: Detect Visual stuido

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Detect Visual Studio[90m ^(^time started: %time%^)[0m

set vsinstall=
set vswhere=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe

if "%VSINSTALLDIR%" NEQ "" (
	echo using enabled Visual Studio installation
	set "vsinstall=%VSINSTALLDIR%"
) else (
	echo using vswhere to detect Visual Studio installation
	FOR /F "delims=" %%r IN ('^""%vswhere%" -nologo -latest -products "*" -all -property installationPath^"') DO set vsinstall=%%r
)
set "vsdevcmd=%vsinstall%\Common7\Tools\VsDevCmd.bat"

if not exist "%vsdevcmd%" (
	echo [36m^<PCIT Project - build LLVM^>[35m [31mCan't find any installation of Visual Studio[0m^
	exit /b 1
)
echo Using VS devcmd: %vsdevcmd%



:: =============================================================
:: clone llvm

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Clone LLVM[90m ^(^time started: %time%^)[0m


if "%skip-clone%" == "true" (
	if not exist %cd%\llvm-project (
		echo [36m^<PCIT Project - build LLVM^>[35m [31m^LLVM Project was not found:[0m
		echo	 	[31m^%cd%\%build%[0m
		exit /b 1
	)

	echo skipping cloning...

) else (
	if exist %cd%\llvm-project (
		echo [36m^<PCIT Project - build LLVM^>[35m [31m^LLVM Project was already cloned:[0m
		echo	 	[31m^%cd%\%build%[0m
		exit /b 1
	)

	git clone %git-repo% --depth=1

	if %ERRORLEVEL% neq 0 (
		echo [36m^<PCIT Project - build LLVM^>[31m Failed to clone LLVM[0m
		exit /b %ERRORLEVEL%
	)
)


if exist %cd%/%build% (
	echo [36m^<PCIT Project - build LLVM^>[35m [31m^build directory already exists:[0m
	echo	 	[31m^%cd%/%build%[0m
	exit /b 1
)

mkdir %build%
cd %build%

mkdir %output_dir%



:: =============================================================
:: Visual Studio cmd

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Visual Studio cmd[90m ^(^time started: %time%^)[0m

set arch=amd64
call "%vsdevcmd%" -arch=%arch% || exit /b 1

	
:: =============================================================
:: cmake

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Run cmake[90m ^(^time started: %time%^)[0m

mkdir %build_dir%
mkdir %output_dir%/lib-%build%
mkdir %output_dir%/include
cd %build_dir%

if "%build%" == "release" (

	cmake -GNinja ^
		-DCMAKE_BUILD_TYPE=Release ^
		-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
		-DCMAKE_INSTALL_PREFIX=%output_dir%/lib-%build% ^
		-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON ^
		-DLLVM_TARGETS_TO_BUILD="AArch64;RISCV;WebAssembly;X86" ^
		-DPython3_FIND_REGISTRY=NEVER ^
		-DPACKAGE_VERSION=%package_version% ^
		-DLLVM_ENABLE_PROJECTS="clang;lld" ^
		-DLLVM_BUILD_TOOLS=OFF ^
		-DLLVM_ENABLE_ASSERTIONS=OFF ^
		-DLLVM_ENABLE_BINDINGS=OFF ^
		-DLLVM_ENABLE_EH=OFF ^
		-DLLVM_ENABLE_UNWIND_TABLES=OFF ^
		-DLLVM_INCLUDE_BENCHMARKS=OFF ^
		-DLLVM_INCLUDE_EXAMPLES=OFF ^
		%src_dir%\llvm || exit /b 1

) else (
	
	cmake -GNinja ^
		-DCMAKE_BUILD_TYPE="Debug" ^
		-DCMAKE_INSTALL_PREFIX=%output_dir% ^
		-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON ^
		-DLLVM_TARGETS_TO_BUILD="AArch64;RISCV;WebAssembly;X86" ^
		-DPython3_FIND_REGISTRY=NEVER ^
		-DPACKAGE_VERSION=%package_version% ^
		-DLLVM_ENABLE_PROJECTS="clang;lld" ^
		-DLLVM_BUILD_TOOLS=OFF ^
		-DLLVM_ENABLE_ASSERTIONS=OFF ^
		-DLLVM_ENABLE_BINDINGS=OFF ^
		-DLLVM_ENABLE_EH=OFF ^
		-DLLVM_ENABLE_UNWIND_TABLES=OFF ^
		-DLLVM_INCLUDE_BENCHMARKS=OFF ^
		-DLLVM_INCLUDE_EXAMPLES=OFF ^
		%src_dir%\llvm || exit /b 1

)



:: =============================================================
:: ninja

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Run ninja[90m ^(^time started: %time%^)[0m

ninja || ninja || ninja || exit /b 1



:: =============================================================
:: move libs to output 

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Move libs to output[90m ^(^time started: %time%^)[0m

cd ../

move %build_dir%\lib\*.lib %output_dir%\lib


:: =============================================================
:: move includes to output 

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Move includes to output[90m ^(^time started: %time%^)[0m

if "%skip-includes%" == "true" (
	echo skipping moving includes...

) else (
	
	:: ===============
	:: LLVM
	echo llvm:

	mkdir %output_dir%\include\llvm

	xcopy /sq %src_dir%\llvm\include\llvm\*.h %output_dir%\include\llvm
	xcopy /sq %src_dir%\llvm\include\llvm\*.def %output_dir%\include\llvm

	xcopy /sq %build_dir%\include\llvm\*.h %output_dir%\include\llvm
	xcopy /sq %build_dir%\include\llvm\*.inc %output_dir%\include\llvm
	xcopy /sq %build_dir%\include\llvm\*.def %output_dir%\include\llvm


	:: ===============
	:: LLVM-C
	echo.
	echo llvm-c:

	mkdir %output_dir%\include\llvm-c

	xcopy /sq %src_dir%\llvm\include\llvm-c\*.h %output_dir%\include\llvm-c


	:: ===============
	:: CLANG
	echo.
	echo clang:

	mkdir %output_dir%\include\clang

	xcopy /sq %src_dir%\clang\include\clang\*.h %output_dir%\include\clang
	xcopy /sq %src_dir%\clang\include\clang\*.inc %output_dir%\include\clang
	xcopy /sq %src_dir%\clang\include\clang\*.def %output_dir%\include\clang

	xcopy /sq %build_dir%\tools\clang\include\clang\*.inc %output_dir%\include\clang


	:: ===============
	:: clang-c
	echo.
	echo clang-c:

	mkdir %output_dir%\include\clang-c

	xcopy /sq %src_dir%\clang\include\clang-c\*.h %output_dir%\include\clang-c


	:: ===============
	:: LLD
	echo.
	echo lld:

	mkdir %output_dir%\include\lld

	xcopy /sq %src_dir%\lld\include\lld\*.h %output_dir%\include\lld
	xcopy /sq %src_dir%\lld\include\lld\*.inc %output_dir%\include\lld

)



:: =============================================================
:: done

echo.
echo [36m^<PCIT Project - build LLVM^>[35m Completed[90m ^(^time started: %time%^)[0m
exit /b 0




::=============================================================================
:: Parse command line arguments.
:: The format for the arguments is:
::   Boolean: --option
::   Value:   --option<separator>value
::     with <separator> being: space, colon, semicolon or equal sign
::
:: Command line usage example:
::   my-batch-file.bat --build --type=release --version 123
:: It will create 3 variables:
::   'build' with the value 'true'
::   'type' with the value 'release'
::   'version' with the value '123'
::
:: Usage:
::   set "build="
::   set "type="
::   set "version="
::
::   REM Parse arguments.
::   call :parse_args %*
::
::   if defined build (
::     ...
::   )
::   if %type%=='release' (
::     ...
::   )
::   if %version%=='123' (
::     ...
::   )
::=============================================================================
:parse_args
	set "arg_name="
	:parse_args_start
	if "%1" == "" (
		:: Set a seen boolean argument.
		if "%arg_name%" neq "" (
			set "%arg_name%=true"
		)
		goto :parse_args_done
	)
	set aux=%1
	if "%aux:~0,2%" == "--" (
		:: Set a seen boolean argument.
		if "%arg_name%" neq "" (
			set "%arg_name%=true"
		)
		set "arg_name=%aux:~2,250%"
	) else (
		set "%arg_name%=%1"
		set "arg_name="
	)
	shift
	goto :parse_args_start

:parse_args_done
exit /b 0