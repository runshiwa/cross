#! /usr/bin/awk -f

BEGIN {
	split(rowHeader, rh);
	split(columnHeader, ch);

	print "<table" tableAttribute ">";
}

{
	print "<tr" rowAttribute">";
	for(i = 1; i <= NF; i++){
		isHeader = 0;
		for(h in ch)
			if(NR == h){
				isHeader = 1;
				break;
			}
		if(!isHeader)
			for(h in rh)
				if(i == h){
					isHeader = 1;
					break;
				}
		if(isHeader){
			run = 0;
			if(suppressRun)
				for(j = i + 1; j <= NF; j++)
					if($i == $j)
						run++;
					else
						break;
			if(suppressRun && run)
				print "<th colspan=\"" run + 1 "\"" headerAttribute ">" $i "</th>";
			else
				print "<th" headerAttribute ">" $i "</th>";
			i += run;
		}
		else
			print "<td" dataAttribute ">" $i "</td>";
	}
	print "</tr>";
}

END {
	print "</table>"
}
