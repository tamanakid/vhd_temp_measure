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
  
  signal units_on   : std_logic;
  signal timing_on  : std_logic;
  
begin
  
  -- pulse: temperature units (celsius, kelvin, fahrenheit)
  process(clk, nRst)
  begin
    if nRst = '0' then
      toggle_units <= '0';
      units_on <= '0';
    elsif clk'event and clk = '1' then
      
      if pulse_units = '1' and units_on = '0' then
        toggle_units <= '1';
        units_on <= '1';
      elsif units_on = '1' and pulse_units = '0' then
        toggle_units <= '0';
        units_on <= '0';
      else
        toggle_units <= '0';
      end if;
      
    end if;
  end process;
  
  
  -- pulse: sampling interval (4, 6, 8, 10, 12 seconds)
  process(clk, nRst)
  begin
    if nRst = '0' then
      toggle_timing <= '0';
      timing_on <= '0';
    elsif clk'event and clk = '1' then
      
      if pulse_timing = '1' and timing_on = '0' then
        toggle_timing <= '1';
        timing_on <= '1';
      elsif timing_on = '1' and pulse_timing = '0' then
        toggle_timing <= '0';
        timing_on <= '0';
      else
        toggle_timing <= '0';
      end if;
      
    end if;
  end process;
  

end rtl;

