
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity temp_conversion is
  port(
    -- global synchronization signals
    nRst  : in std_logic;
    clk   : in std_logic;
    
    -- input data: data read from sensor, read done flag and unit changes button-press
    data_sensor       : in std_logic_vector(8 downto 0);
    read_done         : in std_logic;
    toggle_conv_units : in std_logic;
    
    -- outputs: binary temperature and units
    temperature_bin : buffer std_logic_vector(8 downto 0);
    temperature_sgn : buffer std_logic;
    conv_units      : buffer std_logic_vector(1 downto 0)        
  );
end entity;



architecture rtl of temp_conversion is
  
  constant SUM_FAHRENHEIT : natural := 32;
  constant SUM_KELVIN     : natural := 273;
  
  -- Two's complement signals for all units
  signal temp_celsius_2c        : std_logic_vector(8 downto 0);
  signal temp_fahrenheit_term1  : std_logic_vector(9 downto 0);
  signal temp_fahrenheit_2c     : std_logic_vector(9 downto 0);
  signal temp_kelvin_2c         : std_logic_vector(9 downto 0);
  
  -- channel selector output
  signal temperature_2c        : std_logic_vector(9 downto 0);
  
  
  -- DUDA 2:
  -- type units_t is (celsius, kelvin, fahrenheit);
  -- ENTITY: conv_units : buffer units_t;
  
begin
  
  -- Conversion units state machine
  -- 00: celsius - 01: kelvin - 10: fahrenheit
  process(clk, nRst)
  begin
    if nRst = '0' then
      conv_units <= "00";
    elsif clk'event and clk = '1' then
      
      if toggle_conv_units = '1' then
        case conv_units is
          when "00" =>
            conv_units <= "01";
          when "01" =>
            conv_units <= "10";
          when others =>
            conv_units <= "00";
        end case;
      end if;
      
    end if;
  end process;
  
  
  
  -- Parse data from sensor at read_done flag activation
  process(clk,nRst)
  begin
    if nRst = '0' then
      temp_celsius_2c <= (others => '0');
    elsif clk'event and clk = '1' then
      
      if read_done = '1' then
        temp_celsius_2c <= data_sensor;
      end if;
      
    end if;
  end process;
  
  
  
  -- Conversion to fahrenheit
  -- 1.8125 multiplication: (2 - 0.25 + 0.0625)*celsius
  -- temp_fahrenheit_term1 <= (temp_celsius_bin & "0") - ("000" & temp_celsius_bin(7 downto 2)) + ("00000" & temp_celsius_bin(7 downto 4));
  temp_fahrenheit_term1 <= (temp_celsius_2c & "0") - (temp_celsius_2c(8) & temp_celsius_2c(8) & temp_celsius_2c(8) & temp_celsius_2c(8 downto 2)) +
                           (temp_celsius_2c(8) & temp_celsius_2c(8) & temp_celsius_2c(8) & temp_celsius_2c(8) & temp_celsius_2c(8) & temp_celsius_2c(8 downto 4));
  
  temp_fahrenheit_2c <= temp_fahrenheit_term1 + SUM_FAHRENHEIT;
  
  
  
  -- Conversion to kelvin  
  temp_kelvin_2c <= (temp_celsius_2c(8) & temp_celsius_2c) + SUM_KELVIN;
  
  
  
  -- Units channel selector (mux)
  temperature_2c <= temp_kelvin_2c                        when conv_units = "01" else
                    temp_fahrenheit_2c                    when conv_units = "10" else
                    temp_celsius_2c(8) & temp_celsius_2c;
                 
                
                
                 
  -- Conversion from 2's complement to BCD
  temperature_sgn <= temperature_2c(9);
  temperature_bin <= temperature_2c(8 downto 0)           when (temperature_2c(9) = '0') else
                     not(temperature_2c(8 downto 0)) + 1;
    
    
    
  
end rtl;