#! /usr/bin/awk -f

# example:
#	$ ps aux | tail -n +2 | sort | cross-ordered.awk -v axis="1" -v summary="" | sort -nk 2 | sort
# will produce:
#	per axis (USER),
#		per summary (%CPU, %MEM, VSZ, RSS),
#			frequency of summary
#			minimum of summary
#			average of summary
#			maximum of summary
#			standard deviation of summary
#			summation of summary

function update(){
	for(i = 1; i <= length(s); i++){
		count[s[i]]++;

		delta = $s[i] - mean[s[i]];
		mean[s[i]] = mean[s[i]] + delta / count[s[i]];
		M2[s[i]] = M2[s[i]] + delta * ($s[i] - mean[s[i]]);

		if(count[s[i]] == 1){
			min[s[i]] = $s[i];
			max[s[i]] = $s[i];
		}
		if($s[i] < min[s[i]])
			min[s[i]] = $s[i];
		if(max[s[i]] < $s[i])
			max[s[i]] = $s[i];

		sum[s[i]] += $s[i];
	}
}

function summarize(){
	for(key in count){
		average = mean[key];

		# sample population variance
		# if(1 < count[key])
		# 	variance = M2[key] / (count[key] - 1);
		# else
		# 	variance = 0;

		# entire population variance
		variance = M2[key] / count[key];

		standardDeviation = sqrt(variance);
		print gensub(SUBSEP, OFS, "g", ppattern SUBSEP key), count[key], min[key], average, max[key], standardDeviation, sum[key];
	}
}

function reset(){
	delete count;
	delete mean;
	delete M2;
	delete min;
	delete max;
	delete sum;
}

BEGIN {
	if(!axis)
		axis = "-";
	split(axis, a);
	if(!summary)
		summary = "3 4 5 6";
	split(summary, s);
}

{
	if(axis == "-")
		pattern = axis;
	else {
		pattern = $a[1];
		for(i = 2; i <= length(a); i++)
			pattern = pattern SUBSEP $a[i];
	}

	if(pattern != ppattern){
		summarize();
		reset();
	}
	update();

	ppattern = pattern;
}

END {
	summarize();
}
