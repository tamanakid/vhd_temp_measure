-- spi_timer.vhd
-- Timing module to synchronize spi_interface (or spi_controller) data exchange activity



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity timer is
  
  -- Determines synthesis or simulation (scaled) timing values to consider
  generic(
    TIME_SPI_PERIOD    : natural := 20;       -- 400 ns signal length
    TIME_2MS5_PERIOD   : natural := 6250;     -- 2.5 ms signal length (simulation: 25 - 10 us)
    TIME_2SEC_PERIOD   : natural := 800;       --  2 sec signal length (simulation:  5 - 50 us)
    -- 300 ms must pass after power-up for a conversion to complete before the LM71 actually transmits temperature data.
    TIME_SPI_ENA_NCS   : natural := 120   -- (120 cycles) * (2.5 ms/cycle) = 300 ms
  );
  
  
  port(
    -- global synchronization signals
    nRst  : in std_logic;
    clk   : in std_logic;
    
    -- Control signals from spi_controller
    ena_rd  : in std_logic;
    
    -- Timing signals to spi_controller
    timer_ena_nCS   : buffer std_logic;
    spi_SC_up       : buffer std_logic;
    spi_SC_down     : buffer std_logic;
    spi_SI_read     : buffer std_logic;
    timer_2ms5_eoc  : buffer std_logic;
    timer_2sec_eoc  : buffer std_logic;
    
    -- SPI clock and chip select generation
    spi_SC  : buffer std_logic;
    spi_nCS : buffer std_logic    
  );
end entity;





architecture rtl of timer is
  
  
  
  -- SPI communication constants (clk: 20 ns == 50 MHz)
  -- Total cycle length: 400 ns (2.5 MHz) - 20 clock cycles
  -- 200 ns: SC low
  -- 200 ns: SC high
  -- 100 ns into SC high: SI read
  
  constant TIME_SPI_SC_HI     : natural := 10;    -- 200 ns pulse length
  constant TIME_SPI_SI_RD     : natural := 15;    -- 100 ns into SC_UP
  constant TIME_SPI_SC_LO     : natural := 20;    -- 200 ns pulse length
  
  
  -- internal signals
  signal timer_spi        : std_logic_vector(4 downto 0);     -- base 20 counter (400 ns)
  signal timer_spi_eoc    : std_logic;
  signal timer_2ms5       : std_logic_vector(12 downto 0);    -- base 6250 counter (2.5 ms)
  signal timer_2sec       : std_logic_vector(9 downto 0);     -- base 800 counter (2 sec)
  
  
begin
  
  -- SPI timer counter (base 20 - 400 ns)
  -- Enabled by input ena_nrst_timer
  process(clk, nRst)
  begin
    if nRst = '0' then
      timer_spi <= (0 => '1', others => '0');

    elsif clk'event and clk = '1' then
      
      if timer_spi_eoc = '1' then
        timer_spi <= (0 => '1', others => '0');

      else
        timer_spi <= timer_spi + 1;
		
      end if;
    end if;
  end process;

  timer_spi_eoc <= '1' when timer_spi = TIME_SPI_PERIOD else '0';
  
  
  -- Enable SC conmutations or read operations
  spi_SC_up     <= '1' when timer_spi = TIME_SPI_SC_HI else '0';
  spi_SI_read   <= '1' when timer_spi = TIME_SPI_SI_RD else '0';
  spi_SC_down   <= '1' when timer_spi = TIME_SPI_SC_LO else '0';
  
  
  -- 2.5 ms timer (base 6250)
  -- For modulo_presentacion
  process(nRst, clk)
  begin
    if nRst = '0' then
      timer_2ms5 <= (0 => '1', others => '0');
    elsif clk'event and clk = '1' then
  
      if timer_2ms5_eoc = '1' then
        timer_2ms5 <= (0 => '1', others => '0');
      
      elsif timer_spi_eoc = '1' then
        timer_2ms5 <= timer_2ms5 + 1;
      
      end if;      
    end if;
  end process;
  
  timer_2ms5_eoc <= '1' when timer_2ms5 = TIME_2MS5_PERIOD and timer_spi_eoc = '1' else '0';  
    
  -- enable conversions after 300 ms delay
  timer_ena_nCS <= '1' when timer_2sec = TIME_SPI_ENA_NCS and timer_2ms5_eoc = '1' else '0';
  
  
  
  
  -- 2 seconds timer (base 800)
  -- For sensor requests
  process(nRst, clk)
  begin
    if nRst = '0' then
      timer_2sec <= (0 => '1', others => '0');
    elsif clk'event and clk = '1' then

      if timer_2sec_eoc = '1' then
        timer_2sec <= (0 => '1', others => '0');
      
      elsif timer_2ms5_eoc = '1' then
        timer_2sec <= timer_2sec + 1;
      
      end if;      
    end if;
  end process;
  
  timer_2sec_eoc <= '1' when timer_2sec = TIME_2SEC_PERIOD and timer_2ms5_eoc = '1' else '0';
  
  
  
  
  -- SC  and nCS Generation
  -- Buffered as to avoid glitches
  process(clk, nRst)
  begin
    if nRst = '0' then
      spi_SC <= '0';
      spi_nCS <= '1';
    elsif clk'event and clk = '1' then
    
      if ena_rd = '1' then
        spi_nCS <= '0';
        if spi_SC_up = '1' then
          spi_SC <= '1';
	      elsif spi_SC_down = '1' then
          spi_SC <= '0';
        end if;

      else
        spi_nCS <= '1';
        spi_SC <= '0';
      end if;
	   
    end if;
  end process;
  
  
  
  
end rtl;
  