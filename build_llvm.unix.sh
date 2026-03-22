

function print_help(){
	echo Help:
	echo "	Script for building the LLVM Project for the PCIT Project"
	echo
	echo "	Usage:"
	echo "		build_llvm_release.bat --build <build> [--git-repo <git-repo>] [--version <version>] [--skip-clone] [--skip-include]"
	echo
	echo "	Options:"
	echo "		--build:         [required] build option (debug|release)"
	echo "		--git-repo:      path of git repo to clone (if not default)"
	echo "		--version:       version of the LLVM Project git repo to build (if not default)"
	echo "		--skip-clone:    use local git clone instead of cloning from GitHub"
	echo "		--skip-includes: use local git clone instead of cloning from GitHub"
	echo "		--help:          display this help"
	echo
	echo "	Example:"
	echo "		build_llvm.unix.sh --build release"

	exit 1
}


export build=
export git_repo="https://github.com/PCIT-Project/llvm-project.git"
export version="20.0.8"
export skip_clone=
export skip_includes=


function parse_args(){
	if [[ $1 == "" ]]; then
		return

	elif [[ $1 == "--build" ]]; then
		export build=$2

	elif [[ $1 == "--git-repo" ]]; then
		export git_repo=$2

	elif [[ $1 == "--version" ]]; then
		export version=$2

	elif [[ $1 == "--skip-clone" ]]; then
		export skip_clone=true

	elif [[ $1 == "--skip-includes" ]]; then
		export skip_includes=true

	elif [[ $1 == "--help" ]]; then
		print_help

	fi

	shift
	parse_args $*
}



parse_args $*


