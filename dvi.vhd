----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2022 02:59:05 PM
-- Design Name: 
-- Module Name: dvi - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity dvi is

    Port ( 
    clk:in std_logic;
    tmds0_p:buffer std_logic;
    tmds0_n:buffer std_logic; 
    tmds1_p:buffer std_logic;
    tmds1_n:buffer std_logic;
    tmds2_p:buffer std_logic;
    tmds2_n:buffer std_logic;
    clk_p:buffer std_logic;
    clk_n:buffer std_logic;
    R,G,B:in std_logic_vector(7 downto 0)
    );
end dvi;

architecture Behavioral of dvi is
signal clk50,clk25,clk250,h_sync,v_sync,h_active,v_active,dena:std_logic;
signal control0,control1,control2:std_logic_vector(1 downto 0);
signal data0, data1, data2: STD_LOGIC_VECTOR(9 DOWNTO 0);
component serializer
 generic(
    bits:integer:=10
    );
    Port (
    reg_in:in std_logic_vector(bits-1 downto 0);
    clk: in std_logic;
    data_out: out std_logic 
    );
end component;
component control_generator
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
  end component;
  component tmds 
  Port ( 
  clk:in std_logic;
  dena:in std_logic;
  din:in std_logic_vector(7 downto 0);
  control:in std_logic_vector(1 downto 0);
  dout:out std_logic_vector(9 downto 0)
  );
end component;    
begin
control0<=h_sync & v_sync;
control1<="00";
control2<="00";
ctrl1: control_generator port map(clk,clk25,clk250,h_sync,v_sync,OPEN,v_active,dena);
tmds0:tmds port map(clk25,dena,R,control0,data0);
tmds1:tmds port map(clk25,dena,G,control1,data1);
tmds2:tmds port map(clk25,dena,B,control2,data2);
serial0:serializer port map(data0,clk250,tmds0_p);
serial1:serializer port map(data1,clk250,tmds1_p);
serial2:serializer port map(data2,clk250,tmds2_p);
tmds0_n<=not tmds0_p;
tmds1_n<=not tmds1_p;
tmds2_n<=not tmds2_p;
clk_p<=clk25;
clk_n<=not clk_p;
end Behavioral;
