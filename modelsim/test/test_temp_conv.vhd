
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity test_temp_conv is
end entity;



architecture test of test_temp_conv is
  
  signal clk          : std_logic;
  signal nRst         : std_logic;
  signal pulse_units  : std_logic;
  signal pulse_timing : std_logic;
  signal spi_nCS      : std_logic;
  signal spi_SC       : std_logic;
  signal spi_SI       : std_logic;
  signal disp_mux     : std_logic_vector(4 downto 0);
  signal disp_seg     : std_logic_vector(6 downto 0);
  

  constant T_clk: time := 20 ns;
  
  
  
begin
  
  -- ASSIGNMENT DECLARATIONS

  dut_medt: entity work.metd(struct)
    generic map(
      TIME_SPI_PERIOD   => 20,     -- 400 ns signal length
      TIME_2MS5_PERIOD  => 25,     -- 2.5 ms signal length (simulation: 10 us)
      TIME_2SEC_PERIOD  => 5,      --  2 sec signal length (simulation: 50 us)
      TIME_SPI_ENA_NCS  => 2       -- ena_nCS generated at 300 ms (simulation: 20 us)
    )
    port map(
      clk           => clk,
      nRst          => nRst,
      pulse_units   => pulse_units,
      pulse_timing  => pulse_timing,
      spi_nCS       => spi_nCS,
      spi_SC        => spi_SC,
      spi_SI        => spi_SI,
      disp_mux      => disp_mux,
      disp_seg      => disp_seg
    );
            

  slave: entity work.spi_slave(sim)
    port map(
      nRst => nRst,
      CS   => spi_nCS, 
      CL   => spi_SC,
      Tclk => T_clk,
      SDAT => spi_SI
    );


  
  -- SIMULATION PROCESSES

  -- clk process
  process
  begin
    clk <= '0';
    wait for T_clk/2;
    clk <= '1';
    wait for T_clk/2;
  end process;
  
  
  -- Stimuli process
  process
  begin
    nRst <= '0';
    pulse_units <= '0';
    pulse_timing <= '0';
    
    -- Asynchronous enable
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait until clk'event and clk = '1';
    nRst <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    
    
    -- Synchronous test
    
    
    -- Test temperature conversion
    
    for i in 1 to 191 loop
      
      -- wait for data reading to complete
      wait until spi_nCS'event and spi_nCS = '0';
      wait until spi_nCS'event and spi_nCS = '1';
      wait until clk'event and clk = '1';
      
      -- measure in celsius
      wait until clk'event and clk = '1';
      
      -- measure in kelvin
      pulse_units <= '1';
      wait for 10*T_clk;
      wait until clk'event and clk = '1';
      pulse_units <= '0';
      wait until clk'event and clk = '1';
      
      -- measure in fahrenheit
      pulse_units <= '1';
      wait for 10*T_clk;
      wait until clk'event and clk = '1';
      pulse_units <= '0';
      wait until clk'event and clk = '1';
      
      -- back to celsius
      pulse_units <= '1';
      wait for 10*T_clk;
      wait until clk'event and clk = '1';
      pulse_units <= '0';
      wait until clk'event and clk = '1';
      
    end loop;
    
    
    
    wait;

  end process;
  
end test;