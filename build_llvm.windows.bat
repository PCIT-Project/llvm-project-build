@echo off
SETLOCAL EnableDelayedExpansion


rem =============================================================
rem setup directories

echo [36m^<PCIT Project - build LLVM^>[35m Setting up required directories[90m (^time started: %time%)[0m

mkdir build

	
rem =============================================================
rem clone LLVM

echo [36m^<PCIT Project - build LLVM^>[35m Cloning LLVM (https://github.com/PCIT-Project/llvm-project.git)[90m (^time started: %time%)[0m


git clone https://github.com/PCIT-Project/llvm-project.git --depth=1

if %ERRORLEVEL% neq 0 (
	echo [36m^<PCIT Project - build LLVM^>[31m Failed to clone LLVM[0m
	exit /b %ERRORLEVEL%
)




rem =============================================================
rem preparing to build LLVM

echo [36m^<PCIT Project - build LLVM^>[35m Preparing to build LLVM[90m (^time started: %time%)[0m

cd ./build

cmake "../llvm-project/llvm" ^
	-G "Visual Studio 17 2022" ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DCMAKE_INSTALL_PREFIX="../llvm-project/llvm/build-output" ^
	-DLLVM_ENABLE_PROJECTS="lld;clang" ^
	-DLLVM_BUILD_TOOLS=OFF ^
	-DLLVM_ENABLE_ASSERTIONS=OFF ^
	-DLLVM_ENABLE_BINDINGS=OFF ^
	-DLLVM_ENABLE_EH=OFF ^
	-DLLVM_ENABLE_UNWIND_TABLES=OFF ^
	-DLLVM_INCLUDE_BENCHMARKS=OFF ^
	-DLLVM_INCLUDE_EXAMPLES=OFF
rem -LLVM_INCLUDE_TOOLS ?
	



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
