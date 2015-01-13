ACTION=${1}

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

if [[ ${ACTION} != '' ]]; then

    #   此脚本所在目录的绝对路径（不含空格）
    THIS_DIRECTORY=$( GetAbsolutePath   ${BASH_SOURCE[0]} )
    NOW="$( date +"%Y-%m-%d %H:%M:%S" )"

    cd  ${THIS_DIRECTORY}
    zip pams.zip * -x deploy.sh

    git add .
    git commit -m "No.${RANDOM} - zip file for deployment, commit time: ${NOW}"
    git push -u origin master

    rm  pams.zip

    exit
fi

wget    https://raw.githubusercontent.com/Kaiyokun/PAMS/master/pams.zip
unzip   pams.zip -d ~/PAMS
rm      pams.zip

sudo ln -s ~/PAMS/entry.sh /usr/bin/mgo
