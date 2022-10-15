ghdl -i --std=08 vga_sync.vhd pattern_gen.vhd vga_module_tb.vhd
ghdl -m --std=08 vga_module_tb
ghdl -r --std=08 vga_module_tb --vcd=vga_module_tb.vcd --stop-time=17ms 

# gtkwave vga_module_tb.vcd
# gtkwave vga_module_tb.gtkw --rcvar 'fontname_signals Monospace 8' --rcvar 'fontname_waves Monospace 8'
