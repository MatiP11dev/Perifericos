----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2022 07:44:39 PM
-- Design Name: 
-- Module Name: tmds - Behavioral
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

entity tmds is
  Port ( 
  clk:in std_logic;
  dena:in std_logic;
  din:in std_logic_vector(7 downto 0);
  control:in std_logic_vector(1 downto 0);
  dout:out std_logic_vector(9 downto 0)
  );
end tmds;

architecture Behavioral of tmds is
signal x:std_logic_vector(8 downto 0);
signal onesx:integer range 0 to 8;
signal onesD:integer range 0 to 8;
signal disp:integer range -16 to 15;
signal dout_net: std_logic_vector(9 downto 0);
begin
------contador de '1' en el registro de entrada----------
process(din)
  variable counterD:integer range 0 to 8;
  begin  
  counterD:=0;
  for i in 0 to 7 loop
      if(din(i)='1') then
         counterD:=counterD+1;
      end if;
  end loop;
  onesD<=counterD;       
end process;
-------produce el vector interno de x-------------
process(din,onesD,x)
  begin
   x(0)<=din(0);
   if(onesD>4 or (onesD=4 and din(0)='0')) then
     x(1)<=din(1) xnor x(0);
     x(2)<=din(2) xnor x(1);
     x(3)<=din(3) xnor x(2);
     x(4)<=din(4) xnor x(3);
     x(5)<=din(5) xnor x(4);
     x(6)<=din(6) xnor x(5);
     x(7)<=din(7) xnor x(6);
     x(8)<='0';
   else
   x(1)<=din(1) xor x(0);
   x(2)<=din(2) xor x(1);
   x(3)<=din(3) xor x(2);
   x(4)<=din(4) xor x(3);
   x(5)<=din(5) xor x(4);
   x(6)<=din(6) xor x(5);
   x(7)<=din(7) xor x(6);
   x(8)<='1';
   end if;  
  end process;
-----------contador de '1' en el registro de x-----------
Process(x)
variable counterX:integer range 0 to 8;
begin
  counterX:=0;
  for i in 0 to 7 loop
     if(x(i)='1') then
       counterX:=counterX+1;   
     end if;
  end loop;
onesx<=counterX;     
end process;
------------produce la salida de de dout del tmds-----------
process(disp,dout_net, x, onesX, dena, control, clk)
variable disp_new:integer range -31 to 31;
begin
  if(dena='1') then
     dout_net(8)<=x(8);
     if(disp=0 or onesX=4) then
       dout_net(9)<=not x(8);
         if(x(8)='0') then
           dout_net(7 downto 0)<=not x(7 downto 0);
           disp_new:=disp-2*onesX+8;
         else 
           disp_new:=disp+2*onesX-8;
         end if;
     else
       if((disp>0 and onesX>4) or (disp<0 and onesX<4)) then
         dout_net(9)<='1';
         dout_net(7 downto 0)<=x(7 downto 0);
         if(x(8)='0') then
           disp_new:=disp-2*onesX+8;
         else
           disp_new:=disp-2*onesX+10;
         end if;
       else
         dout_net(9)<='0';
         dout_net(7 downto 0)<=x(7 downto 0);
         if(x(8)='0') then
           disp_new:=disp+2*onesX-10;
         else
           disp_new:=disp+2*onesX-8;
         end if;
       end if;
     end if;
   else
    disp_new:=0;
    if(control="00") then
      dout_net<="1101010100";
    elsif(control="01") then
      dout_net<="0010101011";
    elsif(control="10") then
      dout_net<="0101010100";
    else
      dout_net<="1010101011";
    end if; 
   end if;
   if(rising_edge(clk)) then
     disp<=disp_new;
   end if;
dout<=dout_net;                                
end process;
end Behavioral;
