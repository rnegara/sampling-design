gl dirwork "C:\Dataset\Sub-Sectors\Cassava NTT EJ\Baseline IP2\SampangSumenep"

*set working directories
cd "$dirwork" 
use "$dirwork\cassava_sampang",clear

*create village unique id 
g iddesa=string(prov,"%02.0f")+string(kab,"%02.0f")+string(kec,"%03.0f")+string(desa,"%03.0f")

*create farmer unique id 
drop nurt
sort prov kab kec desa
by prov kab kec desa: g nurt=_n
g idfarmer=string(prov,"%02.0f")+string(kab,"%02.0f")+string(kec,"%03.0f")+string(desa,"%03.0f")+string(nurt,"%03.0f")



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

*sampling cluster at cluster level
preserve
g n=1
collapse (sum) n, by(iddesa)
gsample 4 [w=n] if n>5, wor /*exclude cluster with very low population*/
g selected_c=_n
tempfile s_cluster
save `s_cluster', replace 
restore
sort iddesa 
merge m:1 iddesa using `s_cluster'
drop _merge
replace selected_c=0 if selected_c==.
save selectedc_ss.dta, replace 


*sampling farmers for each selected cluster
keep if inrange(selected_c,1,4)
levelsof selected_c, local(village)												
foreach i of local village{ 
preserve
gsample 22 if selected_c==`i', wor 
save s_farmer`i', replace 
restore
}

use s_farmer1.dta, clear 
append using s_farmer2 s_farmer3 s_farmer4
g selected_f=1

merge 1:1 idfarmer using selectedc_ss
replace selected_f=0 if selected_f==.
save selected_ss_x.dta, replace
forval num=1/4{
mi erase s_farmer`num' 
}

*test the validity of sample
destring yield, replace
gen benchmark=runiform()
su  yield age benchmark
su  yield age benchmark if  selected_f==1

*see the distribution of sample
gen idkec=kab*1000+kec
gen iddesax=idkec*100+desa
tab idkec selected_f
tab iddesax selected_f

