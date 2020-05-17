-- pack_temp_conv.vhd
-- package to provide functions, procedures and data types for temperature conversion 



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


package pack_temp_conv is
  
  -- temperature units
  type t_unit is (celsius, kelvin, fahrenheit);
  
  -- converts temperature in BCD vector and sign bit to natural value  
  function temp_bcd_to_integer (bcd: std_logic_vector(11 downto 0); sgn: std_logic) return integer;
  
end package;



package body pack_temp_conv is

  function temp_bcd_to_integer (bcd: std_logic_vector(11 downto 0); sgn: std_logic) return integer is
    variable result: integer := 0;

  begin
    result :=          (100 *  conv_integer(bcd(11 downto 8)));
    result := result + (10  *  conv_integer(bcd(7 downto 4)));
    result := result +         conv_integer(bcd(3 downto 0));
    if sgn = '1' then
      result := result * (-1);
    end if;
    return result;
  end function;

end package body;
