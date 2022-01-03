gl dirwork "C:\Dataset\Sub-Sectors\Cassava NTT EJ\Baseline IP2"

*set working directories
cd "$dirwork" 
use "$dirwork\c_tulungagung",clear

*buat id desa
g iddesa=string(prov,"%02.0f")+string(kab,"%02.0f")+string(kec,"%03.0f")+string(desa,"%03.0f")

*buat id petani
g idfarmer=string(prov,"%02.0f")+string(kab,"%02.0f")+string(kec,"%03.0f")+string(desa,"%03.0f")+string(nurt,"%03.0f")


/*decide sample size based on the increase of income 20%, CL95% and MoE5%
sampsi 0 0.2, p(0.95) a(0.05)
gen size_t=r(N_1)
gen size_c=r(N_2)
gen size_tot=size_t + size_c

*based on raosoft the sample size for MoE10% CL90%, we need 65 samples 
-->for precaution, we should add to 85 samples and mutiply by two for treatment and control group : 170 samples
there will be 3 district to be surveyed, hence from tulung agung we took 85 while sampang and sumenep we took 85 
for tulungagung we take 5 villages(cluster) from total 13 villages, and from each selected cluster we take 17 farmers 
*/

/*
gen n=1
egen pop_desa=sum(n), by(iddesa)

*sampling cluster at farmer level
gsample 5 [w=pop_desa], cluster(iddesa) 
*/

*sampling cluster at cluster level
preserve
g n=1
collapse (sum) n, by(iddesa)
gsample 5 [w=n], wor
g selected_c=_n
tempfile s_cluster
save `s_cluster', replace 

restore
sort iddesa 
merge m:1 iddesa using `s_cluster'
drop _merge
replace selected_c=0 if selected_c==.

preserve
keep if selected_c==1
gsample 17, wor
*g selected_f=1
tempfile s_farmer1
save `s_farmer1', replace 
restore

preserve
keep if selected_c==2
gsample 17, wor
*g selected_f=1
tempfile s_farmer2
save `s_farmer2', replace 
restore

preserve
keep if selected_c==3
gsample 17, wor
*g selected_f=1
tempfile s_farmer3
save `s_farmer3', replace 
restore

preserve
keep if selected_c==4
gsample 17, wor
*g selected_f=1
tempfile s_farmer4
save `s_farmer4', replace 
restore

preserve
keep if selected_c==5
gsample 17, wor
append using `s_farmer1' `s_farmer2' `s_farmer3' `s_farmer4' 
g selected_f=1
tempfile s_farmer
save `s_farmer', replace 
restore

merge 1:1 idfarmer using `s_farmer'
replace selected_f=0 if selected_f==.
save selected_tulungagung.dta, replace
