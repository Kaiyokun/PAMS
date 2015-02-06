#   公共头文件，包含函数以及常量定义

#   函数:
################################################################################
#
#   Brief:  指定文件/管道中，将占位符替换为实际值
#   Argument List:
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
    option="${4+-i} -r"
    file=${5}

    sed ${option} "s/${placeholder}/${actual_value}/g" ${file}  #   用文件或管道
}

#
#   Brief:  将内容写入指定文件/标准输出
#   Argument List:
#       content(1):         内容
#       [OPT] option(2):    to/NULL
#       [OPT] file(3):      指定的文件/NULL
#   Return:     无
#   Example:    1. Write ${content} to ${file}
#               2. Write ""         to ${file}
#               3. Write "Normal output."
#
Write()
{
    content=${1}
    option=${2}
    file=${3}

    if [[ ${option} == to ]]; then

        echo    -e "${content}" >> "${file}"
    else
        echo    -e "${content}"
    fi
}

#
#   Brief:  循环操作
#   Argument List:
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
#   Brief:  显示带颜色的消息
#   Argument List:
#       message(1): 要显示的消息
#       (2):        in
#       color(3):   颜色 enum {
                        none="\e[m"
                        red="\e[31m"
                        green="\e[32m"
                        blue="\e[34m"
#                   }
#   Return:     无
#   Example:    Show ${message} in ${color}
#
Show()
{
    message=${1}
    color=${3}

    case    ${color} in

        r)  font_color=${red}
            ;;

        g)  font_color=${green}
            ;;

        b)  font_color=${blue}
            ;;

        *)  font_color=${none}
            ;;
    esac

    echo    -e "${font_color}${message}${none}"
}

#
#   Brief:  暂停指定时间
#   Argument List:
#       seconds(1): 暂停秒数
#       (2):        second(s)
#   Return:     无
#   Example:    1. Pause 1 second
#               2. Pause ${seconds} seconds
#
Pause()
{
    seconds=${1}

    read    -t ${seconds}
}

#
#   Brief:  按照目录结构参考文件建立相应目录结构
#   Argument List:
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

    while   read line; do

        depth=${line% *}

        if [[ ${depth:${#depth}-1} == / ]]; then #|| ${depth:${#depth}-1} == - ]]; then

            curr_level=$[${#depth}/4]
            curr_dir=${line##* }

            #Repeat "echo    -n -e \a \a" 2                  times
            #Repeat "echo    -n -e \a \a" $[${curr_level}*4] times
            #Repeat "echo    ${curr_dir}" 1                  times

            if [[ "${curr_dir}" != "$( basename    ${curr_dir} )" ]]; then

                continue
            fi

            if (( ${prev_level} < ${curr_level} )); then

                cd  ${prev_dir}

            elif (( ${prev_level} > ${curr_level} )); then

                Repeat 'cd  ..' ${curr_level} times
            fi

            #if [[ ${depth:${#depth}-1} == / ]]; then

                prev_level=${curr_level}
                prev_dir=${curr_dir}

                mkdir   -p ${curr_dir}
            #else
            #    touch   ${curr_dir}
            #    cd  ..
            #fi
        fi
    done    #   用输入重定向或管道
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

#
#   Brief:  提取文件模板参数
#   Argument List:
#       arg_list_file:  输出实参表到文件
#       template_files: 模板文件列表
#   Return:     无
#   Example:    1. GenArgList   ${arg_list_file} ${template_files}
#               2. GenArgList   .arguments $(ls)
#
GenArgList()
{
    arg_list_file=${1}
    shift
    template_files=${@}

    arg_list=$( cat ${template_files}       |   \
                grep    -E -o '%[^%=]+%'    |   \
                sed     -r "s/%([^%]+)%/\1/g" )

    ref_list=$( cat ${template_files}           |   \
                grep    -E -o '%[^%]+=[^%]+%'   |   \
                sed     -r "s/%([^%]+)%/\1/g" )

    for arg in ${arg_list}; do

        arg_list="$( echo   ${arg_list} | sed   -r "s/\<${arg}\>//g") ${arg}"
    done

    for ref in ${ref_list}; do

        ref_list="$( echo   ${ref_list} |
                        sed   -r "s/${ref%%=*}=[^ ]+//g") ${ref}"
    done

    rm  -f ${arg_list_file}

    for arg in ${arg_list}; do

        c=$( grep -H -n -E "%${arg}%" ${template_files} | sed -r 's/^/\/\/ /')
        ref=$( echo "${ref_list}"           |   \
               grep -E -o "${arg}=[^ ]+"    |   \
               sed  -r "s/${arg}=([^ ]+)/\1/g")

        Write "// Reference for [%${arg}%]:"                 to ${arg_list_file}
        Write "${c}"                                         to ${arg_list_file}
        Write "// ---------------------------------------\n" to ${arg_list_file}
        Write "#define PLACE_HOLDER_${arg} ${ref} // Arg: %${arg}%" \
                                                             to ${arg_list_file}
        Write "\n"                                           to ${arg_list_file}
    done
}

#
#   Brief:  构建模板文件实例
#   Argument List:
#       file_instance:  文件实例
#       header:         模板实参定义文件
#       template_file:  模板文件
#       [OPT] comment:  注释符号/NULL(#)
#   Return:     无
#   Example:    1. InstTmpltFile    ${file_instance} ${header} ${template_file}
#               2. InstTmpltFile    CMakeLists.txt .arguments cmakelists_tmplt
#
InstTmpltFile()
{
    file_instance=${1}
    header=${2}
    template_file=${3}
    comment=${4}

    if [[ ${comment} == '' ]]; then

        comment=#
    else
        comment=${comment////\\/}
    fi

    cat ${template_file}            |   \
    sed -r "s/${comment}/\/\//g"    |   \
    sed -r "s/%([^%]+)%/PLACE_HOLDER_\1/g" > ${file_instance}.c

    gcc -E -C -undef -nostdinc -imacros ${header} ${file_instance}.c    |   \
    sed "/#/d"                                                          |   \
    sed "/^$/d"                                                         |   \
    sed "s/\/\//${comment}/g"                                           |   \
    sed -r "s/${comment}.*PLACE_HOLDER_.+=.+$//g" > ${file_instance}

    rm  -f ${file_instance}.c
}

#   常量:
################################################################################
#   此脚本所在目录
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
