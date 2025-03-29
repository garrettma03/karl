library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_TB is
end ALU_TB;

architecture Behavioral of ALU_TB is

    -- Component declaration for the ALU
    component ALU is
    port(
        rst       : in std_logic;
        clk       : in std_logic;
        in1       : in std_logic_vector(15 downto 0);
        in2       : in std_logic_vector(15 downto 0);
        alu_mode  : in std_logic_vector(2 downto 0);
        z_flag    : out std_logic;
        n_flag    : out std_logic;
        result    : out std_logic_vector(15 downto 0)
    );
    end component;

    -- Signals for the testbench
    signal rst       : std_logic := '0';
    signal clk       : std_logic := '0';
    signal in1       : std_logic_vector(15 downto 0) := (others => '0');
    signal in2       : std_logic_vector(15 downto 0) := (others => '0');
    signal alu_mode  : std_logic_vector(2 downto 0) := (others => '0');
    signal z_flag    : std_logic;
    signal n_flag    : std_logic;
    signal result    : std_logic_vector(15 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the ALU
    uut: ALU port map (
        rst => rst,
        clk => clk,
        in1 => in1,
        in2 => in2,
        alu_mode => alu_mode,
        z_flag => z_flag,
        n_flag => n_flag,
        result => result
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';

        -- Test each alu_mode
        for i in 0 to 7 loop
            alu_mode <= std_logic_vector(to_unsigned(i, 3));
            in1 <= X"0003"; -- Example input 1
            in2 <= X"0002"; -- Example input 2
            wait for clk_period * 2;

        end loop;

        -- End of test
        wait;
    end process;

end Behavioral;