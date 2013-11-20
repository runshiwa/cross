#! /usr/bin/awk -f

# example:
#   $ tail -n +2 ps-aux.txt | sort -nk 1 | cross-ordered.awk -v axis="1" -v summary="" | sort -nk 2 | sort | diff ps-aux1.txt -
# 1st level fine grain summary by cross-ordered.awk, compare with cross.awk
#   $ tail -n +2 ps-aux.txt | cross-ordered.awk -v axis="-" -v summary="" | sort -nk 2 | sort | diff ps-aux2.txt -
# 2nd level rough summary by cross-ordered.awk, compare with cross.awk
#   $ sort -nk 2 ps-aux1.txt | aggregate-ordered.awk -v axis="2" -v summary="" | awk '{print "-",$0}' | sort -nk 2 | sort | diff ps-aux2.txt -
# 2nd summary by aggregate-ordered.awk from 1st summary, then compare
#   $ for i in 3 4 5 6; do tail -n +2 ps-aux.txt | awk -v s=$i '{print "-",s,1,$s,$s,$s,0}' | aggregate-ordered.awk -v axis="1 2" -v summary="3 4 5 6 7"; done | diff ps-aux2.txt -
# 2nd summary by aggregate-ordered.awk from raw data, then compare
#   $ ping www.google.co.jp | awk --source 'BEGIN{FS="[ =():]+";axis="";summary="2 3 4 5 6";running=1}NR==1{print;next}{if(end==1||NF==0){end=1;print;next};$0="-" OFS 1 OFS $11 OFS $11 OFS $11 OFS 0}' -f aggregate-ordered.awk
# print per ping statistics

function update(){
	na = count;
	count += $s[1];

	delta = $s[3] - mean;
	if($s[1] == 1)
		mean = (na * mean + $s[1] * $s[3]) / count;
	else
		mean = mean + delta * $s[1] / count;
	M2b = $s[5] * $s[5] * $s[1];
	M2 = M2 + M2b + delta * delta * (na * $s[1] / count);

	if(na == 0){
		min = $s[2];
		max = $s[4];
	}
	if($s[2] < min)
		min = $s[2];
	if(max < $s[4])
		max = $s[4];

	sum += $s[5];
}

function summarize(){
	average = mean;
	variance = M2 / count;
	standardDeviation = sqrt(variance);
	print gensub(SUBSEP, OFS, "g", ppattern), count, min, average, max, standardDeviation, sum;
}

function reset(){
	count = 0;
	mean = 0;
	M2 = 0;
	min = 0;
	max = 0;
	sum = 0;
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

	if(ppattern && pattern != ppattern){
		if(!running)
			summarize();
		reset();
	}
	update();

	ppattern = pattern;
	if(running)
		summarize();
}

END {
	if(!running)
		summarize();
}
