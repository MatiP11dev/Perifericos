----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2022 02:38:31 PM
-- Design Name: 
-- Module Name: serializer - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity serializer is
    generic(
    bits:integer:=10
    );
    Port (
    reg_in:in std_logic_vector(bits-1 downto 0);
    clk: in std_logic;
    data_out: out std_logic 
    );
end serializer;

architecture Behavioral of serializer is
signal internal:std_logic_vector(bits-1 downto 0);
begin
process(clk)
variable max:integer:=bits-1;
variable counter:integer range 0 to max;
begin
  if(rising_edge(clk)) then
     counter:=counter+1;
     if(counter=max)then
       internal<=reg_in; 
     else
       counter:=0;
     end if;
  data_out<=internal(counter);     
  end if;  
end process;

end Behavioral;
