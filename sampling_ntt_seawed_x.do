
gl dirwork "C:\Dataset\Sub-Sectors\Seaweed NTT"
set more off

*set working directories
cd "$dirwork" 

log using mylog, replace

use "$dirwork\DatasetSeaweed",clear

*create village unique id 
g iddesa=string(codekab,"%02.0f")+string(codekec,"%03.0f")+string(codedes,"%03.0f")

sort codekab codekec codedes
by codekab codekec  codedes: gen nurt=_n

*create farmer unique id 
g idfarmer=string(codekab,"%02.0f")+string(codekec,"%03.0f")+string(codedes,"%03.0f")+string(nurt,"%03.0f")

drop if codekec==41

*sampling cluster at cluster level
g selected_c=0
gen n=1
save selectedc_ntt.dta, replace
forval num=1/15{
collapse (sum) n selected_c, by(iddesa)
gsample 1 [w=n] if selected_c==0, wor 
replace selected_c=`num'
drop n
save s_cluster`num', replace 
merge 1:m iddesa using selectedc_ntt
drop _merge
save selectedc_ntt.dta, replace 
}

forval num=1/15{
mi erase s_cluster`num' 
}

*sampling farmers for each selected cluster
keep if inrange(selected_c,1,15)
levelsof selected_c, local(village)												
foreach i of local village{ 
preserve
gsample 10 if selected_c==`i', wor 
save s_farmer`i', replace 
restore
}

use s_farmer1.dta, clear 
append using s_farmer2 s_farmer3 s_farmer4 s_farmer5 s_farmer6 s_farmer7 s_farmer8 s_farmer9 ///
s_farmer10 s_farmer11 s_farmer12 s_farmer13 s_farmer14 s_farmer15 
g selected_f=1

merge 1:1 idfarmer using selectedc_ntt
replace selected_f=0 if selected_f==.
save selected_ntt_x.dta, replace

forval num=1/15{
mi erase s_farmer`num' 
}

g jk=gender==1
gen benchmark=runiform()
su benchmark jk
su benchmark jk if selected_f==1

tab codekec selected_f

log close
