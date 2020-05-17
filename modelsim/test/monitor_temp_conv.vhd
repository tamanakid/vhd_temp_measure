-- monitor_temp_conv.vhd
-- Ensures correct operation regarding temperature conversion


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_temp_conv.all;



entity monitor_temp_conv is
  port(
    -- global synchronization signals
    clk             : in      std_logic;
    nRst            : in      std_logic;
    
    -- configuration buttons inputs
    pulse_units     : in      std_logic;
    pulse_timing    : in      std_logic;
    
    -- sensor communication signals
    spi_SI          : in      std_logic;
    spi_SC          : in std_logic;
    spi_nCS         : in  std_logic;
    
    -- temperature output signals
    temperature_bcd : in std_logic_vector(11 downto 0);
    temperature_sgn : in std_logic;
    
    -- display module signals
    disp_mux        : in  std_logic_vector(4 downto 0);
    disp_seg        : in std_logic_vector(6 downto 0)
  );
end entity;



architecture test of monitor_temp_conv is

begin
  
  -- Monitor 1
  -- For Celsius units: test correct simulation increments by one degree
  process(clk, nRst)
    variable ena_assert : boolean := false;
    variable spi_nCS_T1 : std_logic;
    variable temp_integer_T1 : integer := 0;
    variable temp_integer_T2 : integer := 0;
    
  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;
    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
      
      if spi_nCS_T1 = '0' and spi_nCS = '1' then
        --report "Old measurement: " & integer'image(temp_integer_T2);
        --report "New measurement: " & integer'image(temp_bcd_to_integer(temperature_bcd, temperature_sgn));
       
       if temp_integer_T2 < 150 then
          assert temp_bcd_to_integer(temperature_bcd, temperature_sgn) = temp_integer_T2 + 1
          report "ERROR: Incorrect temperature increment by slave SPI simulation"
          severity error;
        end if;
      end if;
      
      spi_nCS_T1 := spi_nCS;
      temp_integer_T2 := temp_integer_T1;
      temp_integer_T1 := temp_bcd_to_integer(temperature_bcd, temperature_sgn);
      
    end if;
    
  end process;
  
end test;