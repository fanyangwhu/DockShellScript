#!/usr/bin/bash

#！！！！！！！用于Virtual Screnning之前！！！！！！！！！！#
#######################################
##用于分割多小分子文件为单分子文件，无注释内容mol2文件
##作为参数输入
##writing by FAN: y_fan@whu.edu.cn
##2020.05.11 version 0.2
##add uniq ID rename
##2020.05.09 version 0.1
######################################
#重复ID默认第一个无后缀，可考虑找出有后缀id修改无id文件名及其分子名，暂无需求

#计算分子数量
mol_num=`grep ^@.TRIPOS.MOLECULE$ $1 | wc -l`
echo "该文件共有$mol_num 个分子结构"
#1.先分为tmp文件，-n根据分子数确定位数，/匹配模式/，{*}最大次数
echo "开始拆分文件……"
csplit -ftmp -ksz -n ${#mol_num} $1 %^@.TRIPOS.MOLECULE% /^@.TRIPOS.MOLECULE/ {*}
#传入文件名为目标文件


#2.修改文件名tmpxxxx为zinc编号，其中同一编号以后缀_n区分
echo "重命名中，并为同一ZINC编号多个结构文件名添加数字后缀……"
for file in tmp*
do
	zid=`grep ^ZINC $file`
	if [[ -e "$zid".mol2 ]]; then
		for n in `seq 1 9`; do
			if [[ ! -e "$zid"_"$n".mol2 ]]; then
				filename="$zid"_"$n".mol2
				sed  "/^ZINC/{s/${zid}/${zid}_$n/}" $file > $filename
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
fname=${dname}_uniqID.mol2
mkdir $dname
#修改文件夹名称为所需名称
mv ZINC* ./$dname/
cd $dname
cat ZINC* > $fname
mv $fname ../
cd ..
echo "完成！生成无重名ID结构文件$fname !"
echo "但此文件分子顺序与原文件不同，按名称升序排列"
echo "-------------------------------------"
echo "拆分文件已放入$dname 文件夹，请查看！"
