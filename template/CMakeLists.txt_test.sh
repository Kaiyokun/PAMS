COMMON_HEADER=${1}
TEMPLATE_CMAKELISTS_TEST=${2}
TO_TEST=${3}

#   引入头文件
source  ${COMMON_HEADER}

#   拷贝CMakeLists.txt模板到测试目录下
cd  ${TO_TEST}
cp  ${TEMPLATE_CMAKELISTS_TEST} ${CMAKELISTS}

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
    Write "ADD_TEST(NAME ${TARGET} COMMAND ${TARGET})"        to ${CMAKELISTS}
    Write ""                                                  to ${CMAKELISTS}
done
