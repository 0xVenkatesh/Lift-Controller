## Clock signal
set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "CLK"
set_property IOSTANDARD LVCMOS33 [get_ports {clk}];
create_clock -period 1000.000 -name clk -waveform {0 500} [get_ports clk]

#INSIDE AND OUTSIDE BUTTONS
set_property PACKAGE_PIN P16 [get_ports {i_l[1]}];  # "BTNC"
set_property IOSTANDARD LVCMOS18 [get_ports {i_l[1]}];

set_property PACKAGE_PIN R16 [get_ports {i_l[2]}];  # "BTND"
set_property IOSTANDARD LVCMOS18 [get_ports {i_l[2]}];

set_property PACKAGE_PIN N15 [get_ports {i_u[0]}];  # "BTNL"
set_property IOSTANDARD LVCMOS18 [get_ports {i_u[0]}];

set_property PACKAGE_PIN R18 [get_ports {i_d[1]}];  # "BTNR"
set_property IOSTANDARD LVCMOS18 [get_ports {i_d[1]}];


set_property PACKAGE_PIN T18 [get_ports {i_l[0]}];  # "BTNU"
set_property IOSTANDARD LVCMOS18 [get_ports {i_l[0]}];

set_property PACKAGE_PIN H17 [get_ports {i_u[1]}];  # "SW6"
set_property IOSTANDARD LVCMOS18 [get_ports {i_u[1]}];

set_property PACKAGE_PIN M15 [get_ports {i_d[0]}];  # "SW7"
set_property IOSTANDARD LVCMOS18 [get_ports {i_d[0]} ];


#LEDS
set_property PACKAGE_PIN T22 [get_ports {led[0]}];  # "LD0"
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}];

set_property PACKAGE_PIN T21 [get_ports {led[1]}];  # "LD1"
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}];

set_property PACKAGE_PIN U22 [get_ports {led[2]}];  # "LD2"
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}];

set_property PACKAGE_PIN V22 [get_ports {D}];  # "LD4"
set_property IOSTANDARD LVCMOS33 [get_ports {D}];

set_property PACKAGE_PIN W22 [get_ports {STOP}];  # "LD5"
set_property IOSTANDARD LVCMOS33 [get_ports {STOP}];

set_property PACKAGE_PIN U19 [get_ports {UP}];  # "LD6"
set_property IOSTANDARD LVCMOS33 [get_ports {UP}];

set_property PACKAGE_PIN U14 [get_ports {v}];  # "LD7"
set_property IOSTANDARD LVCMOS33 [get_ports {v}];

#SENSORS
set_property PACKAGE_PIN F22 [get_ports {sf[0]}];  # "SW0"
set_property IOSTANDARD LVCMOS18 [get_ports {sf[0]}];

set_property PACKAGE_PIN G22 [get_ports {si[0]}];  # "SW1"
set_property IOSTANDARD LVCMOS18 [get_ports {si[0]}];

set_property PACKAGE_PIN H22 [get_ports {sf[1]}];  # "SW2"
set_property IOSTANDARD LVCMOS18 [get_ports {sf[1]}];

set_property PACKAGE_PIN F21 [get_ports {si[1]}];  # "SW3"
set_property IOSTANDARD LVCMOS18 [get_ports {si[1]}];

set_property PACKAGE_PIN H19 [get_ports {sf[2]}];  # "SW4"
set_property IOSTANDARD LVCMOS18 [get_ports {sf[2]}];

#RESET
set_property PACKAGE_PIN H18 [get_ports {rst_n}];  # "SW5"
set_property IOSTANDARD LVCMOS18 [get_ports {rst_n}];
