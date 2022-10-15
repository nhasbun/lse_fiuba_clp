set_global_assignment -entity "pll_clk" -library "lib_pll_clk" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_clk" -library "lib_pll_clk" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "pll_clk" -library "lib_pll_clk" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_clk" -name SPD_FILE [file join $::quartus(sip_path) "pll_clk.spd"]

set_global_assignment -library "lib_pll_clk" -name MISC_FILE [file join $::quartus(sip_path) "pll_clk_sim/pll_clk.vho"]
