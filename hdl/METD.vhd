-- METD.vhd
-- Structural Module



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity metd is
  
  -- Determines synthesis or simulation (scaled) timing values to consider
  generic(
    TIME_SPI_PERIOD    : natural := 20;       -- 400 ns signal length
    TIME_2MS5_PERIOD   : natural := 6250;     -- 2.5 ms signal length (simulation: 25 - 10 us)
    TIME_2SEC_PERIOD   : natural := 800;       --  2 sec signal length (simulation:  5 - 50 us)
    -- 300 ms must pass after power-up for a conversion to complete before the LM71 actually transmits temperature data.
    TIME_SPI_ENA_NCS   : natural := 120   -- (120 cycles) * (2.5 ms/cycle) = 300 ms
  );
  
  
  port(
    clk       : in      std_logic;
    nRst      : in      std_logic;
    
    spi_SI    : in      std_logic;
    spi_SC    : buffer  std_logic;
    spi_nCS   : buffer  std_logic
    
    -- mux_disp  : buffer  std_logic_vector(4 downto 0);
    -- seg       : buffer  std_logic_vector(6 downto 0)
  );
end entity;



architecture struct of metd is
  
  signal ena_rd           : std_logic;
  signal read_done        : std_logic;
  signal timer_ena_nCS    : std_logic;
  signal spi_SC_up        : std_logic;
  signal spi_SC_down      : std_logic;
  signal spi_SI_read      : std_logic;
  signal timer_2ms5_eoc   : std_logic;
  signal timer_2sec_eoc   : std_logic;
  signal data_sensor      : std_logic_vector(8 downto 0);
  
  
begin
  
  timer: entity work.timer(rtl)
  generic map(
    TIME_SPI_PERIOD   => TIME_SPI_PERIOD,
    TIME_2MS5_PERIOD  => TIME_2MS5_PERIOD,
    TIME_2SEC_PERIOD  => TIME_2SEC_PERIOD,
    TIME_SPI_ENA_NCS  => TIME_SPI_ENA_NCS
  )
  port map(
    clk             => clk,
    nRst            => nRst,
    ena_rd          => ena_rd,
    timer_ena_nCS   => timer_ena_nCS,
    spi_SC_up       => spi_SC_up,
    spi_SC_down     => spi_SC_down,
    spi_SI_read     => spi_SI_read,
    timer_2ms5_eoc  => timer_2ms5_eoc,
    timer_2sec_eoc  => timer_2sec_eoc,
    spi_SC          => spi_SC,
    spi_nCS         => spi_nCS
  );

    
  
  spi_input_reg: entity work.spi_input_reg(rtl)
  port map(
    clk             => clk,
    nRst            => nRst,
    ena_rd          => ena_rd,
    spi_SI_read     => spi_SI_read,
    spi_SI          => spi_SI,
    data_sensor     => data_sensor
  );
  


  spi_controller: entity work.spi_controller(rtl)
  port map(
    clk             => clk,
    nRst            => nRst,
    ena_rd          => ena_rd,
    read_done       => read_done,
    timer_ena_nCS   => timer_ena_nCS,
    spi_SC_up       => spi_SC_up,
    spi_SC_down     => spi_SC_down,
    spi_SI_read     => spi_SI_read,
    timer_2ms5_eoc  => timer_2ms5_eoc,
    timer_2sec_eoc  => timer_2sec_eoc
  );
  
end struct;