------------------------------------------------------------------------
--
-- Generates clock enable signal.
-- Nexys A7-50T, Vivado v2020.1.1, EDA Playground
--
-- Copyright (c) 2019-present Tomas Fryza
-- Dept. of Radio Electronics, Brno Univ. of Technology, Czechia
-- This work is licensed under the terms of the MIT license.
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;    -- Provides unsigned numerical computation

------------------------------------------------------------------------
-- Entity declaration for clock enable
------------------------------------------------------------------------
entity clock_enable is

port (
	g_NPERIOD	   : in std_logic_vector(16-1 downto 0);
    clk_i          : in  std_logic;
    srst_n_i       : in  std_logic;                                         -- Synchronous reset
    clock_enable_o : out std_logic
   
);
end entity clock_enable;

------------------------------------------------------------------------
-- Architecture declaration for clock enable
------------------------------------------------------------------------
architecture Behavioral of clock_enable is
    signal s_cnt : std_logic_vector(16-1 downto 0) := x"0000";
begin

    --------------------------------------------------------------------
    -- p_clk_enable:
    -- Generate clock enable signal instead of creating another clock 
    -- domain. By default enable signal is low and generated pulse is 
    -- always one clock long.
    --------------------------------------------------------------------
    p_clk_enable : process(clk_i)
    begin
        if rising_edge(clk_i) then                                          -- Rising clock edge
            if srst_n_i = '0' then                                          -- Synchronous reset
                s_cnt <= (others => '0');                                   -- Clear all bits
                clock_enable_o <= '0';
            else
                if s_cnt >= g_NPERIOD-1 then
                    s_cnt <= (others => '0');
                    clock_enable_o <= '1';
                else
                    s_cnt <= s_cnt + x"0001";
                    clock_enable_o <= '0';
                end if;
            end if;
        end if;
    end process p_clk_enable;

end architecture Behavioral;