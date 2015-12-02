#!/bin/bash
for file in `ls -latr|awk {'print $9'}|grep '_pid_stats'`;do
        out_file="`cat ${file} |head -n 1 |tee >(sed 's/ /\n/g'|grep 'Dweblogic.Name'|cut -d"=" -f2)|cut -d" " -f2|grep -v ^Server$`.fill_data.log"
        if [ -w ${out_file} ];then
                cat ${file} |awk {'print $1,$2";"$3";"$5'}|sed 's/\./,/3g'>> ${out_file};
        else
                cat ${file} |awk {'print $1,$2";"$3";"$5'}|sed 's/\./,/3g' > ${out_file};
        fi
done;
