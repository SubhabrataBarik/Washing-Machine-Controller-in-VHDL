----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2023 10:39:36
-- Design Name: 
-- Module Name: Major_project - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Major_project is
  Port ( clk: in std_logic;lid,ex_rin,coin: in std_logic; on_off: out std_logic);
end Major_project;

architecture Behavioral of Major_project is

type state_variables1 is (pause1,soak1,wash1,rinse1,spin1,dry1);
type state_variables2 is (pause2,soak2,wash2,rinse2,spin2,dry2);

signal PS1,NS1 : state_variables1;
signal PS2,NS2: state_variables2;



signal count: std_logic_vector(36 downto 0) := "1000101001001000011001000000000000000";
-- 512 M Hz clock cycle to count to 145 secs
-- therefore no of cycles 512M * 145= 74,240,000,000; which is converted to binary.
begin


async_proc: process(clk,lid,coin)
begin
    if(lid = '1') then
        count<=count;
        on_off<='0';
    elsif(coin= '1') then
        count<= "1000101001001000011001000000000000000";
        PS1 <= soak1;
        PS2 <= soak2;
        on_off<='1';

    elsif( rising_edge(clk)) then
        if(count="0000000000000000000000000000000000000") THEN
            count<="1000101001001000011001000000000000000";
        else
            count<=count-1;
        end if;
        PS1<=NS1;
        PS2<=NS2;
        on_off<='1';
    end if; 
end process async_proc;

sync_proc: process(count,PS1,PS2)
begin
    if(ex_rin='1') THEN
    -- each state changes after 512M * 145/6 = 12,373,333,333.
    -- rinse runs two times
        Case PS2 is 
            when soak2 =>
            -- runs in between 74,240,000,000 to 61,866,666,667
                if(count<"0111001100111100010100110101010101011") then
                    NS2<= wash2;
                else
                    NS2<= soak2;
                end if;
            when wash2=>
            -- runs in between 61,866,666,667 and 49,493,333,334
                if(count< "0101110000110000010000101010101010110") then
                    NS2<= rinse2;
                else
                    NS2<= wash2;
                end if;
                
            when rinse2 =>
            -- runs in between 49,493,333,334 and 24,746,666,668
            -- this runs two times hence its duration is double of rest
                if(count<"0010111000011000001000010101010101100") then
                    NS2<= spin2;
                else
                    NS2<= rinse2;
                end if;
            
           When spin2 =>
           -- runs in between 24,746,666,668 and 12,373,333,333
                if(count< "0001011100001100000100001010101010101") then
                    NS2<= dry2;
                else
                    NS2<= spin2;
                end if;
            
            When dry2 =>
            -- runs in between 12,373,333,333 and 0
            if(count="0000000000000000000000000000000000000") then
                NS2<= pause2;
            else
                NS2<= dry2; 
            end if;
                
            when others =>
                NS2<= pause2;
        end case;
        
        
    else
        Case PS1 is 
        -- total time is 74,240,000,000. Time of one cycle 512M * 145/5= 14,848,000,000
            when soak1 =>
            -- runs in between 74,240,000,000 to 59,362,000,000
                if(count<"0110111010010010000000011110010000000") then
                    NS1<= wash1;
                else
                    NS1<= soak1;
                end if;
                
            when wash1=>
            -- runs in between 59,362,000,000 and 44,544,000,000
                if(count< "0101001011111000001111000000000000000") then
                    NS1<= rinse1;
                else
                    NS1<= wash1;
                end if;
                
            when rinse1 =>
            -- runs in between 44,544,000,000 and 29,696,000,000
                if(count<"0011011101010000001010000000000000000") then
                    NS1<= spin1;
                else
                    NS1<= rinse1;
                end if;
            
           When spin1 =>
           -- runs in between 29,696,000,000 and 14,848,000,000
                if(count< "0001101110101000000101000000000000000") then
                    NS1<= dry1;
                else
                    NS1<= spin1;
                end if;
            
            When dry1 =>
            -- runs in between 14,848,000,000 and 0
            if(count="0000000000000000000000000000000000000") then
                NS1<= pause1;
            else
                NS1<= dry1; 
            end if;
                
            when others =>
                NS1<= pause1;
        end case;
       end if;
    end process sync_proc;
 
end Behavioral;
