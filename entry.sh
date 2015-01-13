#       这是一个自动化管理C/C++工程的脚本工具。它可以实现自动生成工程目录结构、
#   分类整理文件、生成CMakeLists.txt、执行编译以及自动启动测试。

#   不确定因素
COMMON_HEADER=common_header.sh

#
#   Brief:  返回当前脚本所在目录绝对路径
#   Argument List:
#       relative_path:  必须是${BASH_SOURCE[0]}
#   Return:     此脚本所在目录的绝对路径（不含空格）
#   Example:    GetAbsolutePath ${BASH_SOURCE[0]}
#
GetAbsolutePath()
{
    relative_path=${1}
    return=echo

    #   首先取得文件属性
    file_attribute=$( ls    -l ${relative_path} )

    #   测试是否是符号链接
    file_path=${file_attribute##*-> }

    #   不是符号链接（也可能是硬链接，异常）
    if [[ ${file_attribute} == ${file_path} ]]; then

        file_path=${relative_path}
    #   是符号链接
    elif [[ ${file_path:0:1} != / ]]; then

        file_path=$( cd $( dirname  ${relative_path} ) && pwd )/${file_path}
    fi

    #   此脚本所在目录的绝对路径（不含空格）
    ${return}   $( cd   $( dirname  ${file_path} ) && pwd )
}

#   此脚本所在目录的绝对路径（不含空格）
THIS_DIRECTORY=$( GetAbsolutePath   ${BASH_SOURCE[0]} )

#   引入头文件
source  ${THIS_DIRECTORY}/${COMMON_HEADER}

#   无命令行参数则打印帮助文件后退出
ChkArgCnt   ${BASH_SOURCE[0]} ${#}

#   假定命令行参数1为工程路径，参数2为构建模式
PROJECT_DIRECTORY=${1}
BUILD_TYPE=${2}

#   获取工程根目录和工程名
PROJECT_DIRECTORY_ROOT=$( dirname   ${PROJECT_DIRECTORY} )
PROJECT_NAME=$( basename    ${PROJECT_DIRECTORY} )

#   获取构建模式
if [[ ${BUILD_TYPE} == '' ]]; then

    BUILD_TYPE=Debug
else
    BUILD_TYPE=Release
fi

#   测试工程路径是否存在
if [[ -d ${PROJECT_DIRECTORY} ]]; then

    PROJECT_DIRECTORY_ALREADY_EXIST=TRUE
else

    PROJECT_DIRECTORY_ALREADY_EXIST=FALSE

    mkdir   -p ${PROJECT_DIRECTORY_ROOT}
fi

#   进入到工程根目录下
clear
echo    -e "    你好，$USER！欢迎使用C/C++工程自动化管理脚本！\n"
echo    -n "    工程[${PROJECT_NAME}]所在的根目录绝对路径为: "
cd  ${PROJECT_DIRECTORY_ROOT} && pwd
echo
echo
read    -t 1 -p "   Step 1：开始创建目录结构..."
echo
echo

#   设置模板实参
ACTUAL_VALUE[0]=${PROJECT_NAME}
ACTUAL_VALUE[1]=${BUILD_TYPE}

#   构建目录结构
cp  ${REF_FILE_DIRECTORY_STRUCTURE} ${REF_FILE_DIRECTORY_STRUCTURE}~

for (( i = 0; i < ${#PLACEHOLDER[*]}; ++i )); do

    Replace ${PLACEHOLDER[i]} with ${ACTUAL_VALUE[i]}   \
        in ${REF_FILE_DIRECTORY_STRUCTURE}~
done

cat ${REF_FILE_DIRECTORY_STRUCTURE}~ | GenDirStruct ${PWD}  \
    && rm   ${REF_FILE_DIRECTORY_STRUCTURE}~

#   管理工程文件
if [[ ${PROJECT_DIRECTORY_ALREADY_EXIST} == TRUE ]]; then

    cd  ${PROJECT_NAME}
    ${BASH_SCRIPT_MANAGE}   ${THIS_DIRECTORY}/${COMMON_HEADER}  \
                            ${PROJECT_NAME}                     \
                            ${BUILD_TYPE}
fi
