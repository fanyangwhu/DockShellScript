#!/usr/bin/bash

#！！！！！！！用于Virtual Screnning结果分析！！！！！！！！！！#
###################################################################
##此脚本用于获取DOCK结果得分，输入参数为out文件
##writing by FAN: y_fan@whu.edu.cn
##2020.05.09 version 0.1
###################################################################

#1.通过out文件最后两行获取分子数mol_num和运行时间run_time
mol_num=`tail -n 2 $1 | head -n 1 | awk '{print $1}'`
run_sec=`tail -n 1 $1 | awk '{print $4}'`
run_min=$[run_sec/60]
run_hour=$[run_min/60]
echo "本次docking结果共有 $mol_num 个分子结果，运行耗时约 $run_hour 小时（共 $run_min 分钟）"
#2.每个分子得分行数
lines_total=`grep : $1 | sed -e '/^Note/d' -e '$d' | wc -l`
lines_per_mol=$[(lines_total)/mol_num] #-3为去掉前两行note和最后一行total
echo "每个分子包含 $lines_per_mol 行头部注释"

#3.切分每个分子的注释，后缀宽度为分子数的字符长度${#string}
echo "正在拆分每个分子的结果……"
grep : $1 | sed -e '/^Note/d' -e '$d' | split -l $lines_per_mol -d -a ${#mol_num} - tmp

#4.重命名tmp文件及其zinc编号，为同一编号添加后缀，后缀长度两位
echo "正在查找重复ZINC编号，并添加区分后缀……"
for file in tmp*  #`ls | grep tmp`
do
	#echo "$file"
	zid=`grep ZINC $file | awk '{print $2}'`
	if [[ -e "$zid".score ]]; then
		for n in `seq 1 9`; do
			if [[ ! -e "$zid"_"$n".score ]]; then
				filename="$zid"_"$n".score
				sed  "s/${zid}/${zid}_$n/" $file > $filename
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
	title=`awk -F : '{print $1}' $f | sed 's/ //g'`
	echo $title >> $1.scores
	break
done

#得分
for f in ZINC*; do
	scores=`awk -F : '{print $2}' $f | awk '{print $1}'`
	echo $scores >> $1.scores
	rm $f
done

#格式化为csv
sed 's/ /,/g' $1.scores > $1.scores.csv
echo "得分提取完成！请查看结果文件scores.all，或csv格式结果文件scores.all.csv"