----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/27/2025 01:54:47 PM
-- Design Name: 
-- Module Name: Top
-- Project Name: CPU Project
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    port(
        clk      : in  std_logic;
        in_port  : in  std_logic_vector(15 downto 0);
        out_port : out std_logic_vector(15 downto 0);
        rst_exec : in std_logic;
        rst_load : in std_logic
    );
end top;

architecture Structural of top is

    -- Register File component declaration
    component register_file is
        port(
            rst         : in std_logic; 
            clk         : in std_logic;
            rd_index1   : in std_logic_vector(2 downto 0); 
            rd_index2   : in std_logic_vector(2 downto 0); 
            rd_data1    : out std_logic_vector(15 downto 0); 
            rd_data2    : out std_logic_vector(15 downto 0);
            I_ra        : in std_logic_vector(2 downto 0);
            wr_index    : in std_logic_vector(2 downto 0); 
            wr_data     : in std_logic_vector(15 downto 0); 
            wr_enable   : in std_logic;
            I_is_shift  : in std_logic;
            I_is_InOut  : in std_logic
        );
    end component;
    
    -- ALU component declaration
    component ALU is
        port(
            rst       : in std_logic;
            I_in1       : in std_logic_vector(15 downto 0);
            I_in2       : in std_logic_vector(15 downto 0);
            alu_mode  : in std_logic_vector(6 downto 0);
            z_flag    : out std_logic;
            n_flag    : out std_logic;
            result    : out std_logic_vector(15 downto 0)
        );
    end component;
    
    -- Decoder component declaration
    component decoder is
        port(
            clk :   in std_logic;
            rst :   in std_logic;
            I_op_code :   in std_logic_vector(6 downto 0);
            O_alu_mode  :   out std_logic_vector(6 downto 0);
            O_wb_opr    :   out std_logic;
            O_mem_opr   :   out std_logic;
            O_is_shift  :   out std_logic;
            O_is_InOut  :   out std_logic
        );
    end component;

    -- ID_EX component declaration
    component ID_EX is
        port(
            rst :   in  std_logic;
            clk :   in  std_logic;
            I_alu_mode  :   in  std_logic_vector(6 downto 0);
            I_wb_opr    :   in  std_logic;
            I_mem_opr   :   in  std_logic;
            I_ra    :   in  std_logic_vector(2 downto 0);
            I_rd1   :   in  std_logic_vector(15 downto 0);
            I_rd2   :   in  std_logic_vector(15 downto 0);
            O_op1   :   out std_logic_vector(15 downto 0);
            O_op2   :   out std_logic_vector(15 downto 0);
            O_alu_mode  :   out std_logic_vector(6 downto 0);
            O_wb_opr    :   out std_logic;
            O_mem_opr   :   out std_logic;
            O_ra    :   out std_logic_vector(2 downto 0)
        );
    end component;

    -- EX_MEM component declaration
    component EX_MEM is
        port(
            rst             :   in  std_logic;
            clk             :   in  std_logic;
            I_mem_opr       :   in std_logic;
            I_wb_opr        :   in std_logic;
            I_ra            :   in std_logic_vector(2 downto 0);
            I_ALU_result    :   in std_logic_vector(15 downto 0);
            O_mem_addr      :   out std_logic_vector(15 downto 0);
            O_mem_opr       :   out std_logic;
            O_wb_opr        :   out std_logic;
            O_ra            :   out std_logic_vector(2 downto 0);
            O_mem_data      :   out std_logic_vector(15 downto 0)
        );
    end component;

    -- IF_ID component declaration
    component IF_ID is
        port (
            clk       : in std_logic;
            rst       : in std_logic;
            I_instr_in  : in std_logic_vector(15 downto 0);
            O_opcode    : out std_logic_vector(6 downto 0);
            O_ra    :   out std_logic_vector(2 downto 0);
            O_rb    :   out std_logic_vector(2 downto 0);
            O_rc    :   out std_logic_vector(2 downto 0)
        );
    end component;

    -- MEM_WB component declaration
    component MEM_WB is
        port(
            rst :   in  std_logic;
            clk :   in  std_logic;
            I_wb_opr   :   in std_logic;
            O_wb_opr   :   out std_logic
        );
    end component;

    -- PC component declaration
    component PC is
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
    end component;

    component ROM is
        port(
            clk    :   in std_logic;
            pc_addr   :   in std_logic_vector(15 downto 0);
            rst    :   in std_logic;
            sleep :   in std_logic;
            injectsbiterra    :   in std_logic;
            injectdbiterra    :   in std_logic;
            instruction_out   :   out std_logic_vector(15 downto 0);
            sbiterra  :   out std_logic;
            dbiterra  :   out std_logic;
            pc_enable : out std_logic
        );
    end component;
    
    
    -- Internal signals
    -- PC signals
    signal pc_out         : std_logic_vector(15 downto 0);
    signal pc_enable      : std_logic;
    signal branch_en      : std_logic := '0';
    signal branch_addr    : std_logic_vector(15 downto 0) := (others => '0');
    signal return_en      : std_logic := '0';
    signal return_addr    : std_logic_vector(15 downto 0) := (others => '0');
    
    -- ROM signals
    signal instruction    : std_logic_vector(15 downto 0);
    signal rom_sleep      : std_logic := '0';
    signal injectsbiterra : std_logic := '0';
    signal injectdbiterra : std_logic := '0';
    signal sbiterra       : std_logic;
    signal dbiterra       : std_logic;
    
    -- IF/ID signals
    signal if_id_opcode   : std_logic_vector(6 downto 0);
    signal if_id_ra       : std_logic_vector(2 downto 0);
    signal if_id_rb       : std_logic_vector(2 downto 0);
    signal if_id_rc       : std_logic_vector(2 downto 0);
    
    -- Controller signals
    signal alu_mode       : std_logic_vector(6 downto 0);
    signal wb_opr         : std_logic;
    signal mem_opr        : std_logic;
    signal is_shift       : std_logic;
    signal is_inout       : std_logic;
    
    -- Register file signals
    signal rd_data1       : std_logic_vector(15 downto 0);
    signal rd_data2       : std_logic_vector(15 downto 0);
    
    -- ID/EX signals
    signal idex_op1       : std_logic_vector(15 downto 0);
    signal idex_op2       : std_logic_vector(15 downto 0);
    signal idex_alu_mode  : std_logic_vector(6 downto 0);
    signal idex_wb_opr    : std_logic;
    signal idex_mem_opr   : std_logic;
    signal idex_ra        : std_logic_vector(2 downto 0);
    
    -- ALU signals
    signal alu_result     : std_logic_vector(15 downto 0);
    signal alu_z_flag     : std_logic;
    signal alu_n_flag     : std_logic;
    
    -- EX/MEM signals
    signal exmem_mem_addr : std_logic_vector(15 downto 0);
    signal exmem_mem_opr  : std_logic;
    signal exmem_wb_opr   : std_logic;
    signal exmem_ra       : std_logic_vector(2 downto 0);
    signal exmem_mem_data : std_logic_vector(15 downto 0);
    
    -- MEM/WB signals
    signal memwb_wb_opr   : std_logic;
    
