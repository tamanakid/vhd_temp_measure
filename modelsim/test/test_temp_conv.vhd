
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity test_temp_conv is
end entity;



architecture test of test_temp_conv is
  
  signal clk              : std_logic;
  signal nRst             : std_logic;
  signal pulse_units      : std_logic;
  signal pulse_timing     : std_logic;
  signal spi_nCS          : std_logic;
  signal spi_SC           : std_logic;
  signal spi_SI           : std_logic;
  signal temperature_bcd  : std_logic_vector(11 downto 0);
  signal temperature_sgn  : std_logic;
  signal disp_mux         : std_logic_vector(4 downto 0);
  signal disp_seg         : std_logic_vector(6 downto 0);
  

  constant T_clk: time := 20 ns;
  constant time_spi_period : natural := 20;
  constant time_2ms5_period : natural := 5;
  constant time_2sec_period : natural := 25;
  
  
  
begin
  
  -- ASSIGNMENT DECLARATIONS

  dut_medt: entity work.metd(struct)
    generic map(
      TIME_SPI_PERIOD   => time_spi_period,     -- 400 ns signal length
      TIME_2MS5_PERIOD  => time_2ms5_period,    -- 2.5 ms signal length (simulation: 2 us)
      TIME_2SEC_PERIOD  => time_2sec_period,    --  2 sec signal length (simulation: 50 us)
      TIME_SPI_ENA_NCS  => 2                    -- ena_nCS generated at 300 ms (simulation: 4 us)
    )
    port map(
      clk             => clk,
      nRst            => nRst,
      pulse_units     => pulse_units,
      pulse_timing    => pulse_timing,
      spi_nCS         => spi_nCS,
      spi_SC          => spi_SC,
      spi_SI          => spi_SI,
      temperature_bcd => temperature_bcd,
      temperature_sgn => temperature_sgn,
      disp_mux        => disp_mux,
      disp_seg        => disp_seg
    );
            

  slave: entity work.spi_slave(sim)
    port map(
      nRst => nRst,
      CS   => spi_nCS, 
      CL   => spi_SC,
      Tclk => T_clk,
      SDAT => spi_SI
    );


  autoverificacion_temp_conv: entity work.monitor_temp_conv(test)
    port map(
      clk             => clk,
      nRst            => nRst,
      pulse_units     => pulse_units,
      pulse_timing    => pulse_timing,
      spi_nCS         => spi_nCS,
      spi_SC          => spi_SC,
      spi_SI          => spi_SI,
      temperature_bcd => temperature_bcd,
      temperature_sgn => temperature_sgn,
      disp_mux        => disp_mux,
      disp_seg        => disp_seg
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
    
    for i in 1 to 38 loop
      
      for j in 1 to 5 loop
        -- wait for data reading to complete
        wait until spi_nCS'event and spi_nCS = '0';
        wait until spi_nCS'event and spi_nCS = '1';
        wait until clk'event and clk = '1';
      
        -- measure in celsius
        wait for (T_clk * time_spi_period * (time_2ms5_period * 5));
        wait until clk'event and clk = '1';
      
        -- measure in kelvin
        pulse_units <= '1';
        wait until clk'event and clk = '1';
        pulse_units <= '0';
        wait for (T_clk * time_spi_period * (time_2ms5_period * 5));
        wait until clk'event and clk = '1';
      
        -- measure in fahrenheit
        pulse_units <= '1';
        wait for 10*T_clk;
        wait until clk'event and clk = '1';
        pulse_units <= '0';
        wait for (T_clk * time_spi_period * (time_2ms5_period * 5));
        wait until clk'event and clk = '1';
      
        -- back to celsius
        pulse_units <= '1';
        wait for 6*T_clk;
        wait until clk'event and clk = '1';
        pulse_units <= '0';
        wait for (T_clk * time_spi_period * (time_2ms5_period * 5));
        wait until clk'event and clk = '1';
      end loop;
      
      -- Change sampling time every 5 samples
      wait until clk'event and clk = '1';
      pulse_timing <= '1';
      wait for 3*T_clk;
      wait until clk'event and clk = '1';
      pulse_timing <= '0';
      wait until clk'event and clk = '1';
      
      
    end loop;
    
    
    
    wait;

  end process;
  
end test;