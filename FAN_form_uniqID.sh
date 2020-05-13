#!/usr/bin/bash

#！！！！！！！用于Virtual Screnning之前！！！！！！！！！！#
#直接对整个文件多次操作，考虑使用FAN_mol_split_and_form_uniqID.sh代替，
#仅修改需求修改的小分子文件，最后合并
#如对文件尽量少改动用此文件

###################################################################
##此脚本用于获取DOCK结果得分，输入参数为scored.mol2文件
##writing by FAN: y_fan@whu.edu.cn
##2020.05.11 version 0.1
###################################################################

fname=`echo $1 | awk -F . '{print $1}'`
fname=${fname}_uniqID.mol2
cp $1 $fname

for id in `grep ^ZINC $1 | sort | uniq -d`
do
	awk 'BEGIN{n=0} {if($0=="'$id'"){sub("'$id'","'$id'""_"n);n+=1}} 1' $fname > tmpfile
	mv -f tmpfile $fname
done