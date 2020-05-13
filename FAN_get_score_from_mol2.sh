#!/usr/bin/bash

#！！！！！！！用于Virtual Screnning结果分析！！！！！！！！！！#
###################################################################
##此脚本用于获取DOCK结果得分，输入参数为scored.mol2文件
##writing by FAN: y_fan@whu.edu.cn
##2020.05.11 version 0.1
###################################################################

#1.检测是否包含得分注释信息
if [[ ! `grep ^#### $1` ]]; then
	echo "文件中不包含以#开头的注释得分信息！"
	exit
fi

#2.提取注释信息，并计算分子数、注释总行数
grep ^#### $1 > scores.tmp
mol_num=`grep ZINC scores.tmp | wc -l`
lines_total=`cat scores.tmp | wc -l`
lines_per_mol=$[(lines_total)/mol_num]

#3.按行数切分得分文件
split -l $lines_per_mol -d -a ${#mol_num} scores.tmp tmp
rm scores.tmp

#4.重命名tmp文件，如有同名修改后缀
echo "正在查找重复ZINC编号，并添加区分后缀……"
for file in tmp*  #`ls | grep tmp`
do
	#   grep -o 直接输出匹配项
	zid=`grep -o "ZINC[0-9_]*" $file ` 
	#zid=`head $file | grep Name: | awk '{print $3}'`
	if [[ -e "$zid".score ]]; then
		for n in `seq  1 9`; do
			if [[ ! -e "$zid"_"$n".score ]]; then
				filename="$zid"_"$n".score
				sed "s/${zid}/${zid}_$n/" $file > $filename
				rm $file
				break
			fi
		done
	else
		filename="$zid".score
		mv $file $filename
	fi
done


#5.提取标题、得分，并格式化
#标题

echo "合并得分到结果文件中……"
for f in ZINC*; do
	title=`awk '{print $2}' $f | sed 's/://g'`
	echo $title >> $1.scores
	break
done

#得分
for f in ZINC*; do
	scores=`awk '{print $3}' $f`
	echo $scores >> $1.scores
	rm $f
done

#格式化为csv
sed 's/ /,/g' $1.scores > $1.scores.csv
echo "得分提取完成！请查看结果文件.scores，或csv格式结果文件.scores.csv"