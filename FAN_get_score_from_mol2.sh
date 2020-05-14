#!/usr/bin/bash

#！！！！！！！用于Virtual Screnning结果分析！！！！！！！！！！#
###################################################################
##此脚本用于获取DOCK结果得分，输入参数为scored.mol2文件
##writing by FAN: y_fan@whu.edu.cn
##2020.05.14 version 0.2
##Note:支持非ZINC编号的任意分子名称
##2020.05.11 version 0.1
###################################################################

##################################################################
#1.检测是否包含得分注释信息
###################################################################
if [[ ! `grep ^#### $1` ]]; then
	echo "文件中不包含以#开头的注释得分信息！"
	exit
fi

####################################################################
#2.提取注释信息，并计算分子数、注释总行数
#####################################################################
grep ^#### $1 > scores.tmp
mol_num=`grep Name scores.tmp | wc -l`

#lines_total=`cat scores.tmp | wc -l`
#lines_per_mol=$[(lines_total)/mol_num]
#不能准确活得分子数
echo "共$mol_num 个分子"

#####################################################################
#3.按行数切分得分文件
#部分为能docking成功的分子行数不一致，改为用csplit通过查找Name进行切分
#####################################################################
#split -l $lines_per_mol -d -a ${#mol_num} scores.tmp tmp
csplit -ftmp -ksz -n ${#mol_num} scores.tmp %Name% /Name/ {*}
rm scores.tmp

#####################################################################
#4.重命名tmp文件，如有同名修改后缀；并区分docking成功与否
#####################################################################
echo "确认docking是否成功；确认是否有重复ID，并添加区分后缀……"
for file in tmp*  #`ls | grep tmp`
do
	#获取分子名称
	mid=`grep Name $file | awk '{print $3}'` 

	#判断时候有得分，有则修改名称，无则输出Unocking ID，并删除tmp文件
	if [[ `grep Grid_Score $file` ]]; then
		#判断文件是否存在并修改文件名
		if [[ -e "$mid".score ]]; then
			for n in `seq  1 9`; do
				if [[ ! -e "$mid"_"$n".score ]]; then
					filename="$mid"_"$n".score
					sed "s/${mid}/${mid}_$n/" $file > $filename
					rm $file
					break
				fi
			done
		else
			filename="$mid".score
			mv $file $filename
		fi
	else
		#未docking成功的分子
		echo $mid >> UnDocking.id
		mv $file "$mid".undock
	fi
done
#echo "未能Docking成功的分子名称请查看Undocking.id"

##############################################################
#5.提取标题、得分，并格式化
##############################################################
echo "合并得分到结果文件中……"
#标题
for f in *score; do
	title=`awk '{print $2}' $f | sed 's/://g'`
	echo $title >> $1.scores
	break
done

#得分
for f in *score; do
	scores=`awk '{print $3}' $f`
	echo $scores >> $1.scores
	rm $f
done

#格式化为csv
sed 's/ /,/g' $1.scores > $1.scores.csv
echo "得分提取完成！请查看结果文件.scores，或csv格式结果文件.scores.csv"

##############################################################
#6.整合未成功docking的分子信息
##############################################################

#标题
if [[ -e *undock ]]; then
	for f in *undock; do
		title=`awk '{print $2}' $f | sed 's/://g'`
		echo $title >> $1.undockinfo
		break
	done

	#得分
	for f in *undock; do
		scores=`awk '{print $3}' $f`
		echo $scores >> $1.undockinfo
		rm $f
	done
	#格式化为csv
	sed 's/ /,/g' $1.undockinfo > $1.undockinfo.csv
	echo "整合未成功docking的分子信息到。"
fi

echo "全部完成！"