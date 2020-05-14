-- Test que genera, en 191 accesos a la interfaz SPI, la secuencia de datos de temperatura:
-- de 0 a +150 seguida de -40 a -1
 
-- Reloj 50 MHz
-- Es necesario completar la sentencia de emplazamiento del dut
-- El esclavo SPI funciona durante 191 accesos barriendo todas las posibles temperaturas y finalmente el mismo detiene el test

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity test_interfaz_spi is
end entity;



architecture test of test_interfaz_spi is
  signal clk        : std_logic;
  signal nRst       : std_logic;
  signal spi_nCS    : std_logic;
  signal spi_SC     : std_logic;
  signal spi_SI     : std_logic;

  constant T_clk: time := 20 ns;      


begin

  -- ASSIGNMENT DECLARATION

  dut_medt: entity work.metd(struct)
    generic map(
      TIME_SPI_PERIOD   => 20,     -- 400 ns signal length
      TIME_2MS5_PERIOD  => 25,     -- 2.5 ms signal length (simulation: 10 us)
      TIME_2SEC_PERIOD  => 5,      --  2 sec signal length (simulation: 50 us)
      TIME_SPI_ENA_NCS  => 2       -- ena_nCS generated at 300 ms (simulation: 20 us)
    )
    port map(
      clk     => clk,
      nRst    => nRst,
      spi_nCS => spi_nCS,
      spi_SC  => spi_SC,
      spi_SI  => spi_SI
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
    
    -- Asynchronous enable
    nRst <= '0';
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait until clk'event and clk = '1';
    nRst <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    
    -- Synchronous test
    -- No need for further stimuli: spi_slave performs the rest of the simulation
    
    wait;

  end process;

end test;





  
