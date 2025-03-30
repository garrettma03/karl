----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.03.2025 12:23:54
-- Design Name: 
-- Module Name: branch_unit - Behavioral
-- Project Name: 
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_unit is
    port(
        -- Inputs
        clk         : in  std_logic;
        reset       : in  std_logic;
        opcode      : in  std_logic_vector(6 downto 0);
        pc_current  : in  std_logic_vector(15 downto 0);        -- Current PC value
        disp_l      : in  std_logic_vector(8 downto 0);         -- For B1 instructions 
        disp_s      : in  std_logic_vector(5 downto 0);         -- For B2 instructions 
        ra_data     : in  std_logic_vector(15 downto 0);        -- The contents of ra used for B2 instructions (absolute branches).
        r7_data     : in  std_logic_vector(15 downto 0);        -- The contents of r7 used for RETURN (opcode=71).
        nflag       : in  std_logic;
        zflag       : in  std_logic;                            -- ALU flags. nflag=1 if negative, zflag=1 if zero.
        pc_plus_2   : in  std_logic_vector(15 downto 0);        -- PC+2 (default next PC) use when a branch is not taken or for BR.SUB link.

        -- Outputs
        new_pc      : out std_logic_vector(15 downto 0);
        link_reg    : out std_logic_vector(15 downto 0)        -- For BR.SUB only link_reg = PC+2 to be written into R7 

    );
end branch_unit;

architecture Behavioral of branch_unit is

    -- Internal signals for sign extension and shifting.
    signal disp_l_ext      : signed(8 downto 0);
    signal disp_s_ext      : signed(5 downto 0);
    signal disp_l_shifted  : signed(15 downto 0);
    signal disp_s_shifted  : signed(15 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                new_pc   <= (others => '0');
                link_reg <= (others => '0');
            else

                -- Sign-extend the displacements to their full widths.
                disp_l_ext <= signed(disp_l);
                disp_s_ext <= signed(disp_s);

                -- Shift left by 1 (multiply by 2) for word alignment.
                disp_l_shifted <= shift_left(resize(disp_l_ext, 16), 1);
                disp_s_shifted <= shift_left(resize(disp_s_ext, 16), 1);

                case opcode is

                    -- 64 (1000000): BRR => PC <- PC + 2 * disp.l
                    when "1000000" =>
                        new_pc   <= std_logic_vector(signed(pc_current) + disp_l_shifted);
                        link_reg <= (others => '0');

                    -- 65 (1000001): BRR.N => if N=1 => PC <- PC + 2*disp.l else PC <- PC+2
                    when "1000001" =>
                        if nflag = '1' then
                            new_pc <= std_logic_vector(signed(pc_current) + disp_l_shifted);
                        else
                            new_pc <= pc_plus_2;
                        end if;
                        link_reg <= (others => '0');

                    -- 66 (1000010): BRR.Z => if Z=1 => PC <- PC + 2*disp.l else PC <- PC+2
                    when "1000010" =>
                        if zflag = '1' then
                            new_pc <= std_logic_vector(signed(pc_current) + disp_l_shifted);
                        else
                            new_pc <= pc_plus_2;
                        end if;
                        link_reg <= (others => '0');

                    -- 67 (1000011): BR => PC <- R[ra] + 2*disp.s
                    when "1000011" =>
                        new_pc   <= std_logic_vector(signed(ra_data) + disp_s_shifted);
                        link_reg <= (others => '0');

                    -- 68 (1000100): BR.N => if N=1 => PC<-R[ra]+2*disp.s else PC<-PC+2
                    when "1000100" =>
                        if nflag = '1' then
                            new_pc <= std_logic_vector(signed(ra_data) + disp_s_shifted);
                        else
                            new_pc <= pc_plus_2;
                        end if;
                        link_reg <= (others => '0');

                    -- 69 (1000101): BR.Z => if Z=1 => PC<-R[ra]+2*disp.s else PC<-PC+2
                    when "1000101" =>
                        if zflag = '1' then
                            new_pc <= std_logic_vector(signed(ra_data) + disp_s_shifted);
                        else
                            new_pc <= pc_plus_2;
                        end if;
                        link_reg <= (others => '0');

                    -- 70 (1000110): BR.SUB => r7 <- PC+2; PC <- R[ra]+2*disp.s
                    when "1000110" =>
                        link_reg <= pc_plus_2;  -- This will be written to R7 in your pipeline.
                        new_pc   <= std_logic_vector(signed(ra_data) + disp_s_shifted);

                    -- 71 (1000111): RETURN => PC <- r7
                    when "1000111" =>
                        new_pc   <= r7_data;
                        link_reg <= (others => '0');

                    -- Default case: not a B-format branch => do nothing special.
                    when others =>
                        new_pc   <= pc_plus_2;
                        link_reg <= (others => '0');

                end case;
            end if;
        end if;
    end process;

end Behavioral;
