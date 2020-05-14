#!/usr/bin/bash
####################################
#合并同一分子库不同方法得分
####################################

#利用管道一个命令即可

join -t, -o 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 -a1 -a2 -eNA -j 1 rigid_tcm_scored.mol2.scores.csv anchor_tcm_scored.mol2.scores.csv | \
wk -F,  '{if($1=="NA"){OFS=",";$1=$9;$2=$10;$3=$11;$4=$12}} 1' | cut -d, -f 1-8,13- >join_rigid_flex.scores.csv

exit


#先将所有的列合并，空内容以NA填充，-o输出所有列，因为默认2.1不会输出，所以这里全部列出来了
join -t, -o 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 -a1 -a2 -eNA -j 1 rigid_tcm_scored.mol2.scores.csv anchor_tcm_scored.mol2.scores.csv > join_rigid_flex.scores.csv
#每个文件共8列，前四列内容相同，如果第一个文件的内容为NA，则将其前四列内容用第二个文件的前四列内容填充
awk -F,  '{if($1=="NA"){OFS=",";$1=$9;$2=$10;$3=$11;$4=$12}} 1' join_rigid_flex.scores.csv > join.tmp
#最后将第二个文件的前四列即9-12列切除
cut -d, -f 1-8,13- join.tmp > join_rigid_flex.scores.csv