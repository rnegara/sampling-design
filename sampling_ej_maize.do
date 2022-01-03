
gl dirwork "C:\Dataset\Sub-Sectors\Maize EJ\ie"
set more off

*set working directories
cd "$dirwork" 

log using mylog, replace

use "$dirwork\farmlist.dta",clear

*sampling cluster at cluster level
g selected_c=0
gen n=1
gen idfarmer=_n
save selectedc_sumenep.dta, replace
forval num=1/10{
collapse (sum) n selected_c, by(poktan)
gsample 1 [w=n] if selected_c==0 & n>=10, wor 
replace selected_c=`num'
drop n
save s_cluster`num', replace 
merge 1:m poktan using selectedc_sumenep
drop _merge
save selectedc_sumenep.dta, replace 
}

forval num=1/10{
mi erase s_cluster`num' 
}

*sampling farmers for each selected cluster
keep if inrange(selected_c,1,10)
levelsof selected_c, local(fgroup)												
foreach i of local fgroup{ 
preserve
gsample 5 if selected_c==`i', wor 
save s_farmer`i', replace 
restore
}

use s_farmer1.dta, clear 
append using s_farmer2 s_farmer3 s_farmer4 s_farmer5 s_farmer6 s_farmer7 s_farmer8 s_farmer9 s_farmer10 
g selected_f=1

merge 1:1 idfarmer using selectedc_sumenep
replace selected_f=0 if selected_f==.
save selected_sumenep_x.dta, replace

forval num=1/10{
mi erase s_farmer`num' 
}


gen benchmark=runiform()
su benchmark jumlahbibit
su benchmark jumlahbibit if selected_f==1
tab poktan if selected_c>0

log close
