###############################################################
# setup args


function print_help(){
	echo "Usage: build_llvm.windows.bat [Debug|Release] [--no-clone|]"
	echo
	echo "	--no-clone option:	if set, skip the cloning step"
}



if [[ $1 != "Debug" && $1 != "Release" ]]; then
	print_help
	exit 1
fi




###############################################################
# setup directories

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Setting up required directories[90m \(time started: $NOW\)[0m

RET_CODE=$( mkdir build )

	
###############################################################
# clone LLVM

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Cloning LLVM \(https://github.com/PCIT-Project/llvm-project.git\)[90m \(time started: $NOW\)[0m

if [[ $2 == "--no-clone" ]]; then
	#statements
fi

RET_CODE=$( git clone https://github.com/PCIT-Project/llvm-project.git --depth=1 )

if $RET_CODE; then
	echo [36m\<PCIT Project - build LLVM\>[31m Failed to clone LLVM[0m
	exit $RET_CODE
fi



################################################################
## preparing to build LLVM

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Preparing to build LLVM[90m \(time started: $NOW\)[0m

cd ./build

RET_CODE= cmake "../llvm-project/llvm" \
	-DCMAKE_INSTALL_PREFIX="../llvm-project/llvm/build-output" \
	-DCMAKE_BUILD_TYPE=$1 \
	-DLLVM_ENABLE_PROJECTS="lld;clang" \
	-DLLVM_TARGETS_TO_BUILD="AArch64;RISCV;WebAssembly;X86" \
	-DLLVM_BUILD_TOOLS=OFF \
	-DLLVM_ENABLE_ASSERTIONS=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF \
	-DLLVM_ENABLE_EH=OFF \
	-DLLVM_ENABLE_UNWIND_TABLES=OFF \
	-DLLVM_INCLUDE_BENCHMARKS=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF
# -LLVM_INCLUDE_TOOLS ?
	



if $RET_CODE; then
	echo [36m\<PCIT Project - build LLVM\>[31m Failed to prepare building LLVM[0m
	exit $RET_CODE
fi


################################################################
## building LLVM

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Building LLVM[90m \(time started: $NOW\)[0m

RETCODE= cmake --build . --target install

if $RET_CODE; then
	echo [36m\<PCIT Project - build LLVM\>[31m Failed to build LLVM[0m
	exit $RET_CODE
fi


################################################################
## moving output of LLVM

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Preparing output \(moving to ./output\)[90m \(time started: $NOW\)[0m

cd ../
move "./llvm-project/llvm/build-output" "./output"



###############################################################
# done

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[32m Completed[90m \(time started: $NOW\)[0m
