-- METD.vhd
-- Structural Module



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_temp_conv.all;



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
    -- global synchronization signals
    clk           : in      std_logic;
    nRst          : in      std_logic;
    
    -- configuration buttons inputs
    pulse_units   : in      std_logic;
    pulse_timing  : in      std_logic;
    
    -- sensor communication signals
    spi_SI        : in      std_logic;
    spi_SC        : buffer  std_logic;
    spi_nCS       : buffer  std_logic;
    
    -- display module signals
    disp_mux      : buffer  std_logic_vector(4 downto 0);
    disp_seg      : buffer  std_logic_vector(6 downto 0)
  );
end entity;



architecture struct of metd is
  
  -- SPI communication related signals
  signal ena_rd             : std_logic;
  signal read_done          : std_logic;
  signal timer_ena_nCS      : std_logic;
  signal spi_SC_up          : std_logic;
  signal spi_SC_down        : std_logic;
  signal spi_SI_read        : std_logic;
  signal timer_2ms5_eoc     : std_logic;
  signal timer_2sec_eoc     : std_logic;
  signal data_sensor        : std_logic_vector(8 downto 0);
  
  -- pulse filter related signals
  signal toggle_units       : std_logic;
  signal toggle_timing      : std_logic;
  
  -- Conversion related signals
  signal temperature_bin    : std_logic_vector(8 downto 0);
  signal temperature_sgn    : std_logic;
  signal temp_units         : t_unit;
  signal temperature_bcd    : std_logic_vector(11 downto 0);
  
  
begin
  
  -- Timer interface
  
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
  
  
  
  -- Pulses filter
  
  pulses_filter: entity work.pulses_filter(rtl)
  port map(
    clk             => clk,
    nRst            => nRst,
    pulse_units     => pulse_units,
    pulse_timing    => pulse_timing,
    toggle_units    => toggle_units,
    toggle_timing   => toggle_timing
  );
  

  
  
  -- SPI input register
  
  spi_input_reg: entity work.spi_input_reg(rtl)
  port map(
    clk             => clk,
    nRst            => nRst,
    ena_rd          => ena_rd,
    spi_SI_read     => spi_SI_read,
    spi_SI          => spi_SI,
    data_sensor     => data_sensor
  );
  


  -- SPI controller module

  spi_controller: entity work.spi_controller(rtl)
  port map(
    clk             => clk,
    nRst            => nRst,
    ena_rd          => ena_rd,
    read_done       => read_done,
    toggle_timing   => toggle_timing,
    timer_ena_nCS   => timer_ena_nCS,
    spi_SC_up       => spi_SC_up,
    spi_SC_down     => spi_SC_down,
    spi_SI_read     => spi_SI_read,
    timer_2ms5_eoc  => timer_2ms5_eoc,
    timer_2sec_eoc  => timer_2sec_eoc
  );
  
  
  
  -- Conversion module: 2C to binary
  
  temp_conversion: entity work.temp_conversion(rtl)
  port map(
    clk               => clk,
    nRst              => nRst,
    data_sensor       => data_sensor,
    read_done         => read_done,
    toggle_units      => toggle_units,
    temperature_bin   => temperature_bin,
    temperature_sgn   => temperature_sgn,
    temp_units        => temp_units
  );
  
  
  
  
  -- Conversion module: binary to BCD
  
  temp_binary_to_bcd: entity work.temp_binary_to_bcd(rtl)
  port map(
    temperature_bin   => temperature_bin,
    temperature_bcd   => temperature_bcd
  );
  
  
  
  -- Display module output
  
  display_module: entity work.display_module(rtl)
  port map(
    clk         => clk,
    nRst        => nRst,
    tic         => timer_2ms5_eoc,
    temp_units  => temp_units,
    sgn         => temperature_sgn,
    mod_BCD     => temperature_bcd,
    mux_disp    => disp_mux,
    seg         => disp_seg
  );
  
  
end struct;