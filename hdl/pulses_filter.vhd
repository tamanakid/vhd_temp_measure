-- pulses_filter.vhd
-- conformador de pulsos para filtrar presionado de botones p1 y p2


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity pulses_filter is
  port(
    -- global synchronization signals
    nRst  : in std_logic;
    clk   : in std_logic;
    
    -- pulses inputs
    pulse_units   : in std_logic;
    pulse_timing  : in std_logic;
    
    -- filtered pulses outpus
    toggle_units  : buffer std_logic;
    toggle_timing : buffer std_logic
  );
end entity;



architecture rtl of pulses_filter is
  
  -- flip-flop arrays for input synchronization and metastability (MS) prevention
  signal units_sync     : std_logic_vector(4 downto 0);
  signal timing_sync    : std_logic_vector(4 downto 0);
  
begin
  
  -- input synchronization and MS prevention (For each pulse: 4 ff for MS filtering + 1 ff for pulse state monitoring)
  -- NOTE: pulse inputs are '0' when on, '1' when off
  process(clk, nRst)
  begin
    if nRst = '0' then
      units_sync <= (others => '1');
      timing_sync <= (others => '1');

    elsif clk'event and clk = '1' then
      units_sync <= units_sync(3 downto 0) & pulse_units;
      timing_sync <= timing_sync(3 downto 0) & pulse_timing;
      
    end if;
  end process;


  -- Filtered pulses outputs are '1' when on, '0' when off.
  
  -- filtered pulse: temperature units (celsius, kelvin, fahrenheit)
  toggle_units <= '1' when units_sync(4) = '1' and units_sync(3) = '0' else '0';
  
  -- filtered pulse: sampling interval (4-12 seconds)
  toggle_timing <= '1' when timing_sync(4) = '1' and timing_sync(3) = '0' else '0';
  

end rtl;

