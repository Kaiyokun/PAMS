COMMON_HEADER=${1}
PROJECT_NAME=${2}
BUILD_TYPE=${3}

#   引入头文件
source  ${COMMON_HEADER}

#   设置模板实参
ACTUAL_VALUE[0]=${PROJECT_NAME}
ACTUAL_VALUE[1]=${BUILD_TYPE}

#   构建主CMakeLists.txt
cp  ${CMAKELISTS_ROOT} ${CMAKELISTS}

for (( i = 0; i < ${#PLACEHOLDER[*]}; ++i )); do

    Replace ${PLACEHOLDER[i]} with ${ACTUAL_VALUE[i]} in ${CMAKELISTS}
done

#   拷贝CMakeLists.txt到源文件目录下
cp  ${CMAKELISTS_LIBRARY} ${SOURCE}/${CMAKELISTS}

#   拷贝部分测试CMakeLists.txt到测试目录下
cd  ${TEST}
cp  ${CMAKELISTS_TEST} ${CMAKELISTS}

#   将每个测试源文件添加到可执行目标中
for FILE in $(ls); do

    SOURCE=${FILE##*/}
    FILE_TYPE=${SOURCE#*.}

    if [[ ${FILE_TYPE} != c && ${FILE_TYPE} != cpp ]]; then

        continue
    fi

    TARGET=${SOURCE%%.*}

    Write "ADD_EXECUTABLE(${TARGET} ${SOURCE})"               to ${CMAKELISTS}
    Write "TARGET_LINK_LIBRARIES(${TARGET} \${LIBRARY_NAME})" to ${CMAKELISTS}
    Write ""                                                  to ${CMAKELISTS}
done

#   启动构建
echo
echo
read    -t 1 -p "   Step 2：开始构建[${BUILD_TYPE}]版本..."
echo
echo

cd  ../${BUILT}
cmake   ..
make
exit    ${?}
