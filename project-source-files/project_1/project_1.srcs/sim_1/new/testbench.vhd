LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         clk_i 	: IN  std_logic;
         BTN0 		: IN  std_logic;
         SW0_CPLD : IN  std_logic;
         SW1_CPLD : IN  std_logic;
         SW2_CPLD : IN  std_logic;
         SW3_CPLD : IN  std_logic;
         SW4_CPLD : IN  std_logic;
         SW5_CPLD : IN  std_logic;
         SW6_CPLD : IN  std_logic;
         SW7_CPLD : IN  std_logic;
         LD0 		: OUT  std_logic;
         active_o  : OUT  std_logic;
         done_o 	: OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i    : std_logic;
   signal BTN0 	   : std_logic := '0';   -- 1 passive state -- 0 active state
   signal SW0_CPLD : std_logic := '1';
   signal SW1_CPLD : std_logic := '0';
   signal SW2_CPLD : std_logic := '1';
   signal SW3_CPLD : std_logic := '0';
   signal SW4_CPLD : std_logic := '1';
   signal SW5_CPLD : std_logic := '0';
   signal SW6_CPLD : std_logic := '1';
   signal SW7_CPLD : std_logic := '0';

 	--Outputs
   signal LD0 		: std_logic;
   signal active_o : std_logic;
   signal done_o 	: std_logic;
	
   -- Clock period definitions
   constant clk_i_period : time := 0.12 ms;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          clk_i 	 => clk_i,
          BTN0		 => BTN0,
          SW0_CPLD => SW0_CPLD,
          SW1_CPLD => SW1_CPLD,
          SW2_CPLD => SW2_CPLD,
          SW3_CPLD => SW3_CPLD,
          SW4_CPLD => SW4_CPLD,
          SW5_CPLD => SW5_CPLD,
          SW6_CPLD => SW6_CPLD,
          SW7_CPLD => SW7_CPLD,
          LD0		 => LD0,
          active_o  => active_o,
          done_o	 => done_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns
      wait for 100 ns;	
      wait for clk_i_period*10;
		
		BTN0 <= '0';						-- even parity, 110 bit/s, one stop bit
		wait for clk_i_period*1400;
		
				
		BTN0 <= '1';						--	even parity, 600 bit/s, one stop bit
		wait for clk_i_period*200;		
		BTN0 <= '0';
		wait for clk_i_period*300;
		
		BTN0 <= '1';						-- passsive state
		wait for clk_i_period*200;	
      wait;
   end process;

END;