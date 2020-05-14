#!/usr/bin/bash

#！！！！！！！用于Virtual Screnning结果处理！！！！！！！！！！#
######################################
##用于分割多小分子文件为单分子文件
##且分子头部有运行结果注释内容的mol2文件
##作为参数输入
##writing by FAN: y_fan@whu.edu.cn
##2020.05.09 version 0.1
######################################

#计算分子数量
mol_num=`grep ^@.TRIPOS.MOLECULE$ $1 | wc -l`
echo "该文件共有$mol_num 个分子结构"
#1.先分为tmp文件，-n根据分子数确定位数，/匹配模式/，{*}最大次数
echo "开始拆分文件……"
csplit -ftmp -ksz -n ${#mol_num} $1 %Name:% /Name:/ {*}
#传入文件名为目标文件

#2.修改文件名tmpxxxx为zinc编号，其中同一编号以后缀_n区分
echo "重命名中，并为重名文件添加数字后缀……"
for file in tmp*
do
	zid=`grep Name $file | awk '{print $3}'` 
	#zid=`head $file | grep Name: | awk '{print $3}'`
	if [[ -e "$zid".mol2 ]]; then
		for n in `seq 1 9`; do
			if [[ ! -e "$zid"_"$n".mol2 ]]; then
				filename="$zid"_"$n".mol2
				sed  "/Name:/{s/${zid}/${zid}_$n/}" $file > $filename
				rm $file
				break
			fi
		done
	else
		filename="$zid".mol2
		mv $file $filename
	fi
done

#3.各小分子文件放入文件夹中
echo "创建同名文件夹……"
dname=`echo $1 | awk -F . '{print $1}'`
mkdir $dname

mv *mol2 ./$dname/
mv ./$dname/$1 ./
echo "完成！拆分文件已放入$dname 文件夹，请查看！"


#########################################################################
#4.提取头部注释分数项
