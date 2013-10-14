#! /usr/bin/awk -f

BEGIN {
	rowMax = 0;
	columnMax = 0;
}

{
	if(rowMax < NR)
		rowMax = NR;
	if(columnMax < NF)
		columnMax = NF;
	for(i = 1; i <= NF; i++)
		v[NR, i] = $i;
}

END {
	for(i = 1; i <= columnMax; i++){
		j = 1;
		line = v[j, i];
		for(j = 2; j <= rowMax; j++)
			line = line OFS v[j, i];
		print line;
	}
}
