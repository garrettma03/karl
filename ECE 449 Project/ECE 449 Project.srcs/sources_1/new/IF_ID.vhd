library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID is
    port (
        clk       : in std_logic;  -- Clock signal
        rst       : in std_logic;  -- Reset signal
        I_instr_in  : in std_logic_vector(15 downto 0); -- Full instruction from Memory
        O_opcode    : out std_logic_vector(6 downto 0); -- Opcode (to Control Unit)
        O_ra    :   out std_logic_vector(2 downto 0);
        O_rb    :   out std_logic_vector(2 downto 0);
        O_rc    :   out std_logic_vector(2 downto 0)
    );
end IF_ID;

architecture Behavioral of IF_ID is

begin
    -- Instruction decode process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                O_opcode <= (others => '0');
                O_ra <= (others => '0');
                O_rb <= (others => '0');
                O_rc <= (others => '0');
            else
                -- Store instruction and extract fields
                O_opcode <= I_instr_in(15 downto 9);
                O_ra <= I_instr_in(8 downto 6);
                O_rb <= I_instr_in(5 downto 3);
                O_rc <= I_instr_in(2 downto 0);
            end if;
        end if;
    end process;
    
end Behavioral;