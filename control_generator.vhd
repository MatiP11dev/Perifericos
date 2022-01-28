----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2022 12:19:34 PM
-- Design Name: 
-- Module Name: control_generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity control_generator is
   generic(
   h_pulse:positive:=96;
   hbp:positive:=144;
   ha:positive:=784;
   hfp:positive:=800;
--Parte del clock vertical
   v_pulse:positive:=2;
   vbp:positive:=35;
   va:positive:=515;
   vfp:positive:=525   
   );
 Port (
   clk50: IN STD_LOGIC; --System clock (50MHz)
   clk25: BUFFER STD_LOGIC; --TMDS clock (25MHz)
   clk250: BUFFER STD_LOGIC; --Tx clock (250MHz)
   h_sync:buffer std_logic;
   v_sync:out std_logic;
   h_active:buffer std_logic;
   v_active:buffer std_logic;
   dena:out std_logic
  );
end control_generator;

architecture Behavioral of control_generator is
signal feedback: std_logic;
begin
PLL : PLLE2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
      CLKFBOUT_MULT => 5,        -- Multiply value for all CLKOUT, (2-64)
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
      CLKIN1_PERIOD => 20.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE => 1,
      --CLKOUT1_DIVIDE => 1,
      --CLKOUT2_DIVIDE => 1,
      --CLKOUT3_DIVIDE => 1,
     -- CLKOUT4_DIVIDE => 1,
     -- CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
      CLKOUT0_DUTY_CYCLE => 0.5,
    --  CLKOUT1_DUTY_CYCLE => 0.5,
    --  CLKOUT2_DUTY_CYCLE => 0.5,
    --  CLKOUT3_DUTY_CYCLE => 0.5,
    --  CLKOUT4_DUTY_CYCLE => 0.5,
    --  CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
     -- CLKOUT1_PHASE => 0.0,
     -- CLKOUT2_PHASE => 0.0,
     -- CLKOUT3_PHASE => 0.0,
     -- CLKOUT4_PHASE => 0.0,
     -- CLKOUT5_PHASE => 0.0,
      DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
      STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clk250,   -- 1-bit output: CLKOUT0
   --   CLKOUT1 => CLKOUT1,   -- 1-bit output: CLKOUT1
     -- CLKOUT2 => CLKOUT2,   -- 1-bit output: CLKOUT2
     -- CLKOUT3 => CLKOUT3,   -- 1-bit output: CLKOUT3
     -- CLKOUT4 => CLKOUT4,   -- 1-bit output: CLKOUT4
     -- CLKOUT5 => CLKOUT5,   -- 1-bit output: CLKOUT5
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => feedback, -- 1-bit output: Feedback clock
      LOCKED => OPEN,     -- 1-bit output: LOCK
      CLKIN1 => clk50,     -- 1-bit input: Input clock
      -- Control Ports: 1-bit (each) input: PLL control ports
      PWRDWN => '0',     -- 1-bit input: Power-down
      RST => '0',           -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => feedback   -- 1-bit input: Feedback clock
   );
 clk25_generador:process(clk50)
 begin
   if(rising_edge(clk50)) then
     clk25<=not clk25;
   end if;
 end process;
clk_horizontal_generator:process(clk25)
variable counter:integer range 0 to hfp:=0;
begin
 if rising_edge(clk25) then
    if(counter=h_pulse-1) then
      h_sync<='1';
    elsif(counter=hbp-1) then
      h_active<='1';
    elsif(counter=ha-1) then
      h_active<='0';
    elsif(counter=hfp-1) then
      h_sync<='0';
      counter:=0;
    end if;
    counter:=counter+1;     
 end if;
end process;
clk_vertical_generator:process(h_sync)
variable counter:integer range 0 to vfp:=0;
begin
 if rising_edge(h_sync) then
    if(counter=v_pulse-1) then
      v_sync<='1';
    elsif(counter=vbp-1) then
      v_active<='1';
    elsif(counter=va-1) then
      v_active<='0';
    elsif(counter=vfp-1) then
      v_sync<='0';
      counter:=0;
    end if;
    counter:=counter+1;     
 end if;
end process;
dena<=h_active and v_active;
end Behavioral;
