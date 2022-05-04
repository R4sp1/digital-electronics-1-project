library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------
-- Entity declaration for top level
------------------------------------------------------------------------
entity top is
port (
    clk_i      	: in  std_logic;  	-- 100MHz clock signal
    reset       : in  std_logic;    -- hardware reset via button
    BTN0       	: in  std_logic;  	-- synchronous reset
    SW0_CPLD	: in  std_logic;	-- data (0)   for tx
    SW1_CPLD	: in  std_logic;	-- data (1)
    SW2_CPLD	: in  std_logic;	-- data (2)
    SW3_CPLD	: in  std_logic;	-- data (3)
    SW4_CPLD	: in  std_logic;	-- data (4)
    SW5_CPLD	: in  std_logic;	-- data (5)
    SW6_CPLD	: in  std_logic;  	-- data (6)
    SW7_CPLD	: in  std_logic;	-- data (7)
------------------------- control variables ----------------------------
    tx		    : out std_logic;  	-- tx pin
    active_o	: out std_logic;	-- transmitting active
    done_o	    : out std_logic; 	-- transmitting done (defalut value is HIGH)
    rx          : in  std_logic;    -- rx pin
    LED         : out std_logic_vector (7 downto 0) --LEDs to show recived sequence
               );
end entity top;

------------------------------------------------------------------------
-- Architecture declaration for top level
------------------------------------------------------------------------
architecture Behavioral of top is
    signal s_en	 	: std_logic;                          -- enable signal
    signal s_srst	: std_logic;                          -- synchronous reset
    signal s_bound 	: std_logic_vector(15 downto 0);      -- getting division ratio
    signal s_data  	: std_logic_vector(7 downto 0);       -- data going to tx
begin
    s_data(0) <= SW0_CPLD;                                -- get transmit sequnce from switches
    s_data(1) <= SW1_CPLD;
    s_data(2) <= SW2_CPLD;
    s_data(3) <= SW3_CPLD;
    s_data(4) <= SW4_CPLD;
    s_data(5) <= SW5_CPLD;
    s_data(6) <= SW6_CPLD;
    s_data(7) <= SW7_CPLD;

    --------------------------------------------------------------------
    -- Sub-block of clock_enable entity
    CLOCKE: entity work.clock_enable
   		  
        port map( 
		  g_NPERIOD       => s_bound,
		  srst_n_i        => s_srst,
          clock_enable_o  => s_en,
          clk_i           => clk_i
		);
    --------------------------------------------------------------------
    -- Sub-block of UART_transmit entity
    UART: entity work.UART_transmit
        port map (   
		   clk_i	   => clk_i,
		   tx_dv_i	   => BTN0,
		   tx_byte_i   => s_data,
		   en_i		   => s_en,
           res_en_o    => s_srst,
		   tx_active_o => active_o,	
		   tx_serial_o => tx,
		   tx_done_o   => done_o	
		 );
	--------------------------------------------------------------------
    -- Sub-block of UART_recive entity
	receiver : entity work.UART_recive
        port map (
            clk_i          => clk_i,
            reset          => reset,
            rx_data_in     => rx,
            rx_data_out    => LED
        );
    --------------------------------------------------------------------
    -- getting division ratio in HEX format      
    speed : process (clk_i)
    begin		
		if rising_edge(clk_i) then
		  s_bound <= x"28a0";	-- 10Mhz/10400 = 9615,38 baud; d10400 = x28a0
		end if;
    end process speed;	
					
end architecture Behavioral;