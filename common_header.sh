#   公共头文件，包含函数以及常量定义

#   函数：
################################################################################
#
#   Brief:  指定文件/管道中，将占位符替换为实际值
#   Argument List：
#       placeholder(1):     占位符
#       (2):                with
#       actual_value(3):    实际值
#       [OPT] option(4):    in/NULL
#       [OPT] file(5):      指定文件/NULL
#   Return:     无
#   Example:    1. Replace ${placeholder} with ${actual_value} in ${file}
#               2. cat  ${file} | Replace ${placeholder} with ${actual_value}
#
Replace()
{
    placeholder=${1}
    actual_value=${3}
    option=${4+-i}
    file=${5}

    sed ${option} "s/${placeholder}/${actual_value}/g" ${file}
}

#
#   Brief:  将内容写入指定文件
#   Argument List：
#       content(1): 内容
#       (2):        to
#       file(3):    指定的文件
#   Return:     无
#   Example:    1. Write ${content} to ${file}
#               2. Write ""         to ${file}
#
Write()
{
    content=${1}
    file=${3}

    echo    -e "${content}" >> "${file}"
}

#
#   Brief:  循环操作
#   Argument List：
#       operate(1): 操作
#       count(2):   循环次数
#       (3):        times
#   Return:     无
#   Example:    Repeat ${operate} ${count} times
#
Repeat()
{
    operate=${1}
    count=${2}

    for i in $( seq ${count} ); do

        ${operate}
    done
}

#
#   Brief:  按照目录结构参考文件建立相应目录结构
#   Argument List：
#       root_dir:   指定根目录
#   Return:     无
#   Example:    1. GenDirStruct ${root_dir} < ${ref_file}
#               2. cat  ${ref_file} | GenDirStruct  ${root_dir}
#
GenDirStruct()
{
    root_dir=${1}

    cd  ${root_dir}

    prev_level=0
    prev_dir=.

    while read  line; do

        depth=${line% *}

        if [[ ${depth:${#depth}-1} == / || ${depth:${#depth}-1} == - ]]; then

            curr_level=$[${#depth}/4]
            curr_dir=${line##* }

            Repeat "echo    -n -e \a \a" $[${curr_level}*4] times
            Repeat "echo    ${curr_dir}" 1 times

            if [[ "${curr_dir}" != "$( basename    ${curr_dir} )" ]]; then

                continue
            fi

            if (( ${prev_level} < ${curr_level} )); then

                cd  ${prev_dir}

            elif (( ${prev_level} > ${curr_level} )); then

                Repeat 'cd  ..' ${curr_level} times
            fi

            if [[ ${depth:${#depth}-1} == / ]]; then

                prev_level=${curr_level}
                prev_dir=${curr_dir}

                mkdir   -p ${curr_dir}
            else
                touch   ${curr_dir}
                cd  ..
            fi
        fi
    done    #   用管道或者输入重定向
}

#
#   Brief:  返回当前脚本绝对路径
#   Argument List:
#       relative_path:  必须是${BASH_SOURCE[0]}
#   Return:     当前脚本绝对路径（不含空格）
#   Example:    GetFullName ${BASH_SOURCE[0]}
#
GetFullName()
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

    #   此脚本所在的绝对路径（不含空格）
    file_dir=$( cd   $( dirname ${file_path} ) && pwd )
    file_name=$( basename   ${file_path} )

    ${return}   ${file_dir}/${file_name}
}

#
#   Brief:  返回当前脚本所在目录绝对路径
#   Argument List:
#       relative_path:  必须是${BASH_SOURCE[0]}
#   Return:     此脚本所在目录的绝对路径（不含空格）
#   Example:    GetFullPath ${BASH_SOURCE[0]}
#
GetFullPath()
{
    relative_path=${1}
    return=echo

    #   此脚本所在目录的绝对路径（不含空格）
    ${return}   $( dirname  $( GetFullName  ${relative_path} ) )
}

#
#   Brief:  无命令行参数退出并打印帮助文档
#   Argument List:
#       this_script:    必须是${BASH_SOURCE[0]}
#       arg_count:      必须是${#}
#   Return:     无
#   Example:    ChkArgCnt   ${BASH_SOURCE[0]} ${#}
#
ChkArgCnt()
{
    this_script=${1}
    arg_count=${2}

    this_script_path=$( GetFullPath ${this_script} )
    this_script_name=$( basename    $( GetFullName  ${this_script} ) )
    this_script_help_file=${this_script_path}/${this_script_name%%.*}.hlp

    if [[ ${arg_count} == 0 ]]; then

        clear
        cat ${this_script_help_file}
        exit
    fi
}

#   常量：
################################################################################
THIS_DIRECTORY=$( GetFullPath   ${BASH_SOURCE[0]} )

#   脚本
BASH_SCRIPT_MANAGE=${THIS_DIRECTORY}/manage.sh
BASH_SCRIPT_BUILD=${THIS_DIRECTORY}/build.sh

#   文件模板
CMAKELISTS=CMakeLists.txt
CMAKELISTS_ROOT=${THIS_DIRECTORY}/cmakelists_template_root.txt
CMAKELISTS_LIBRARY=${THIS_DIRECTORY}/cmakelists_library.txt
CMAKELISTS_TEST=${THIS_DIRECTORY}/cmakelists_partial_test.txt
REF_FILE_DIRECTORY_STRUCTURE=${THIS_DIRECTORY}/README

#   文件模板占位符
PLACEHOLDER[0]=%PROJECT_NAME%
PLACEHOLDER[1]=%BUILD_TYPE%
PLACEHOLDER[2]=%INCLUDE%
PLACEHOLDER[3]=%LIBRARY%
PLACEHOLDER[4]=%SOURCE%
PLACEHOLDER[5]=%TEST%
PLACEHOLDER[6]=%BUILT%
PLACEHOLDER[7]=%TEST_%

#   实际值
ACTUAL_VALUE[0]=
ACTUAL_VALUE[1]=
ACTUAL_VALUE[2]=include
ACTUAL_VALUE[3]=library
ACTUAL_VALUE[4]=source
ACTUAL_VALUE[5]=test
ACTUAL_VALUE[6]=built
ACTUAL_VALUE[7]=test_

INCLUDE=${ACTUAL_VALUE[2]}
LIBRARY=${ACTUAL_VALUE[3]}
SOURCE=${ACTUAL_VALUE[4]}
TEST=${ACTUAL_VALUE[5]}
BUILT=${ACTUAL_VALUE[6]}
TEST_=${ACTUAL_VALUE[7]}
