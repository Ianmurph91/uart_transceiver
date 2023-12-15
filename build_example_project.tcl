set buid_dir [ file dirname [ file normalize [ info script ] ] ]

create_project -force uart_example ${buid_dir}/uart_example -part xc7z014sclg484-1

import_files -fileset sources_1 -norecurse ${buid_dir}/UART.vhd
import_files -fileset sources_1 -norecurse ${buid_dir}/receiver.vhd
import_files -fileset sources_1 -norecurse ${buid_dir}/transmitter.vhd
update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
import_files -fileset sim_1 -norecurse ${buid_dir}/testbench.sv
update_compile_order -fileset sim_1

launch_simulation
open_wave_config ${buid_dir}/testbench_behav.wcfg
run 1700 us