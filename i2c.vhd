----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2021 08:16:30 PM
-- Design Name: 
-- Module Name: i2c - Behavioral
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

entity i2c is
 generic(
 fclk:positive:=50000;--frecuencia de reloj
 bps:positive :=400 --bits por segundo
 );
 Port ( 
   address:in std_logic_vector(7 downto 0);--direccion del dispositivo
   clk:in std_logic;--clk del sistema
   reset:in std_logic;--reset del i2c
   rw:in std_Logic;--bandera de lectura o escritura
   start_in:in std_logic;--entrada para empezar la comunicacion
   stop_in:in std_logic;-- entrada para terminar la comunicacion
   data:inout std_logic_vector(7 downto 0);--entrada/salida de datos
   sda:inout std_logic;--sda pin
   scl:out std_logic;--clock del i2c
   ack_error:out std_logic--error de ack
 );
end i2c;

architecture Behavioral of i2c is
type state is(idle,start,star_rd,wr_address,mem_address,rd_address,wr_data,
rd_data,ack1,ack2,ack3,ack4,no_ack,stop);--Estados del i2c
signal pr_state,nx_state:state;--estado anterior y siguiente para la maquina de estados
signal clk_data:std_logic;--clock de bus de datos
signal clk_scl:std_logic;--clk del scl
signal ack:std_logic_vector(2 downto 0);--ack
constant data_rate:positive:=fclk/bps/4;--tasa de datos
signal int_clk:std_logic:='0';--clock interno del i2c
signal rd_register:std_logic_vector(7 downto 0);--registro
shared variable timer:integer range 0 to 8:=1;--timer para la maquina de estados
shared variable i:integer range 0 to 8:=0;--contador de maquina de estados
attribute fsm_encoding:string;
attribute fsm_encoding of state: type is "sequential";--maquina de estados es de tipo secuencial
begin
ack_error<=ack(0) or ack(1) or ack(2);
-------------Process para generar reloj interno------------
process(clk) 
variable counter:integer range 0 to data_rate;
begin
 if(reset='1') then
   counter:=0;
 elsif(rising_edge(clk)) then 
      if(counter=data_rate-1) then
         int_clk<=not int_clk;
         counter:=0;
      else
         counter:=counter+1;
      end if;   
  end if;              
end process;
-----------Process para generar clock del i2c y del clk_data---------------
process(int_clk)
variable counter:integer range 0 to 3;
begin
  if reset='1' then
     counter:=0;
  elsif rising_edge(wire) then
     if(counter=0) then
         clk_scl<='0';
          counter:=counter+1;
     elsif(counter=1) then
         clk_data<='1';
          counter:=counter+1;
     elsif(counter=2) then
         clk_scl<='1';
         counter:=counter+1;
     elsif(counter=3) then
         clk_data<='0';
         counter:=0;    
     end if;
  end if;                   
end process;
------Maquina de estados---------
process(clk_data)
begin
  if reset='1' then
      pr_state<=idle;--Cuando el reset es 1 pasa al estado inicial
  elsif rising_edge(clk_data) then
     if(i=timer-1) then  --Contador para la maquina de estados
        pr_state<=nx_state;
        i:=0;
     else 
        i:=i+1;   
     end if;
  end if;
end process;
-----------Transiciones de maquina de estados-------------   
process(pr_state,start_in,stop_in,rd_register,data,sda,rw
,clk_data,clk_scl,address)
begin
case(pr_state) is
   when idle=>
        data<=(others=>'Z');
        scl<='1';
        sda<='1';
        timer:=1;
        if start_in='1' then
           nx_state<=start;
        else 
           nx_state<=idle;
        end if;      
  when start=>
       data<=(others=>'Z');
       sda<=clk_data;
       scl<='1';
       timer:=1;
       nx_state<=wr_address;
   when wr_address=>
        sda<=address(7-i);
        scl<=clk_scl;
        data<=(others=>'Z');
        timer:=8;
        nx_state<=ack1;
   when ack1=>
        sda<='Z';
        scl<=clk_scl;
        timer:=1;
        data<=(others=>'Z');
        nx_state<=mem_address;
   when mem_address=>
        sda<=data(7-i);
        scl<=clk_scl;
        timer:=8;
        nx_state<=ack2;
   when ack2=>
        sda<='Z';
        scl<=clk_scl;
        data<=(others=>'Z');
        timer:=1;
        if rw='0' then
           nx_state<=star_rd;
        else
           nx_state<=wr_data;
        end if;      
   when wr_data=>
        sda<=data(7-i);
        scl<=clk_scl;
        timer:=8;
        nx_state<=ack3;
   when star_rd=>
       sda<=clk_data;
       scl<='1';
       timer:=1;
       data<=(others=>'Z');
       nx_state<=rd_address;
   when rd_address=>
        sda<=rd_register(7-i);
        scl<=clk_scl;
        timer:=8;
        data<=(others=>'Z');
        nx_state<=ack3;
   when ack3=>
        sda<='Z';
        scl<=clk_scl;
        timer:=1;
        data<=(others=>'Z');
        if(rw='0') then
          nx_state<=rd_data;
        elsif rw='1' and stop_in='0' then
          nx_state<=wr_data;
        elsif rw='1' and stop_in='1' then
          nx_state<=stop;
        end if;     
   when rd_data=>
        data(7-i)<=sda;
        scl<=clk_scl;
        timer:=8;
        if stop_in='0' then
           nx_state<=ack4;
        else
           nx_state<=no_ack; 
        end if;     
   when ack4=>
        sda<='0';
        scl<=clk_scl;
        timer:=1;
        data<=(others=>'Z');
        nx_State<=rd_Data;
   when no_ack=>
        sda<='1';
        scl<=clk_scl;
        timer:=1;
        data<=(others=>'Z');
        nx_state<=stop;
   when stop=>
        sda<=clk_data;
        scl<='1';
        timer:=1;
        data<=(others=>'Z');
        nx_State<=idle;
   end case;
 end process;       
end Behavioral;
