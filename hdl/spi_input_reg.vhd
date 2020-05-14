-- spi_interface.vhd
-- communication module with SPI sensor



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity spi_input_reg is
  port(
    -- global synchronization signals
    nRst  : in std_logic;
    clk   : in std_logic;
    
    -- Control signal from spi_controller
    ena_rd  : in std_logic;
    
    -- Timing signal from spi_timer
    spi_SI_read  : in std_logic;
    
    -- Input signal from SPI slave
    spi_SI  :     in std_logic;
    
    -- Data read from sensor
    data_sensor : buffer std_logic_vector(8 downto 0)
  );
end entity;



architecture rtl of spi_input_reg is
  
  signal spi_SI_buffer  : std_logic_vector(1 downto 0);
  
begin
  
  -- Buffering asynchronous input spi_SI (double buffering to avoid metastability)
  -- Incurs in a 40 ns delay, which does not affect current functionality (actual sampling occurs at least 130 ns after data is placed)
  process(clk, nRst)
  begin
    if nRst = '0' then
      spi_SI_buffer <= "00";
    elsif clk'event and clk = '1' then
      spi_SI_buffer <= spi_SI_buffer(0) & spi_SI;
    end if;
  end process;
  
  
  
  -- SIPO Shift Register for incoming data from slave
  process(clk, nRst)
  begin
    if nRst = '0' then
      data_sensor <= (others => '0');
    elsif clk'event and clk = '1' then
      
      if ena_rd = '1' and spi_SI_read = '1' then
        data_sensor <= data_sensor(7 downto 0) & spi_SI_buffer(1);
      end if;

    end if;
  end process;
  
  
end rtl;
  