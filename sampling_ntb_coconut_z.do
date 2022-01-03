clear
gl dirwork "C:\Dataset\Sub-Sectors\Coconut NTB"
set more off

*set working directories
cd "$dirwork" 

use "$dirwork\lombok_utara",clear

g n=1
sort desa
egen pop_desa=sum(n), by (desa)
gsample 150 [w=pop_desa], wor
g selected_f=1

merge 1:1 kec desa no using "$dirwork\lombok_utara"
replace selected_f=0 if selected_f==.

gen benchmark=runiform()
su benchmark jk l_lahan_m2 j_pohon
su benchmark jk l_lahan_m2 j_pohon if selected_f==1
