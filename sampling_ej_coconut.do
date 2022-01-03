clear
gl dirwork "C:\Dataset\Sub-Sectors\Coconut EJ"
set more off

*set working directories
cd "$dirwork" 

log using mylog, replace

use "$dirwork\pacitan",clear

/*create village unique id 
g iddesa=string(codekab,"%02.0f")+string(codekec,"%03.0f")+string(codedes,"%03.0f")
*/
*sort codekab codekec codedes
sort kode_desa
by kode_desa: gen nurt=_n

*create farmer unique id 
g idfarmer=string(kode_desa,"%02.0f")+string(nurt,"%03.0f")

*sampling cluster at cluster level
g selected_c=0
gen n=1
save selectedc_pctn.dta, replace
forval num=1/5{
collapse (sum) n selected_c, by(kode_desa)
gsample 1 [w=n] if selected_c==0, wor 
replace selected_c=`num'
drop n
save s_cluster`num', replace 
merge 1:m kode_desa using selectedc_pctn
drop _merge
save selectedc_pctn.dta, replace 
}

forval num=1/5{
mi erase s_cluster`num' 
}

*sampling farmers for each selected cluster
keep if inrange(selected_c,1,5)
levelsof selected_c, local(village)												
foreach i of local village{ 
preserve
gsample 30 if selected_c==`i', wor 
save s_farmer`i', replace 
restore
}

use s_farmer1.dta, clear 
append using s_farmer2 s_farmer3 s_farmer4 s_farmer5  
g selected_f=1

merge 1:1 idfarmer using selectedc_pctn
replace selected_f=0 if selected_f==.
save selected_pctn_x.dta, replace

forval num=1/5{
mi erase s_farmer`num' 
}

gen benchmark=runiform()
su benchmark b1r1 b1r2 b2r1 b9r1 b9r1s1	b9r2 b9r2s1	b9r3 b9r3s1
su benchmark b1r1 b1r2 b2r1 b9r1 b9r1s1	b9r2 b9r2s1	b9r3 b9r3s1 if selected_f==1

log close