begin
    -- PC instantiation
    PC_inst: PC port map(
        clk         => clk,
        rst_exec    => rst_exec,
        rst_load    => rst_load,
        branch_en   => branch_en,
        branch_addr => branch_addr,
        return_en   => return_en,
        return_addr => return_addr,
        pc_out      => pc_out,
        pc_enable   => pc_enable
    );
    
    -- ROM instantiation
    ROM_inst: ROM port map(
        clk              => clk,
        pc_addr          => pc_out,
        rst              => rst_exec,
        sleep            => rom_sleep,
        injectsbiterra   => injectsbiterra,
        injectdbiterra   => injectdbiterra,
        instruction_out  => instruction,
        sbiterra         => sbiterra,
        dbiterra         => dbiterra,
        pc_enable        => pc_enable
    );
    
    -- IF/ID instantiation
    IF_ID_inst: IF_ID port map(
        clk         => clk,
        rst         => rst_exec,
        I_instr_in  => instruction,
        O_opcode    => if_id_opcode,
        O_ra        => if_id_ra,
        O_rb        => if_id_rb,
        O_rc        => if_id_rc
    );
    
    -- Decoder (Controller) instantiation
    Decoder_inst: decoder port map(
        clk        => clk,
        rst        => rst_exec,
        I_op_code  => if_id_opcode,
        O_alu_mode => alu_mode,
        O_wb_opr   => wb_opr,
        O_mem_opr  => mem_opr,
        O_is_shift => is_shift,
        O_is_InOut => is_inout
    );
    
    -- Register File instantiation
    RF_inst: register_file port map(
        rst         => rst_exec,
        clk         => clk,
        rd_index1   => if_id_rb,
        rd_index2   => if_id_rc,
        rd_data1    => rd_data1,
        rd_data2    => rd_data2,
        I_ra        => if_id_ra,
        wr_index    => exmem_ra,
        wr_data     => exmem_mem_data,
        wr_enable   => memwb_wb_opr,
        I_is_shift  => is_shift,
        I_is_InOut  => is_inout
    );
    
    -- ID/EX instantiation
    ID_EX_inst: ID_EX port map(
        rst        => rst_exec,
        clk        => clk,
        I_alu_mode => alu_mode,
        I_wb_opr   => wb_opr,
        I_mem_opr  => mem_opr,
        I_ra       => if_id_ra,
        I_rd1      => rd_data1,
        I_rd2      => rd_data2,
        O_op1      => idex_op1,
        O_op2      => idex_op2,
        O_alu_mode => idex_alu_mode,
        O_wb_opr   => idex_wb_opr,
        O_mem_opr  => idex_mem_opr,
        O_ra       => idex_ra
    );
    
    -- ALU instantiation
    ALU_inst: ALU port map(
        rst       => rst_exec,
        I_in1     => idex_op1,
        I_in2     => idex_op2,
        alu_mode  => idex_alu_mode,
        z_flag    => alu_z_flag,
        n_flag    => alu_n_flag,
        result    => alu_result
    );
    
    -- EX/MEM instantiation
    EX_MEM_inst: EX_MEM port map(
        rst           => rst_exec,
        clk           => clk,
        I_mem_opr     => idex_mem_opr,
        I_wb_opr      => idex_wb_opr,
        I_ra          => idex_ra,
        I_ALU_result  => alu_result,
        O_mem_addr    => exmem_mem_addr,
        O_mem_opr     => exmem_mem_opr,
        O_wb_opr      => exmem_wb_opr,
        O_ra          => exmem_ra,
        O_mem_data    => exmem_mem_data
    );
    
    -- -- Memory instantiation
    -- Memory_inst: memory port map(
    --     clk           => clk,
    --     addr          => exmem_mem_addr,
    --     mem_opr       => exmem_mem_opr,
    --     mem_data_in   => exmem_mem_data,
    --     mem_data_out  => mem_data_out
    -- );
    
    -- MEM/WB instantiation
    MEM_WB_inst: MEM_WB port map(
        rst      => rst_exec,
        clk      => clk,
        I_wb_opr => exmem_wb_opr,
        O_wb_opr => memwb_wb_opr
    );
    
    out_port <= exmem_mem_data when is_inout = '1' else (others => '0');
    
end Structural;
