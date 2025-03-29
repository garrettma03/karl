library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_top_tb is
end cpu_top_tb;

architecture Behavioral of cpu_top_tb is

    -- DUT component
    component cpu_top
        port (
            clk         : in  std_logic;
            rst_exec    : in  std_logic;
            rst_load    : in  std_logic;
            in_port     : in  std_logic_vector(15 downto 0);
            out_port    : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals
    signal clk_tb       : std_logic := '0';
    signal rst_exec_tb  : std_logic := '0';
    signal rst_load_tb  : std_logic := '0';
    signal in_port_tb   : std_logic_vector(15 downto 0) := (others => '0');
    signal out_port_tb  : std_logic_vector(15 downto 0);

    -- Clock period (in ns)
    constant clk_period : time := 10 ns;

begin

    -- Instantiate DUT
    uut: cpu_top
        port map (
            clk         => clk_tb,
            rst_exec    => rst_exec_tb,
            rst_load    => rst_load_tb,
            in_port     => in_port_tb,
            out_port    => out_port_tb
        );

    -- Clock generator
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Test procedure
    stim_proc: process
    begin
--        -- Initial state
--        rst_exec_tb <= '0';
--        rst_load_tb <= '0';
--        wait for 20 ns;

--        -- Trigger reset & execute
--        rst_exec_tb <= '1';
--        wait for clk_period;
--        rst_exec_tb <= '0';
        wait for 30 ns;
        rst_exec_tb <= '1';
        wait for clk_period;
        rst_exec_tb <= '0';
        -- Wait and let CPU iterate
        wait for 500 ns;

        -- Done
        wait;
    end process;

end Behavioral;
