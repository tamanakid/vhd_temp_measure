-- spi_controller.vhd
-- State machine that controls communication between FPGA modules and SPI slave sensor



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity spi_controller is
  port(
    -- global synchronization signals
    nRst  : in std_logic;
    clk   : in std_logic;
    
    -- Timing signals from spi_timer
    timer_ena_nCS   : in std_logic;
    spi_SC_up       : in std_logic;
    spi_SC_down     : in std_logic;
    spi_SI_read     : in std_logic;
    timer_2ms5_eoc  : in std_logic;
    timer_2sec_eoc  : in std_logic;
    
    -- Control signals to spi_timer
    ena_rd    : buffer std_logic;
    read_done : buffer std_logic
  );
end entity spi_controller;




architecture rtl of spi_controller is
  
  constant BITS_READ : natural := 9;            -- 9 bits to be read for a 1ºC resolution
  constant TIMER_READ_INTERVAL : natural := 4;  -- 4 seconds between each read operation
  
  
  type t_state is (off, power_up, ready, comm, wait_tristate);
  signal state            : t_state;
  
  signal read_bit_count   : std_logic_vector(4 downto 0); -- counts up to the 9 bits to be read.
  signal wait_2sec_count  : std_logic_vector(1 downto 0); -- counts up to 12 seconds of waiting time before another read.
  signal wait_done        : std_logic;

begin
  
  -- State machine (Automata)
  process(clk, nRst)
  begin
    if nRst = '0' then
      state <= off;
    elsif clk'event and clk = '1' then
      
      case state is   
        when off =>
          state <= power_up;
         
        when power_up =>
          if timer_ena_nCS = '1' then
            state <= comm;
          end if;          
         
        when comm =>
          if ena_rd = '0' then
            state <= wait_tristate;
          end if;
        
        when wait_tristate =>
          if spi_SC_down = '1' then  -- lasts 400 ns (double of 200 ns requirement)
            state <= ready;
          end if;

        when ready =>
          if ena_rd = '1' then
            state <= comm;
          end if;

      end case;
    end if;
  end process;
  
  
  
  
  -- Handle 'ena_rd' signal used at spi_interface to enable reading operations
  process(clk, nRst)
  begin
    if nRst = '0' then
      ena_rd <= '0';
      read_bit_count <= (others => '0');
      wait_2sec_count <= (0 => '1', others => '0');
  
    elsif clk'event and clk = '1' then
      
      -- Initial Enabling: At power_up state's ending
      if state = power_up and timer_ena_nCS = '1' then
        ena_rd <= '1';
      
      -- DISABLING ena_rd: when reading operation is done: 9 bits/cycles are counted.
      elsif state = comm then
        if read_done = '1' then
          read_bit_count <= (others => '0');
          ena_rd <= '0';

        elsif spi_SI_read = '1' then
          read_bit_count <= read_bit_count + 1;
        end if;
        
      
      -- ENABLING ena_rd: Start new read when required time interval transcurs (Default: 4 seconds - TIMER_READ_INTERVAL)
      elsif state = ready then
        if wait_done = '1' then
          wait_2sec_count <= (0 => '1', others => '0');
          ena_rd <= '1';
          
        elsif timer_2sec_eoc = '1' then
          wait_2sec_count <= wait_2sec_count + 1;
        end if;

      end if;
    end if;
  end process;
  
  read_done <= '1' when read_bit_count = BITS_READ and spi_SC_down = '1'
                   else '0';
  
  wait_done <= '1' when ((wait_2sec_count & '0') >= TIMER_READ_INTERVAL) and timer_2sec_eoc = '1'
                   else '0';
  

end rtl;