gl dirwork "C:\Dataset\Sub-Sectors\Seaweed NTT"

*set working directories
cd "$dirwork" 
use "$dirwork\DatasetSeaweed",clear

*create village unique id 
g iddesa=string(codekab,"%02.0f")+string(codekec,"%03.0f")+string(codedes,"%03.0f")

sort codekab codekec codedes
by codekab codekec  codedes: gen nurt=_n

*create farmer unique id 
g idfarmer=string(codekab,"%02.0f")+string(codekec,"%03.0f")+string(codedes,"%03.0f")+string(nurt,"%03.0f")

*replace codedes=99 if codedes==.

/*decide sample size based on the increase of income 20%, CL95% and MoE5%
sampsi 0 0.2, p(0.95) a(0.05)
gen size_t=r(N_1)
gen size_c=r(N_2)
gen size_tot=size_t + size_c

--based on raosoft where the sample size for MoE10% CL90%, we need 65 samples 
-->for precaution, we should add to 85 samples and mutiply by two for treatment and control group : 170 samples
there will be 3 district to be surveyed, hence from tulung agung we took 85 while sampang and sumenep we took 85 
for tulungagung we take 5 villages(cluster) from total 13 villages, and from each selected cluster we take 17 farmers 
*/

drop if codekec==41

*sampling cluster at cluster level
preserve
g n=1
collapse (sum) n, by(iddesa)
gsample 6 [w=n], wor
g selected_c=_n
tempfile s_cluster
save `s_cluster', replace 
restore
sort iddesa 
merge m:1 iddesa using `s_cluster'
drop _merge
replace selected_c=0 if selected_c==.
save selectedc_ntt.dta, replace 


*sampling farmers for each selected cluster
keep if inrange(selected_c,1,6)
levelsof selected_c, local(village)												
foreach i of local village{ 
preserve
gsample 10 if selected_c==`i', wor 
save s_farmer`i', replace 
restore
}

use s_farmer1.dta, clear 
append using s_farmer2 s_farmer3 s_farmer4 s_farmer5 s_farmer6 /*s_farmer7 s_farmer8 s_farmer9 ///
s_farmer10 s_farmer11 s_farmer12 s_farmer13 s_farmer14 s_farmer15 */
g selected_f=1

merge 1:1 idfarmer using selectedc_ntt
replace selected_f=0 if selected_f==.
save selected_ntt_x.dta, replace
forval num=1/6{
mi erase s_farmer`num' 
}


g jk=gender==1
su rand
su rand if selected_f==1

su jk
su jk if selected_f==1
