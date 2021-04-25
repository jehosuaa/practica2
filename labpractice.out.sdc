## Generated SDC file "labpractice.out.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"

## DATE    "Sun Apr 25 01:14:03 2021"

##
## DEVICE  "10CL006YU256A7G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {currentState.S0} -period 1.000 -waveform { 0.000 0.500 } [get_registers {currentState.S0}]
create_clock -name {clk} -period 1.000 -waveform { 0.000 0.500 } [get_ports {clk}]
create_clock -name {A[0]} -period 1.000 -waveform { 0.000 0.500 } [get_ports {A[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {A[0]}] -rise_to [get_clocks {A[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {A[0]}] -fall_to [get_clocks {A[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {A[0]}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {A[0]}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {A[0]}] -rise_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {A[0]}] -fall_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A[0]}] -rise_to [get_clocks {A[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {A[0]}] -fall_to [get_clocks {A[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {A[0]}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A[0]}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A[0]}] -rise_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A[0]}] -fall_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {currentState.S0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {currentState.S0}] -rise_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {currentState.S0}] -fall_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {currentState.S0}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {currentState.S0}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {currentState.S0}] -rise_to [get_clocks {currentState.S0}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {currentState.S0}] -fall_to [get_clocks {currentState.S0}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {currentState.S0}] -rise_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {currentState.S0}] -fall_to [get_clocks {A[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {currentState.S0}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {currentState.S0}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {currentState.S0}] -rise_to [get_clocks {currentState.S0}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {currentState.S0}] -fall_to [get_clocks {currentState.S0}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

