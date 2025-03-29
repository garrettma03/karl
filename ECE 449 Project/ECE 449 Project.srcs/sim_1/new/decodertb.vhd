library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_ID_tb is
end IF_ID_tb;

architecture Behavioral of IF_ID_tb is

    -- Component declarations
    component IF_ID is
        port (
            clk       : in  std_logic;                     -- Clock signal
            rst       : in  std_logic;                     -- Reset signal
            I_instr_in: in  std_logic_vector(15 downto 0); -- Full instruction from Memory
            O_opcode  : out std_logic_vector(6 downto 0);  -- Opcode (to Control Unit)
            O_ra      : out std_logic_vector(2 downto 0);
            O_rb      : out std_logic_vector(2 downto 0);
            O_rc      : out std_logic_vector(2 downto 0)
        );
    end component;

    component register_file is
        port (
            rst         : in  std_logic;
            clk         : in  std_logic;
            rom_addr    : out std_logic_vector(2 downto 0);  -- Add this line
            rd_index1   : in  std_logic_vector(2 downto 0);
            rd_index2   : in  std_logic_vector(2 downto 0);
            rd_data1    : out std_logic_vector(15 downto 0);
            rd_data2    : out std_logic_vector(15 downto 0);
            I_ra        : in std_logic_vector(2 downto 0);
            wr_index    : in  std_logic_vector(2 downto 0);
            wr_data     : in  std_logic_vector(15 downto 0);
            wr_enable   : in  std_logic;
            I_is_shift  : in  std_logic
        );
    end component;

    component decoder is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            I_op_code: in  std_logic_vector(6 downto 0);
            O_alu_mode : out std_logic_vector(6 downto 0);
            O_wb_opr   : out std_logic;
            O_mem_opr  : out std_logic;
            O_is_shift : out std_logic
        );
    end component;

    component ID_EX is
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            I_alu_mode: in  std_logic_vector(6 downto 0);
            I_wb_opr  : in  std_logic;
            I_mem_opr : in  std_logic;
            I_ra      : in  std_logic_vector(2 downto 0);
            I_rd1     : in  std_logic_vector(15 downto 0);
            I_rd2     : in  std_logic_vector(15 downto 0);
            O_op1     : out std_logic_vector(15 downto 0);
            O_op2     : out std_logic_vector(15 downto 0);
            O_alu_mode: out std_logic_vector(6 downto 0);
            O_wb_opr  : out std_logic;
            O_mem_opr : out std_logic;
            O_ra      : out std_logic_vector(2 downto 0)
        );
    end component;

    component ALU is
        port (
            rst      : in  std_logic;
            I_in1    : in  std_logic_vector(15 downto 0);
            I_in2    : in  std_logic_vector(15 downto 0);
            alu_mode : in  std_logic_vector(6 downto 0);
            z_flag   : out std_logic;
            n_flag   : out std_logic;
            result   : out std_logic_vector(15 downto 0)
        );
    end component;

    component EX_MEM is
        port (
            rst         : in  std_logic;
            clk         : in  std_logic;
            I_mem_opr   : in  std_logic;
            I_wb_opr    : in  std_logic;
            I_ra        : in  std_logic_vector(2 downto 0);
            I_ALU_result: in  std_logic_vector(15 downto 0);
            I_mem_addr  : in  std_logic_vector(2 downto 0);
            O_mem_addr  : out std_logic_vector(2 downto 0);
            O_mem_opr   : out std_logic;
            O_wb_opr    : out std_logic;
            O_ra        : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Test signals
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal I_instr_in   : std_logic_vector(15 downto 0) := (others => '0');

    -- IF_ID signals
    signal O_opcode     : std_logic_vector(6 downto 0);
    signal O_ra         : std_logic_vector(2 downto 0);
    signal O_rb         : std_logic_vector(2 downto 0);
    signal O_rc         : std_logic_vector(2 downto 0);

    -- Register file signals
    signal reg_rd_data1 : std_logic_vector(15 downto 0);
    signal reg_rd_data2 : std_logic_vector(15 downto 0);
    signal wr_index     : std_logic_vector(2 downto 0) := "000";
    signal wr_data      : std_logic_vector(15 downto 0) := (others => '0');
    signal wr_enable    : std_logic := '0';
    signal shift_amount : std_logic_vector(3 downto 0) := "0000";

    -- Decoder signals
    signal d_alu_mode   : std_logic_vector(6 downto 0);
    signal wb_opr       : std_logic;
    signal mem_opr      : std_logic;
    signal is_shift     : std_logic;

    -- ID_EX signals
    signal idex_op1     : std_logic_vector(15 downto 0);
    signal idex_op2     : std_logic_vector(15 downto 0);
    signal idex_alu_mode: std_logic_vector(6 downto 0);
    signal idex_wb_opr  : std_logic;
    signal idex_mem_opr : std_logic;
    signal idex_ra      : std_logic_vector(2 downto 0);

    -- ALU signals
    signal alu_z_flag   : std_logic;
    signal alu_n_flag   : std_logic;
    signal alu_result   : std_logic_vector(15 downto 0);

    -- EX/MEM signals
    signal exmem_mem_addr : std_logic_vector(2 downto 0);
    signal exmem_mem_opr  : std_logic;
    signal exmem_wb_opr   : std_logic;
    signal exmem_ra       : std_logic_vector(2 downto 0);

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT) and pipeline components
    uut_if_id: IF_ID port map (
        clk       => clk,
        rst       => rst,
        I_instr_in=> I_instr_in,
        O_opcode  => O_opcode,
        O_ra      => O_ra,
        O_rb      => O_rb,
        O_rc      => O_rc
    );

    uut_reg_file: register_file port map (
        rst       => rst,
        clk       => clk,
        rom_addr  => open,
        rd_index1 => O_rb,
        rd_index2 => O_rc,
        rd_data1  => reg_rd_data1,
        rd_data2  => reg_rd_data2,
        I_ra => O_ra,
        wr_index  => wr_index,
        wr_data   => wr_data,
        wr_enable => wr_enable,
        I_is_shift=> is_shift
    );

    uut_decoder: decoder port map (
        clk      => clk,
        rst      => rst,
        I_op_code=> O_opcode,
        O_alu_mode => d_alu_mode,
        O_wb_opr  => wb_opr,
        O_mem_opr => mem_opr,
        O_is_shift => is_shift
    );

    uut_id_ex: ID_EX port map (
        clk       => clk,
        rst       => rst,
        I_alu_mode=> d_alu_mode,
        I_wb_opr  => wb_opr,
        I_mem_opr => mem_opr,
        I_ra      => O_ra,
        I_rd1     => reg_rd_data1,
        I_rd2     => reg_rd_data2,
        O_op1     => idex_op1,
        O_op2     => idex_op2,
        O_alu_mode=> idex_alu_mode,
        O_wb_opr  => idex_wb_opr,
        O_mem_opr => idex_mem_opr,
        O_ra      => idex_ra
    );

    ALU_inst: ALU port map (
        rst      => rst,
        I_in1    => idex_op1,
        I_in2    => idex_op2,
        alu_mode => idex_alu_mode,
        z_flag   => alu_z_flag,
        n_flag   => alu_n_flag,
        result   => alu_result
    );

    uut_ex_mem: EX_MEM port map (
        clk         => clk,
        rst         => rst,
        I_mem_opr   => idex_mem_opr,
        I_wb_opr    => idex_wb_opr,
        I_ra        => idex_ra,
        I_ALU_result=> alu_result,
        I_mem_addr  => idex_ra,  -- Assuming mem_addr comes from ra (adjust if needed)
        O_mem_addr  => exmem_mem_addr,
        O_mem_opr   => exmem_mem_opr,
        O_wb_opr    => exmem_wb_opr,
        O_ra        => exmem_ra
    );

    -- Clock process
    clk_process: process
    begin
        wait for CLK_PERIOD/2;
        clk <= not clk;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 2 clock cycles
        wait for CLK_PERIOD * 2;
        rst <= '0';

        -- Test Case 1: NOP (Format A0, opcode = 0)
        I_instr_in <= "0000000000000000"; -- NOP
        wait for CLK_PERIOD*3;

        -- Test Case 2: ADD r3, r2, r1 (Format A1, opcode = 1) *Should get 12 or 0xC*
        I_instr_in <= "0000001000001010"; -- ADD r0 <- r1 + r2
        wait for CLK_PERIOD*3;

        -- Test Case 3: SUB r3, r2, r1 (Format A1, opcode = 2) *Should get 8 or 0x8*
        I_instr_in <= "0000010000001010"; -- SUB r0 <- r1 - r2
        wait for CLK_PERIOD*3;

        -- Test Case 4: MUL r3, r2, r1 (Format A1, opcode = 3) *Should get 20 or 0x14*
        I_instr_in <= "0000011000001010"; -- MUL r0 <- r5 * r7
        wait for CLK_PERIOD*3;

        -- Test Case 5: NAND r3, r2, r1 (Format A1, opcode = 4) *Should get 1111 or 0xff*
        I_instr_in <= "0000100000001010"; -- NAND r0 <- `(r1 AND r2)
        wait for CLK_PERIOD*3;

        -- Test Case 6: SHL r1, #1 (Format A2, opcode = 5) *Should get 24 or 0x24*
        I_instr_in <= "0000101001000001"; -- SHL r1, #4
        wait for CLK_PERIOD*3;

        -- Test Case 7: SHR r1, #2 (Format A2, opcode = 6) *Should get 3 or 0x03*
        I_instr_in <= "0000110001000010"; -- SHR r1, #2
        wait for CLK_PERIOD*3;

        -- Test Case 8: TEST r3 (Format A3, opcode = 7) *Truthfully idk what this should be*
        I_instr_in <= "0000111000100000"; -- TEST r0
        wait for CLK_PERIOD*3;

        -- End simulation
        wait;
    end process;

end Behavioral;