if [[ $build == "" ]]; then
	echo [36m\<PCIT Project - build LLVM\> [31m--build option is required[0m
	print_help
fi
if [[ $build != "debug" ]]; then
	if [[ $build != "release" ]]; then
		echo [36m\<PCIT Project - build LLVM\> [31minvalid --build option[0m
		print_help	
	fi
fi


if [[ $git_repo == "" ]]; then
	echo [36m\<PCIT Project - build LLVM\> [31mgit_repo is required[0m
	print_help
fi

if [[ $version == "" ]]; then
	echo [36m\<PCIT Project - build LLVM\> [31mversion is required[0m
	print_help
fi


###############################################################
# begin

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m build x64 $build[90m \(time started: $NOW\)[0m

current_working_dir=$( cd "$( dirname "$0" )" && pwd )

package_version=$version
src_dir=$current_working_dir\/llvm_package_$package_version\/llvm\-project
build_dir=$current_working_dir\/llvm_package_$package_version\/$build\/build
output_dir=$current_working_dir\/llvm_package_$package_version\/$build\/output

echo "git repo:        $git_repo"
echo "package version: $package_version"
echo "src dir:         $src_dir"
echo "build dir:       $build_dir"
echo "output dir:      $output_dir"
echo

if [[ ! -e llvm_package_$package_version ]]; then
	mkdir llvm_package_$package_version
fi

cd llvm_package_$package_version


###############################################################
# clone llvm

NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Cloning llvm[90m \(time started: $NOW\)[0m


current_working_dir=$( cd "$( dirname "$0" )" && pwd )


if [[ $skip_clone == "true" ]]; then
	if [[ ! -e $current_working_dir/llvm-project ]]; then
		echo [36m\<PCIT Project - build LLVM\>[31m LLVM Project was not found:[0m
		echo "	 	[31m$current_working_dir/$build[0m"
		exit 1
	fi

	echo skipping cloning...

else
	if [[ -e $current_working_dir/llvm-project ]]; then
		echo [36m\<PCIT Project - build LLVM\>[31m LLVM Project was already cloned:[0m
		echo "	 	[31m$current_working_dir/$build[0m"
		exit 1
	fi

	git clone $git_repo --depth=1
	

	if [[ $? != 0 ]]; then
		echo [36m\<PCIT Project - build LLVM\>[31m Failed to clone LLVM[0m
		exit $?
	fi
fi


if [[ -e $current_working_dir/$build ]]; then
	echo [36m\<PCIT Project - build LLVM\>[31m build directory already exists:[0m
	echo "	 	[31m$current_working_dir/$build[0m"
	exit 1
fi


mkdir $build
cd $build


###############################################################
# cmake

echo
NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Run cmake[90m \(time started: $NOW\)[0m

mkdir $build_dir
mkdir $output_dir/include
mkdir $output_dir/lib-$build
cd $build_dir

if [[ $build == "release" ]]; then

	cmake -GNinja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded \
		-DCMAKE_INSTALL_PREFIX=$output_dir \
		-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
		-DLLVM_TARGETS_TO_BUILD="AArch64;RISCV;WebAssembly;X86" \
		-DPython3_FIND_REGISTRY=NEVER \
		-DPACKAGE_VERSION=$package_version \
		-DLLVM_ENABLE_PROJECTS="clang;lld" \
		-DLLVM_BUILD_TOOLS=OFF \
		-DLLVM_ENABLE_ASSERTIONS=OFF \
		-DLLVM_ENABLE_BINDINGS=OFF \
		-DLLVM_ENABLE_EH=OFF \
		-DLLVM_ENABLE_UNWIND_TABLES=OFF \
		-DLLVM_INCLUDE_BENCHMARKS=OFF \
		-DLLVM_INCLUDE_EXAMPLES=OFF \
		$src_dir/llvm || exit 1

else
	
	cmake -GNinja \
		-DCMAKE_BUILD_TYPE="Debug" \
		-DCMAKE_INSTALL_PREFIX=$output_dir \
		-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
		-DLLVM_TARGETS_TO_BUILD="AArch64;RISCV;WebAssembly;X86" \
		-DPython3_FIND_REGISTRY=NEVER \
		-DPACKAGE_VERSION=$package_version \
		-DLLVM_ENABLE_PROJECTS="clang;lld" \
		-DLLVM_BUILD_TOOLS=OFF \
		-DLLVM_ENABLE_ASSERTIONS=OFF \
		-DLLVM_ENABLE_BINDINGS=OFF \
		-DLLVM_ENABLE_EH=OFF \
		-DLLVM_ENABLE_UNWIND_TABLES=OFF \
		-DLLVM_INCLUDE_BENCHMARKS=OFF \
		-DLLVM_INCLUDE_EXAMPLES=OFF \
		$src_dir/llvm || exit 1

fi



###############################################################
# ninja

echo
NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Run ninja[90m \(time started: $NOW\)[0m



ninja || ninja || ninja || exit 1


###############################################################
# move libs to output

echo
NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Move libs to output[90m \(time started: $NOW\)[0m

cd ../

mv $build_dir/lib/*.lib $output_dir


###############################################################
# move includes to output

echo
NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Move includes to output[90m \(time started: $NOW\)[0m

if [[ $skip-includes == "true" ]]; then
	echo skipping moving includes...

) else (
	
	##################
	## LLVM
	echo llvm:

	mkdir $output_dir/include/llvm

	cp -r $src_dir/llvm/include/llvm/*.h $output_dir/include/llvm
	cp -r $src_dir/llvm/include/llvm/*.def $output_dir/include/llvm

	cp -r %build_dir%/include/llvm/*.h $output_dir/include/llvm
	cp -r %build_dir%/include/llvm/*.inc $output_dir/include/llvm
	cp -r %build_dir%/include/llvm/*.def $output_dir/include/llvm


	##################
	## LLVM-C
	echo.
	echo llvm-c:

	mkdir $output_dir/include/llvm-c

	cp -r $src_dir/llvm/include/llvm-c/*.h $output_dir/include/llvm-c


	##################
	## CLANG
	echo.
	echo clang:

	mkdir $output_dir/include/clang

	cp -r $src_dir/clang/include/clang/*.h $output_dir/include/clang
	cp -r $src_dir/clang/include/clang/*.inc $output_dir/include/clang
	cp -r $src_dir/clang/include/clang/*.def $output_dir/include/clang

	cp -r %build_dir%/tools/clang/include/clang/*.inc $output_dir/include/clang


	##################
	## clang-c
	echo.
	echo clang-c:

	mkdir $output_dir/include/clang-c

	cp -r $src_dir/clang/include/clang-c/*.h $output_dir/include/clang-c


	##################
	## LLD
	echo.
	echo lld:

	mkdir $output_dir/include/lld

	cp -r $src_dir/lld/include/lld/*.h $output_dir/include/lld
	cp -r $src_dir/lld/include/lld/*.inc $output_dir/include/lld

)



###############################################################
# done

echo
NOW=$( date '+%H:%M:%S' )
echo [36m\<PCIT Project - build LLVM\>[35m Completed[90m \(time started: $NOW\)[0m

exit 0
