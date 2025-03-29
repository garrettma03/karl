library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEM_WB is
    port(
        rst :   in  std_logic;
        clk :   in  std_logic;
        I_wb_opr   :   in std_logic;
        O_wb_opr   :   out std_logic
    );
end MEM_WB;

architecture Behavioral of MEM_WB is

begin

    process (clk, rst)
    begin
        if rst = '1' then
            O_wb_opr <= '0';
        elsif rising_edge(clk) then
            O_wb_opr <= I_wb_opr;
        end if;

    end process;

end Behavioral;