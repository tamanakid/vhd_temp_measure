-- temp_binary_to_bcd.vhd
-- Converts binary temperature to BCD value


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity temp_binary_to_bcd is
  port(
    -- input: binary temperature
    temperature_bin : in std_logic_vector(8 downto 0);
    
    -- output: BCD temperature
    temperature_bcd : buffer std_logic_vector(11 downto 0)
  );
end entity;



architecture rtl of temp_binary_to_bcd is
  
  signal temp_dec : std_logic_vector(8 downto 0);
  signal temp_uds : std_logic_vector(8 downto 0);
  
  
begin
  
  temperature_bcd(11 downto 8) <= "0100" when temperature_bin > 399 else
                                  "0011" when temperature_bin > 299 else
                                  "0010" when temperature_bin > 199 else
                                  "0001" when temperature_bin > 99 else
                                  "0000";

  temp_dec <= temperature_bin - 400 when temperature_bin > 399 else
              temperature_bin - 300 when temperature_bin > 299 else
              temperature_bin - 200 when temperature_bin > 199 else
              temperature_bin - 100 when temperature_bin > 99 else
              temperature_bin;

  
  temperature_bcd(7 downto 4) <=  "1001" when temp_dec > 89 else
                                  "1000" when temp_dec > 79 else
                                  "0111" when temp_dec > 69 else
                                  "0110" when temp_dec > 59 else
                                  "0101" when temp_dec > 49 else
                                  "0100" when temp_dec > 39 else
                                  "0011" when temp_dec > 29 else
                                  "0010" when temp_dec > 19 else
                                  "0001" when temp_dec > 9 else
                                  "0000";


  temp_uds <= temp_dec - 90 when temp_dec > 89 else
              temp_dec - 80 when temp_dec > 79 else
              temp_dec - 70 when temp_dec > 69 else
              temp_dec - 60 when temp_dec > 59 else
              temp_dec - 50 when temp_dec > 49 else
              temp_dec - 40 when temp_dec > 39 else
              temp_dec - 30 when temp_dec > 29 else
              temp_dec - 20 when temp_dec > 19 else
              temp_dec - 10 when temp_dec > 9 else
              temp_dec;

  
  temperature_bcd(3 downto 0) <= temp_uds(3 downto 0);
  
end rtl;