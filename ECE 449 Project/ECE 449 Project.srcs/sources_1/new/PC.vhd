library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port (
        clk         : in std_logic;  -- Clock signal
        rst_exec    : in std_logic;  -- Reset and Execute (Start execution from 0x0000)
        rst_load    : in std_logic;  -- Reset and Load (Start loading from 0x0002)
        branch_en   : in std_logic;  -- Branch enable (1 = update PC)
        branch_addr : in std_logic_vector(15 downto 0); -- New PC value for branching
        return_en   : in std_logic;  -- Enable return (RETURN instruction)
        return_addr : in std_logic_vector(15 downto 0); -- Address from R7 for return
        pc_out      : out std_logic_vector(15 downto 0);  -- Output: Current PC value
        pc_enable   : in std_logic
    );
end PC;

architecture Behavioral of PC is
    signal pc_reg : std_logic_vector(15 downto 0) := (others => '0'); -- PC Register

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_exec = '1' then
                pc_reg <= x"0000"; -- Reset and Execute (Start at address 0x0000)
            elsif rst_load = '1' then
                pc_reg <= x"0002"; -- Reset and Load (Start at address 0x0002 for BIOS loading)
            elsif return_en = '1' then
                pc_reg <= return_addr; -- Returning from subroutine (restore PC from R7)
            elsif branch_en = '1' then
                pc_reg <= branch_addr; -- Branching (either B1 or B2 format)
            elsif pc_enable = '1' then
                pc_reg <= std_logic_vector(unsigned(pc_reg) + 2); -- Normal execution (PC increments)
            end if;
        end if;
    end process;

    pc_out <= pc_reg; -- Output the current PC value

end Behavioral;
