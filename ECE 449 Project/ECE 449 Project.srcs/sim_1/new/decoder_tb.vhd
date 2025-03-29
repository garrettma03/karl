LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY decoder_tb IS
END decoder_tb;

ARCHITECTURE testbench OF decoder_tb IS

    -- Component Declaration
    COMPONENT decoder
        PORT(
            I_instruction : IN std_logic_vector(15 DOWNTO 0);
            clk          : IN std_logic;
            rst          : IN std_logic;
            O_op         : OUT std_logic_vector(6 DOWNTO 0);
            O_ra         : INOUT std_logic_vector(2 DOWNTO 0);
            O_rb         : INOUT std_logic_vector(2 DOWNTO 0);
            O_rc         : INOUT std_logic_vector(2 DOWNTO 0);
            O_imm        : INOUT std_logic_vector(5 DOWNTO 0);
            O_z_flag     : INOUT std_logic;
            O_n_flag     : INOUT std_logic;
            O_result     : INOUT std_logic_vector(15 DOWNTO 0)
        );
    END COMPONENT;
    
    -- Signals for testing
    SIGNAL clk_tb       : std_logic := '0';
    SIGNAL rst_tb       : std_logic := '0';
    SIGNAL instruction_tb : std_logic_vector(15 DOWNTO 0) := (others => '0');
    SIGNAL op_tb        : std_logic_vector(6 DOWNTO 0) := (others => '0');
    SIGNAL ra_tb        : std_logic_vector(2 DOWNTO 0) := (others => '0');
    SIGNAL rb_tb        : std_logic_vector(2 DOWNTO 0) := (others => '0');
    SIGNAL rc_tb        : std_logic_vector(2 DOWNTO 0) := (others => '0');
    SIGNAL imm_tb       : std_logic_vector(5 DOWNTO 0) := (others => '0');
    SIGNAL z_flag_tb    : std_logic := '0';
    SIGNAL n_flag_tb    : std_logic := '0';
    SIGNAL result_tb    : std_logic_vector(15 DOWNTO 0) := (others => '0');
    
BEGIN
    -- Instantiate the decoder
    DUT: decoder PORT MAP (
        I_instruction => instruction_tb,
        clk          => clk_tb,
        rst          => rst_tb,
        O_op         => op_tb,
        O_ra         => ra_tb,
        O_rb         => rb_tb,
        O_rc         => rc_tb,
        O_imm        => imm_tb,
        O_z_flag     => z_flag_tb,
        O_n_flag     => n_flag_tb,
        O_result     => result_tb
    );

    -- Clock Process
    clk_process : PROCESS
    BEGIN
        FOR i IN 0 TO 50 LOOP
            clk_tb <= '0';
            WAIT FOR 5 ns;
            clk_tb <= '1';
            WAIT FOR 5 ns;
        END LOOP;
    END PROCESS;
    
    -- Test Process
    test_process : PROCESS
    BEGIN
        -- Reset the decoder
        rst_tb <= '1';
        WAIT FOR 10 ns;
        rst_tb <= '0';
        
        -- Apply test instructions
        instruction_tb <= x"0D21"; -- ADD r3, r2, r1
        WAIT FOR 20 ns;
        instruction_tb <= x"125A"; -- SUB r4, r3, r2
        WAIT FOR 20 ns;
--        instruction_tb <= x"16C3"; -- MUL r5, r4, r3
--        WAIT FOR 10 ns;
--        instruction_tb <= x"1AC4"; -- NAND r6, r5, r4
--        WAIT FOR 10 ns;
--        instruction_tb <= x"1582"; -- SHL r3, 2
--        WAIT FOR 10 ns;
--        instruction_tb <= x"1903"; -- SHR r2, 3
--        WAIT FOR 10 ns;
--        instruction_tb <= x"1C40"; -- TEST r1
--        WAIT FOR 10 ns;
--        instruction_tb <= x"2000"; -- OUT r2
--        WAIT FOR 10 ns;
        
        -- Stop simulation
        WAIT;
    END PROCESS;

END testbench;
