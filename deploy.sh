ACTION=${1}

#
#   Brief:  返回当前脚本绝对路径
#   Argument List:
#       relative_path:  必须是${BASH_SOURCE[0]}
#   Return:     此脚本所在目录的绝对路径（不含空格）
#   Example:    GetFullPath ${BASH_SOURCE[0]}
#
GetFullPath()
{
    relative_path=${1}
    return=echo

    #   首先，确定此脚本所在目录的绝对路径，先取得文件属性
    file_attribute=$( ls    -l ${relative_path} )

    #   测试是否是符号链接
    file_path=${file_attribute##*-> }

    #   不是符号链接（也可能是硬链接，异常）
    if [[ ${file_attribute} == ${file_path} ]]; then

        file_path=${relative_path}
    #   是符号链接
    else

        file_path=$( cd $( dirname  ${relative_path} ) && pwd )/${file_path}
    fi

    #   此脚本所在目录的绝对路径（不含空格）
    ${return}   $( cd   $( dirname  ${file_path} ) && pwd )
}

#   此脚本所在目录的绝对路径（不含空格）
THIS_DIRECTORY=$( GetFullPath   ${BASH_SOURCE[0]} )

if [[ ${ACTION} != '' ]]; then

    NOW="$( date +"%Y-%m-%d %H:%M:%S" )"

    cd  ${THIS_DIRECTORY}
    zip pams.zip * -x deploy.sh

    git add pams.zip deploy.sh
    git commit -m "No.${RANDOM} - zip file for deployment, commit time: ${NOW}"
    git push -u origin master

    rm  pams.zip

    exit
fi

wget    https://raw.githubusercontent.com/Kaiyokun/PAMS/master/pams.zip
