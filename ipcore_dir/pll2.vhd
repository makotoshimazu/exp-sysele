--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.3
--  \   \         Application : xaw2vhdl
--  /   /         Filename : pll2.vhd
-- /___/   /\     Timestamp : 12/20/2012 13:47:08
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: xaw2vhdl-st /home/denjo/Dropbox/lecture/term6/sysele/sysele_day9/ipcore_dir/pll2.xaw /home/denjo/Dropbox/lecture/term6/sysele/sysele_day9/ipcore_dir/pll2
--Design Name: pll2
--Device: xc5vlx50-3ff676
--
-- Module pll2
-- Generated by Xilinx Architecture Wizard
-- Written for synthesis tool: XST
-- For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT0 = 0.142 ns
-- For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT1 = 0.142 ns
-- For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT2 = 0.142 ns

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity pll2 is
   port ( CLKIN1_IN   : in    std_logic; 
          RST_IN      : in    std_logic; 
          CLKOUT0_OUT : out   std_logic; 
          CLKOUT1_OUT : out   std_logic; 
          CLKOUT2_OUT : out   std_logic; 
          LOCKED_OUT  : out   std_logic);
end pll2;

architecture BEHAVIORAL of pll2 is
   signal CLKFBOUT_CLKFBIN : std_logic;
   signal CLKOUT0_BUF      : std_logic;
   signal CLKOUT1_BUF      : std_logic;
   signal CLKOUT2_BUF      : std_logic;
   signal GND_BIT          : std_logic;
   signal GND_BUS_5        : std_logic_vector (4 downto 0);
   signal GND_BUS_16       : std_logic_vector (15 downto 0);
   signal VCC_BIT          : std_logic;
begin
   GND_BIT <= '0';
   GND_BUS_5(4 downto 0) <= "00000";
   GND_BUS_16(15 downto 0) <= "0000000000000000";
   VCC_BIT <= '1';
   CLKOUT0_BUFG_INST : BUFG
      port map (I=>CLKOUT0_BUF,
                O=>CLKOUT0_OUT);
   
   CLKOUT1_BUFG_INST : BUFG
      port map (I=>CLKOUT1_BUF,
                O=>CLKOUT1_OUT);
   
   CLKOUT2_BUFG_INST : BUFG
      port map (I=>CLKOUT2_BUF,
                O=>CLKOUT2_OUT);
   
   PLL_ADV_INST : PLL_ADV
   generic map( BANDWIDTH => "OPTIMIZED",
            CLKIN1_PERIOD => 12.500,
            CLKIN2_PERIOD => 10.000,
            CLKOUT0_DIVIDE => 2,
            CLKOUT1_DIVIDE => 2,
            CLKOUT2_DIVIDE => 2,
            CLKOUT0_PHASE => 0.000,
            CLKOUT1_PHASE => 180.000,
            CLKOUT2_PHASE => 0.000,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT1_DUTY_CYCLE => 0.500,
            CLKOUT2_DUTY_CYCLE => 0.500,
            COMPENSATION => "SYSTEM_SYNCHRONOUS",
            DIVCLK_DIVIDE => 1,
            CLKFBOUT_MULT => 6,
            CLKFBOUT_PHASE => 0.0,
            REF_JITTER => 0.000000)
      port map (CLKFBIN=>CLKFBOUT_CLKFBIN,
                CLKINSEL=>VCC_BIT,
                CLKIN1=>CLKIN1_IN,
                CLKIN2=>GND_BIT,
                DADDR(4 downto 0)=>GND_BUS_5(4 downto 0),
                DCLK=>GND_BIT,
                DEN=>GND_BIT,
                DI(15 downto 0)=>GND_BUS_16(15 downto 0),
                DWE=>GND_BIT,
                REL=>GND_BIT,
                RST=>RST_IN,
                CLKFBDCM=>open,
                CLKFBOUT=>CLKFBOUT_CLKFBIN,
                CLKOUTDCM0=>open,
                CLKOUTDCM1=>open,
                CLKOUTDCM2=>open,
                CLKOUTDCM3=>open,
                CLKOUTDCM4=>open,
                CLKOUTDCM5=>open,
                CLKOUT0=>CLKOUT0_BUF,
                CLKOUT1=>CLKOUT1_BUF,
                CLKOUT2=>CLKOUT2_BUF,
                CLKOUT3=>open,
                CLKOUT4=>open,
                CLKOUT5=>open,
                DO=>open,
                DRDY=>open,
                LOCKED=>LOCKED_OUT);
   
end BEHAVIORAL;


