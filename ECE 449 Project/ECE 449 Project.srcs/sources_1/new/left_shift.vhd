library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- Needed for shifts
entity left_shift is
end left_shift;
 
architecture behave of left_shift is
  signal a : std_logic_vector(15 downto 0);
  signal b : (15 downto 0);
  signal c : (15 downto 0);
   
begin
 
  process is
  begin
    -- Left Shift
    c <= shift_left(unsigned(a), b);
 
    wait for 100 ns;
  end process;
end architecture behave;