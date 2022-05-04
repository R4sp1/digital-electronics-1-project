library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity UART_recive is
generic(
        g_PERIOD: integer := 650
        );
port(
    clk_i       : in  std_logic;
    rx_data_in  : in  std_logic;
    rx_data_out : out std_logic_vector (7 downto 0);
    reset	 : in std_logic
    );
end UART_recive;

architecture Behavioral of UART_recive is

    type rx_states_t is (s_idle, s_start, s_data, s_stop);
    signal rx_state: rx_states_t := s_idle;

    signal baud_rate_x16_clk  : std_logic := '0';
    signal rx_stored_data     : std_logic_vector(7 downto 0) := (others => '0');

begin

    x16_baud: process(clk_i)
    variable x16_baud_count: integer range 0 to (g_PERIOD - 1) := (g_PERIOD - 1);
    begin
        if rising_edge(clk_i) then
            if (reset = '1') then
                baud_rate_x16_clk <= '0';
                x16_baud_count := (g_PERIOD - 1);
            else
                if (x16_baud_count = 0) then
                    baud_rate_x16_clk <= '1';
                    x16_baud_count := (g_PERIOD - 1);
                else
                    baud_rate_x16_clk <= '0';
                    x16_baud_count := x16_baud_count - 1;
                end if;
            end if;
        end if;
    end process x16_baud;
    
    UART_rx: process(clk_i)
        variable bit_duration_count : integer range 0 to 15 := 0;
        variable bit_count          : integer range 0 to 7  := 0;
    begin
        if rising_edge(clk_i) then
            if (reset = '1') then
                rx_state <= s_idle;
                rx_stored_data <= (others => '0');
                rx_data_out <= (others => '0');
                bit_duration_count := 0;
                bit_count := 0;
            else
                if (baud_rate_x16_clk = '1') then     -- the rx works 16 times faster the baud rate frequency
                    case rx_state is
                    
                        when s_idle =>
                            rx_stored_data <= (others => '0');    -- clean the received data register
                            bit_duration_count := 0;              -- reset counters
                            bit_count := 0;
                            if (rx_data_in = '0') then             -- if the start bit received go to START sequnce
                                rx_state <= s_start;                 
                            end if;
                            
                        when s_start =>
                            if (rx_data_in = '0') then             -- verify that the start bit is preset
                                if (bit_duration_count = 7) then   
                                    rx_state <= s_data;              
                                    bit_duration_count := 0;
                                else
                                    bit_duration_count := bit_duration_count + 1;
                                end if;
                            else
                                rx_state <= s_idle;                  -- the start bit is not preset (false alarm)
                            end if;

                        when s_data =>
                            if (bit_duration_count = 15) then                -- wait for one enable impulse
                                rx_stored_data(bit_count) <= rx_data_in;     -- fill in the receiving register one received bit.
                                bit_duration_count := 0;
                                if (bit_count = 7) then                      -- when all 8 bit received, go to the STOP state
                                    rx_state <= s_stop;
                                    bit_duration_count := 0;
                                else
                                    bit_count := bit_count + 1;
                                end if;
                            else
                                bit_duration_count := bit_duration_count + 1;
                            end if;

                        when s_stop =>
                            if (bit_duration_count = 15) then      -- wait for one enable impulse
                                rx_data_out <= rx_stored_data;     -- transer the received data on the LEDs
                                rx_state <= s_idle;
                            else
                                bit_duration_count := bit_duration_count + 1;
                            end if;

                        when others =>
                            rx_state <= s_idle;
                            
                    end case;
                end if;
            end if;
        end if;
    end process UART_rx;

end Behavioral;
