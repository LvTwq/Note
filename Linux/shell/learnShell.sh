#!/bin/bash
# author: lvmc

echo "hello world!"

your_name="jerry"
echo ${your_name}
readonly your_name

# 纯字符串使用单引号，如果有变量，使用双引号
str="Hello, I know you are \"${your_name}\"! \n"
echo -e ${str}

# 获取字符串长度
echo ${#str}
# 从字符串第2个字符开始截取4个字符，索引从0开始
echo ${str:1:4}

# 查找字符o或l的位置（哪个字符先出现就计算哪个）
echo `expr index "${str}" l`

# 用括号表示数组，元素用空格分开
array_name=(value0 value1 value2)
# 可以使用不连续的下标，并且下标范围没有限制
array_name[n]=valuen
# 读取数组
echo ${array_name[n]}
# 读取所有元素
echo ${array_name[@]}
# 获取数组元素个数
echo ${#array_name[@]}
# 或者
echo ${#array_name[*]}
# 获取数组单个元素的长度
echo ${#array_name[n]}

:<<EOF

注释

EOF

# 执行脚本时，传递参数，$0 为执行的文件名（包含文件路径）
echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";
echo "参数个数为：$#";
echo "传递的参数作为一个字符串显示：$*";

# 关联数组，可以使用任意的字符串、或者整数作为下标来访问数组元素
declare -A site
site["google"]="www.google.com"
site["runoob"]="www.runoob.com"
site["taobao"]="www.taobao.com"
echo ${site["runoob"]}

# 2 + 2 必须有空格
val=`expr 2 + 2`
echo "${val}"

# 文件测试运算符
file="/root/learnShell.sh"
if [ -e $file ]
then
   echo "文件存在"
else
   echo "文件不存在"
fi



# read 命令从标准输入中读取一行,并把输入行的每个字段的值指定给 shell 变量
read name
echo "$name It is a test"

# -e开启转义 \n换行 \c不换行
echo -e "OK! \c"
echo "It is a test"

# 显示结果定向至文件，> 表示输出重定向
echo "it is a test" > myfile
#  >> 追加到文件末尾
echo "菜鸟教程: www.runoob.com" >> myfile

# 删除这行
sed -i '/it is a test/d' myfile

# 原样输出字符串，不进行转移或取变量（单引号）
echo '$name\"'



# 清空文件内容
:> myfile


:<<EOF
%s %c %d %f 都是格式替代符，％s 输出一个字符串，％d 整型输出，％c 输出一个字符，％f 输出实数，以小数形式输出
%-10s 指一个宽度为 10 个字符（- 表示左对齐，没有则表示右对齐），任何字符都会被显示在 10 个字符宽的字符内，如果不足则自动以空格填充，超过也会将内容全部显示出来
%-4.2f 指格式化为小数，其中 .2 指保留2位小数。
EOF

printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg  
printf "%-10s %-8s %-4.2f\n" 郭靖 男 66.1234
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876



# test 命令用于检查某个条件是否成立，它可以进行数值、字符和文件三个方面的测试
num1=100
num2=100
if test ${num1} -eq ${num2}
then
    echo '两个数相等！'
else
    echo '两个数不相等！'
fi


# [] 执行基本的算数运算，等号两边不能有空格
a=5
b=6
result=$[a+b]
echo "result 为： $result"


# for 循环
for((i=1;i<=10;i++));
do   
    echo $i;  
done