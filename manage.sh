COMMON_HEADER=${1}
PROJECT_NAME=${2}

#   引入头文件
source  ${COMMON_HEADER}

#   将文件按特征分类归档
for FILE in $(ls); do

    FILE_NAME_PRIFIX=${FILE:0:${#TEST_}}
    FILE_TYPE=${FILE##*.}

    if [[ ${FILE_NAME_PRIFIX} == ${TEST_} ]]; then

        mv  ${FILE} ${TEST}/${FILE}

    elif [[ ${FILE_TYPE} == c || ${FILE_TYPE} == cpp ]]; then

        mv  ${FILE} ${SOURCE}/${FILE}

    elif [[ ${FILE_TYPE} == h || ${FILE_TYPE} == hpp ]]; then

        mv  ${FILE} ${INCLUDE}/${FILE}
    fi
done

#   构建工程
${BASH_SCRIPT_BUILD}    ${@}

#   构建失败则退出
if  [[ ${?} != 0 ]]; then

    exit
fi

#   进入测试目录
cd  ${BUILT}/${TEST_}${PROJECT_NAME}

#   开始测试
read    -t 1 -p "   Step 3：开始测试..."
echo
PS3='>> '

while true; do

    echo    "工程[${PROJECT_NAME}]测试程序集，请选择："
    echo    --------------------------------------------------------------------

    select  EXE in $(ls); do

        if [[ ${EXE} != "" ]]; then

            echo
            echo    "启动[${EXE}]"
            echo    ------------------------------------------------------------

            ./${EXE}
        fi

        break
    done

    echo
    echo
    echo
done
