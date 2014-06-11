#! /usr/bin/awk -f

# example:
#   $ ps aux >ps-aux.txt
# raw data
#   $ tail -n +2 ps-aux.txt | cross.awk -v axis="1" -v summary="" | sort -nk 2 | sort >ps-aux1.txt
# 1st level fine grain summary by cross.awk
#   $ tail -n +2 ps-aux.txt | cross.awk -v axis="-" -v summary="" | sort -nk 2 | sort >ps-aux2.txt
# 2nd level rough summary by cross.awk
#   $ aggregate.awk -v axis="2" -v summary="" ps-aux1.txt | awk '{print "-",$0}' | sort -nk 2 | sort | diff ps-aux2.txt -
# 2nd summary by aggregate.awk from 1st summary, then compare
#   $ for i in 3 4 5 6; do tail -n +2 ps-aux.txt | awk -v s=$i '{print "-",s,1,$s,$s,$s,0}' | aggregate.awk -v axis="1 2" -v summary="3 4 5 6 7"; done | diff ps-aux2.txt -
# 2nd summary by aggregate.awk from raw data, then compare
#   $ ping www.google.co.jp | awk --source 'BEGIN{FS="[ =():]+";axis="";summary="2 3 4 5 6";running=1}NR==1{print;next}{if(end==1||NF==0){end=1;print;next};$0="-" OFS 1 OFS $11 OFS $11 OFS $11 OFS 0}' -f aggregate.awk
# print per ping statistics

function update(){
	na = count[pattern];
	count[pattern] += $s[1];

	delta = $s[3] - mean[pattern];
	if($s[1] == 1)
		mean[pattern] = (na * mean[pattern] + $s[1] * $s[3]) / count[pattern];
	else
		mean[pattern] = mean[pattern] + delta * $s[1] / count[pattern];
	M2b = $s[5] * $s[5] * $s[1]
	M2[pattern] = M2[pattern] + M2b + delta * delta * (na * $s[1] / count[pattern]);

	if(na == 0){
		min[pattern] = $s[2];
		max[pattern] = $s[4];
	}
	if($s[2] < min[pattern])
		min[pattern] = $s[2];
	if(max[pattern] < $s[4])
		max[pattern] = $s[4];

	sum[pattern] += $s[1] * $s[3];
}

function summarize(){
	for(key in count){
		average = mean[key];
		variance = M2[key] / count[key];
		standardDeviation = sqrt(variance);
		print gensub(SUBSEP, OFS, "g", key), count[key], min[key], average, max[key], standardDeviation, sum[key];
	}
}

BEGIN {
	if(!axis)
		axis = "-";
	split(axis, a);
	if(!summary)
		summary = "3 4 5 6 7";
	if(split(summary, s) != 5){
		print "summary must have 5 basic statistics (freq, min, avg, max, stddev)" >"/dev/stderr";
		exit 1;
	}
}

{
	if(axis == "-")
		pattern = axis;
	else {
		pattern = $a[1];
		for(i = 2; i <= length(a); i++)
			pattern = pattern SUBSEP $a[i];
	}

	update();
	if(running)
		summarize();
}

END {
	if(!running)
		summarize();
}
