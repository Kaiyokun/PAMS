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

    #   可能存在多重符号链接
    while true; do
        #   不是符号链接（也可能是硬链接，异常）
        if [[ ${file_attribute} == ${file_path} ]]; then

            file_path=${relative_path}
            break
        fi

        #   是符号链接
        if [[ ${file_path:0:1} != / ]]; then

            relative_path=$( cd \
                $( dirname  ${relative_path} ) && pwd )/${file_path}
        else
            relative_path=${file_path}
        fi

        file_attribute=$( ls    -l ${relative_path} )
        file_path=${file_attribute##*-> }
    done

    #   此脚本所在的绝对路径（不含空格）
    ${return}   $( cd   $( dirname  ${file_path} ) && pwd )
}

#   此脚本所在目录的绝对路径（不含空格）
THIS_DIRECTORY=$( GetAbsolutePath   ${BASH_SOURCE[0]} )

#   引入头文件
source  ${THIS_DIRECTORY}/${COMMON_HEADER}

#   检测进入状态
if [[ ${#} == 0 ]]; then

    if [[ -f .makefile ]]; then

        make    -f .makefile
    else
        echo    error
    fi
fi
