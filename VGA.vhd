----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2021 06:17:19 PM
-- Design Name: 
-- Module Name: VGA - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA is
   generic(
   fclk:positive:=50000;--clock del sistema
   p_clk:positive:=25175;--Clock del pixel
--Parte del clock horizontal  
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
   red,green,blue:out std_logic_vector(9 downto 0);--salida del bus rojo, verde y azul
   hsync,vsync:out std_logic;--salida del clock horizontal y vertical
   clk:in std_logic--entrada del clock del sistema
   );
end VGA;

architecture Behavioral of VGA is
signal divider:integer:=fclk/p_clk/2;--divisor para generar el pixel_clk
signal pixel_clk:std_logic;--es el pixel_clock que se encuentra adrentro del vga
signal h_sync,v_sync: std_logic;--son los clock horizontal y vertical
signal h_active:std_logic;--activa el horizontal
signal v_active:std_logic;--activa vertical
signal dena:std_logic;
begin
-----------Process que genera el clock del pixel-----------------
process(clk)
variable counter:integer:=0;
begin
  if rising_edge(clk) then
     if(counter=divider-1) then
        pixel_clk<=not pixel_clk;
        end if;
     else 
     counter:=counter+1;   
    end if;
end process;
-----------Process que genera el clock horizontal-----------------
process(pixel_clk)
variable counter:integer range 0 to hfp:=0;
begin
 if rising_edge(pixel_clk) then
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
-----------Process que genera el clock vertical-----------------
process(h_sync)
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
----------image generator-----------
dena<=h_active and v_active;
process(dena)
variable line_counter:integer:=0;
begin
  if v_sync='1' then
  line_counter:=0;
  elsif rising_edge(h_sync) then
      if v_active='1' then
         line_counter:=line_counter+1;   
        end if;
  end if;
  if(dena='1') then
    if line_counter=1 then
       red<=(others=>'1');
       green<=(others=>'0');
       blue<=(others=>'0');
     end if;
    elsif line_counter>1 and line_counter<=3 then
       red<=(others=>'0');
       green<=(others=>'1');
       blue<=(others=>'0');
    elsif line_counter>3 and line_counter <=6 then
       red<=(others=>'0');
       green<=(others=>'0');
       blue<=(others=>'1');
    else
       red<=(others=>'0');
       green<=(others=>'0');
       blue<=(others=>'0');                
  end if;
end process; 
end Behavioral;
