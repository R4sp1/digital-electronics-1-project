library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_transmit is
 
  port (
    clk_i       : in  std_logic;
    tx_dv_i     : in  std_logic;				                            --Press button to send data
    tx_byte_i   : in  std_logic_vector(7 downto 0);
    en_i        : in  std_logic;
    res_en_o	: out std_logic;
    tx_active_o : out std_logic;
    tx_serial_o : out std_logic;
    tx_done_o   : out std_logic
    );
    
end UART_transmit;


architecture transmitter of UART_transmit is

  type t_Main is (s_passive, s_tx_start_bit, s_tx_data_bits, s_tx_stop_bit, s_clean);
  
  signal s_Main      : t_Main  := s_passive;
  signal s_bit_index : integer range 0 to 7 := 0;
  signal s_one_bits  : integer range 0 to 7 := 0;
  signal s_tx_data   : std_logic_vector(7 downto 0) := (others => '0');
  signal s_tx_done   : std_logic := '0';
  
begin

  
  UART_transmit : process (clk_i,en_i)
  begin
    if rising_edge(clk_i) then
        
      case s_Main is

        when s_passive =>                                                   --idle state
          tx_active_o <= '0';
          tx_serial_o <= '1';  
          s_tx_done   <= '1';
          s_bit_index <= 0;
          s_one_bits  <= 0;

          if tx_dv_i = '0' then                                             --if 0 goto start bit sequence
            s_tx_data <= tx_byte_i;
            res_en_o <= '0';
            s_Main <= s_tx_start_bit;
          else
            s_Main <= s_passive;
          end if;

        -- activate start bit, start bit = 0
        when s_tx_start_bit =>
	      res_en_o    <= '1';
          tx_active_o <= '1';
          tx_serial_o <= '0';
          s_tx_done   <= '0';

        -- assigning start/data bits
          if en_i = '0' then                                                --if enable == 1 send data bits
            s_Main   <= s_tx_start_bit;
          else
            s_Main   <= s_tx_data_bits;
          end if;

        -- activate data bits         
        when s_tx_data_bits =>
          tx_serial_o <= s_tx_data(s_bit_index);
          
          if en_i = '0' then
            s_Main   <= s_tx_data_bits;
          else	
            if s_bit_index < 7 then						                    -- send next bit
              s_bit_index <= s_bit_index + 1;
              s_Main   <= s_tx_data_bits;
            else
            	s_one_bits <= 0;
            	s_Main   <= s_tx_stop_bit;
            end if;
          end if;

        -- active stop bit, stop bit = 1
        when s_tx_stop_bit =>
          tx_serial_o <= '1';

          if en_i = '0' then
            s_Main   <= s_tx_stop_bit;
          else
	        s_tx_done   <= '1';
	        s_Main   <= s_clean;
          end if;

        -- clean process
        when s_clean =>
          tx_active_o <= '0';
          s_tx_done   <= '1';
	      if tx_dv_i = '0' then
	        s_Main <= s_clean;
	      else
	        s_Main   <= s_passive;
	      end if;
          
        -- passive state    
        when others =>
          s_Main <= s_passive;

      end case;
    end if;
  end process UART_transmit;

  tx_done_o <= s_tx_done;
  
end transmitter;
