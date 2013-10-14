#! /usr/bin/awk -f

BEGIN {
	split(row, r);
	split(column, c);
	split(summary, s);
}

{
	rp = "";
	if(length(r)){
		i = 1;
		rp = $r[i];
		for(i = 2; i <= length(r); i++)
			rp = rp SUBSEP $r[i];
		rv[rp]++;
	}
	else
		rv[rp] = "";

	cp = "";
	if(length(c)){
		j = 1;
		cp = $c[j];
		for(j = 2; j <= length(c); j++)
			cp = cp SUBSEP $c[j];
		cv[cp]++;
	}
	else
		cv[cp] = "";

	for(sp = 1; sp <= length(s); sp++)
		v[rp, cp, sp] = $s[sp];
}

END {
	i = 1;
	for(cp in cv){
		split(cp, ch, SUBSEP);
		for(sp = 1; sp <= length(s); sp++){
			for(j = 1; j <= length(ch); j++)
				header[j, length(s) * (i - 1) + sp] = ch[j];
			header[j, length(s) * (i - 1) + sp] = s[sp];
		}
		i++;
	}
	for(k = 1; k <= j; k++){
		line = "";
		for(l = 1; l < length(r); l++)
			line = line OFS;
		l = 1;
		if(!length(r))
			line = header[k, l];
		else
			line = line OFS header[k, l];
		for(l = 2; l <= length(s) * (i - 1); l++)
			line = line OFS header[k, l];
		print line;
	}
	for(rp in rv){
		if(length(r)){
			line = gensub(SUBSEP, OFS, "g", rp);
			for(cp in cv)
				for(sp = 1; sp <= length(s); sp++)
					line = line OFS v[rp, cp, sp];
		}
		else
			for(cp in cv){
				sp = 1;
				line = v[rp, cp, sp];
				for(sp = 2; sp <= length(s); sp++)
					line = line OFS v[rp, cp, sp];
			}
		print line;
	}
}
