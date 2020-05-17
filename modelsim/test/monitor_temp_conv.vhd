-- monitor_temp_conv.vhd
-- Ensures correct operation regarding temperature conversion


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity monitor_temp_conv is
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



architecture test of monitor_temp_conv is

begin
  
  -- Monitor 1
  -- Comprobar 
  process(clk, nRst)
    variable ena_assert : boolean := false;
    
  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;
    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    -- elsif clk'event and clk = '1' and ena_assert then
      
    end if;
    
  end process;
  
end test;