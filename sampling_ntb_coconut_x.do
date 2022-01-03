clear
gl dirwork "C:\Dataset\Sub-Sectors\Coconut NTB"
set more off

*set working directories
cd "$dirwork" 

log using mylog, replace

use "$dirwork\lombok_utara",clear

/*create village unique id 
g iddesa=string(codekab,"%02.0f")+string(codekec,"%03.0f")+string(codedes,"%03.0f")
*/
/*sort codekab codekec codedes
sort desa
by desa: gen nurt=_n
*/
/*create farmer unique id 
g idfarmer=string(kode_desa,"%02.0f")+string(nurt,"%03.0f")
*/
g idfarmer=_n
sort desa
by desa: gen nurt=_n
*sampling cluster at cluster level
g selected_c=0
g n=1
egen pop_desa=sum(n), by(desa)
g l_lahan_ha=l_lahan_m2/10000
su l_lahan_ha if l_lahan_ha<1
g l_cat=l_lahan_ha<=1
egen tot_l_cat=sum(n), by(l_cat)
gen weight=pop_desa+tot_l_cat

save selectedc_lu.dta, replace
forval num=1/15{
keep weight selected_c nurt desa 
keep if nurt==1 
gsample 1 [w=weight] if selected_c==0, wor 
replace selected_c=`num'
drop n
save s_cluster`num', replace 
merge 1:m desa using selectedc_lu
drop _merge
save selectedc_lu.dta, replace 
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
append using s_farmer2 s_farmer3 s_farmer4 s_farmer5  s_farmer6 s_farmer7 s_farmer8 s_farmer9 ///
s_farmer10 s_farmer11 s_farmer12 s_farmer13 s_farmer14 s_farmer15
g selected_f=1

merge 1:1 idfarmer using selectedc_lu
replace selected_f=0 if selected_f==.
save selected_lu_x.dta, replace

forval num=1/15{
mi erase s_farmer`num' 
}

gen benchmark=runiform()
su benchmark jk l_lahan_m2 j_pohon
su benchmark jk l_lahan_m2 j_pohon if selected_f==1

log close
