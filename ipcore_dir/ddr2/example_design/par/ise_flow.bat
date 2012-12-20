./rem_files.bat

#Following coregen commands to be uncommented  when the parameter DEBUG_EN is changed from 0 to 1 in ddr2.v/.vhd file.
#coregen -b icon4_cg.xco
#coregen -b vio_async_in96_cg.xco
#coregen -b vio_async_in192_cg.xco
#coregen -b vio_sync_out32_cg.xco
#coregen -b vio_async_in100_cg.xco

#rm *.ncf
echo Synthesis Tool: XST

mkdir "../synth/__projnav" > ise_flow_results.txt
mkdir "../synth/xst" >> ise_flow_results.txt
mkdir "../synth/xst/work" >> ise_flow_results.txt

xst -ifn xst_run.txt -ofn mem_interface_top.syr -intstyle ise >> ise_flow_results.txt
ngdbuild -intstyle ise -dd ../synth/_ngo -nt timestamp -uc ddr2.ucf -p xc5vlx50ff676-1 ddr2.ngc ddr2.ngd >> ise_flow_results.txt

map -intstyle ise -detail -w -logic_opt off -ol high -xe n -t 1 -cm area -o ddr2_map.ncd ddr2.ngd ddr2.pcf >> ise_flow_results.txt
par -w -intstyle ise -ol high -xe n ddr2_map.ncd ddr2.ncd ddr2.pcf >> ise_flow_results.txt
trce -e 3 -xml ddr2 ddr2.ncd -o ddr2.twr ddr2.pcf >> ise_flow_results.txt
bitgen -intstyle ise -f mem_interface_top.ut ddr2.ncd >> ise_flow_results.txt

echo done!
