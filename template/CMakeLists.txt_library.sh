COMMON_HEADER=${1}
TEMPLATE_CMAKELISTS_LIBRARY=${2}
TO_SOURCE=${3}

#   引入头文件
source  ${COMMON_HEADER}

#   拷贝CMakeLists.txt模板到库目录下
cd  ${TO_SOURCE}
cp  ${TEMPLATE_CMAKELISTS_LIBRARY} ${CMAKELISTS}
