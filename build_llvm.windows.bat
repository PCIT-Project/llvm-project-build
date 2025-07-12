@echo off
SETLOCAL EnableDelayedExpansion


rem =============================================================
rem setup args

GOTO:MAIN

:print_help
    SETLOCAL ENABLEDELAYEDEXPANSION
       echo Usage: build_llvm.windows.bat [Debug^|Release]  [--no-clone^|]
       echo:
       echo 	--no-clone option:	if set, skip the cloning step 
    ENDLOCAL
EXIT /B 0



:MAIN

if "%1" neq "Debug" ( if "%1" neq "Release" (
	call:print_help
	exit /b 0
))





rem =============================================================
rem setup directories

echo [36m^<PCIT Project - build LLVM^>[35m Setting up required directories[90m (^time started: %time%)[0m

mkdir build

	
rem =============================================================
rem clone LLVM

echo [36m^<PCIT Project - build LLVM^>[35m Cloning LLVM (https://github.com/PCIT-Project/llvm-project.git)[90m (^time started: %time%)[0m


if "%2" == "--no-clone" (
	echo skipping cloning...

) else (
	git clone https://github.com/PCIT-Project/llvm-project.git --depth=1

	if %ERRORLEVEL% neq 0 (
		echo [36m^<PCIT Project - build LLVM^>[31m Failed to clone LLVM[0m
		exit /b %ERRORLEVEL%
	)
)





rem =============================================================
rem preparing to build LLVM

echo [36m^<PCIT Project - build LLVM^>[35m Preparing to build LLVM[90m (^time started: %time%)[0m

cd ./build


if "%1" == "Debug" (

	cmake "../llvm-project/llvm" ^
		-G "Visual Studio 17 2022" ^
		-DCMAKE_INSTALL_PREFIX="../llvm-project/llvm/build-output" ^
		-DCMAKE_BUILD_TYPE="Debug" ^
		-DLLVM_ENABLE_PROJECTS="lld;clang" ^
		-DLLVM_TARGETS_TO_BUILD="AArch64;RISCV;WebAssembly;X86" ^
		-DLLVM_BUILD_TOOLS=OFF ^
		-DLLVM_ENABLE_ASSERTIONS=OFF ^
		-DLLVM_ENABLE_BINDINGS=OFF ^
		-DLLVM_ENABLE_EH=OFF ^
		-DLLVM_ENABLE_UNWIND_TABLES=OFF ^
		-DLLVM_INCLUDE_BENCHMARKS=OFF ^
		-DLLVM_INCLUDE_EXAMPLES=OFF

) else (
	
	cmake "../llvm-project/llvm" ^
		-G "Visual Studio 17 2022" ^
		-DCMAKE_INSTALL_PREFIX="../llvm-project/llvm/build-output" ^
		-DCMAKE_BUILD_TYPE=Release ^
		-DCMAKE_MSCV_RUNTIME_LIBRARY=MultiThreaded ^
		-DLLVM_ENABLE_PROJECTS="lld;clang" ^
		-DLLVM_TARGETS_TO_BUILD="AArch64;RISCV;WebAssembly;X86" ^
		-DLLVM_BUILD_TOOLS=OFF ^
		-DLLVM_ENABLE_ASSERTIONS=OFF ^
		-DLLVM_ENABLE_BINDINGS=OFF ^
		-DLLVM_ENABLE_EH=OFF ^
		-DLLVM_ENABLE_UNWIND_TABLES=OFF ^
		-DLLVM_INCLUDE_BENCHMARKS=OFF ^
		-DLLVM_INCLUDE_EXAMPLES=OFF

)


	



if %ERRORLEVEL% neq 0 (
	echo [36m^<PCIT Project - build LLVM^>[31m Failed to prepare building LLVM[0m
	exit /b %ERRORLEVEL%
)


rem =============================================================
rem building LLVM

echo [36m^<PCIT Project - build LLVM^>[35m Building LLVM[90m (^time started: %time%)[0m

cmake --build . --target install

if %ERRORLEVEL% neq 0 (
	echo [36m^<PCIT Project - build LLVM^>[31m Failed to build LLVM[0m
	exit /b %ERRORLEVEL%
)


rem =============================================================
rem moving output of LLVM

echo [36m^<PCIT Project - build LLVM^>[35m Preparing output (moving to ./output)[90m (^time started: %time%)[0m

cd ../
move "./llvm-project/llvm/build-output" "./output"



rem =============================================================
rem done

echo [36m^<PCIT Project - build LLVM^>[32m Completed[90m (^time started: %time%)[0m