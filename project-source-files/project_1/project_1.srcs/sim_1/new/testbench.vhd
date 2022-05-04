LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         clk_i 	    : IN  std_logic;
         BTN0 		: IN  std_logic;
         SW0_CPLD   : IN  std_logic;
         SW1_CPLD   : IN  std_logic;
         SW2_CPLD   : IN  std_logic;
         SW3_CPLD   : IN  std_logic;
         SW4_CPLD   : IN  std_logic;
         SW5_CPLD   : IN  std_logic;
         SW6_CPLD   : IN  std_logic;
         SW7_CPLD   : IN  std_logic;
         tx 		: OUT  std_logic;
         active_o   : OUT  std_logic;
         done_o 	: OUT  std_logic;
         LED        : out std_logic_vector (7 downto 0);
         rx         : in  std_logic;
         reset      : in  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i     : std_logic;
   signal BTN0 	    : std_logic := '1';   -- 1 passive state -- 0 active state
   signal SW0_CPLD  : std_logic := '1';   -- Data to transmit
   signal SW1_CPLD  : std_logic := '0';
   signal SW2_CPLD  : std_logic := '1';
   signal SW3_CPLD  : std_logic := '0';
   signal SW4_CPLD  : std_logic := '1';
   signal SW5_CPLD  : std_logic := '0';
   signal SW6_CPLD  : std_logic := '1';
   signal SW7_CPLD  : std_logic := '0';

 	-- Transmit outputs
   signal tx 		: std_logic; 
   signal active_o  : std_logic;
   signal done_o 	: std_logic;
   
   -- Recive inputs
   signal rx_data_out    : std_logic_vector (7 downto 0) := (others => '0');
   signal rx_serial_in   : std_logic := '1';
   signal reset          : std_logic := '0';         -- hardware reset set to LOW
	
   -- Clock period definitions
   constant clk_i_period : time := 10 ns;   -- 10ns period = 100MHz

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          clk_i     => clk_i,
          BTN0      => BTN0,
          SW0_CPLD  => SW0_CPLD,
          SW1_CPLD  => SW1_CPLD,
          SW2_CPLD  => SW2_CPLD,
          SW3_CPLD  => SW3_CPLD,
          SW4_CPLD  => SW4_CPLD,
          SW5_CPLD  => SW5_CPLD,
          SW6_CPLD  => SW6_CPLD,
          SW7_CPLD  => SW7_CPLD,
          tx		=> tx,
          active_o  => active_o,
          done_o    => done_o,
          LED       => rx_data_out,
          rx        => rx_serial_in,
          reset     => reset
        );
        
        rx_serial_in <= tx;

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
      wait for clk_i_period*10000;
		
		BTN0 <= '0';                    -- start sending bits in 8N1 UART standart at 9600 baud
		wait for clk_i_period*400;
		
		BTN0 <= '1';					-- return to passsive state
		wait for clk_i_period*200;	
      wait;
   end process;

END;