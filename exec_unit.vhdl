library ieee ;
use ieee.std_logic_1164.all ;
USE ieee.numeric_std.ALL;
--use work.array_pkg.all;

entity exec_unit is
    port(
    clk, stall, reset: in std_logic;    
    alu1_dest , ls1_dest : in std_logic_vector(15 downto 0);
    alu1_oper1, alu1_oper2, ls1_oper: in std_logic_vector(15 downto 0);
    alu1_imm6 : in std_logic_vector(5 downto 0);

    ls1_imm6 : in std_logic_vector(5 downto 0);
    ls1_imm9 : in std_logic_vector(8 downto 0);
    br1_mode: in std_logic_vector(3 downto 0);
    br1_oper1, br1_oper2, br1_pc_in, ls1_pc_in, alu1_pc_in  : in std_logic_vector(15 downto 0); --need 2 operands to check for BEQ
    br1_imm6 : in std_logic_vector(5 downto 0);
    br1_imm9 : in std_logic_vector(8 downto 0);
    alu1_mode: in std_logic_vector(5 downto 0);
    ls1_mode: in std_logic_vector(3 downto 0);
    branch_mode: in std_logic_vector(2 downto 0);
    stall_pc1, stall_pc2 : in std_logic_vector(15 downto 0);

    ls_dest,ls_value : out std_logic_vector(15 downto 0);
    br_value, br_pc, alu_pc, ls_pc : out std_logic_vector(15 downto 0);
    br_mode: out std_logic_vector(3 downto 0);
    ls_mode: out std_logic_vector(3 downto 0);
    alu_c, alu_z: out std_logic;
    br_c, br_z: out std_logic;
    ls_c, ls_z: out std_logic;
    br_eq1, br_eq2 : out std_logic;
    stall_out : out std_logic;
    --connections to prf
    alu1_reg_data: out std_logic_vector(15 downto 0);
    alu1_reg_addr: out std_logic_vector(15 downto 0);
    alu1_reg_en: out std_logic
    );

    

end entity exec_unit;

architecture execution of exec_unit is

    component ALU is
        port(alu_op: in std_logic_vector(2 downto 0);
      inp_a: in std_logic_vector(15 downto 0);
      inp_b: in std_logic_vector(15 downto 0);
      out_c: out std_logic;
      out_z: out std_logic;
      alu_out: out std_logic_vector(15 downto 0));
    end component;

    component comparator is 
    port(
		input1: in std_logic_vector(15 downto 0);
		input2: in std_logic_vector(15 downto 0);

		status: out std_logic);
    end component;

    component sign_extend7 is 
        port(
		    input: in std_logic_vector(8 downto 0);
		    output: out std_logic_vector(15 downto 0));
    end component;

    component sign_extend10 is 
        port(
		    input: in std_logic_vector(5 downto 0);
		    output: out std_logic_vector(15 downto 0));
    end component;

    component left_shift is 
    port(
		input: in std_logic_vector(15 downto 0);
		output: out std_logic_vector(15 downto 0));
    end component;

    signal alu_imm6,alu_lshift: std_logic_vector(15 downto 0);
    signal br_imm6,br_imm9: std_logic_vector(15 downto 0);
    signal ls_imm6,ls_imm9: std_logic_vector(15 downto 0);
    signal alu_sel, br_sel, ls_sel : std_logic_vector(2 downto 0);
    signal br_oper1, br_oper2 : std_logic_vector(15 downto 0);
    signal alu_oper1, alu_oper2 : std_logic_vector(15 downto 0);
    signal ls_oper1, ls_oper2 : std_logic_vector(15 downto 0);
    signal alu_value: std_logic_vector(15 downto 0);
    signal alu_mode: std_logic_vector(5 downto 0);
    signal alu_reg_data, alu_reg_addr: std_logic_vector(15 downto 0);
    signal stall_signal : std_logic := '0';
    signal br_eq : std_logic;

begin

    alu1_use : ALU port map(alu_op => alu_sel, inp_a => alu_oper1, inp_b => alu_oper2, alu_out => alu_reg_data, out_c => alu_c, out_z => alu_z);
    br1_use : ALU port map(alu_op => br_sel, inp_a => br_oper1, inp_b => br_oper2, alu_out => br_value, out_c => br_c, out_z => br_z);
    ls1_use : ALU port map(alu_op => ls_sel, inp_a => ls_oper1, inp_b => ls_oper2, alu_out => ls_value, out_c => ls_c, out_z => ls_z);

    alu_se10 : sign_extend10 port map(input => alu1_imm6, output =>alu_imm6);
    alu_lshifting : left_shift port map(input => alu1_oper2, output =>alu_lshift);

    br_comp : comparator port map(input1 => br_oper1, input2 => br_oper2, status => br_eq);
    br_se7 : sign_extend7 port map(input => br1_imm9, output =>br_imm9);
    br_se10 : sign_extend10 port map(input => br1_imm6, output =>br_imm6);

    ls_se7 : sign_extend7 port map(input => ls1_imm9, output =>ls_imm9);
    ls_se10 : sign_extend10 port map(input => ls1_imm6, output =>ls_imm6);

    alu_process : process(clk,alu1_oper1,alu1_oper2,alu1_mode,alu_imm6)
    begin
        if falling_edge(clk) and stall = '0' then
            if(alu1_mode="000100" or alu1_mode="000101" or alu1_mode="000110") then
                alu_oper1 <= alu1_oper1;
                alu_oper2 <= alu1_oper2;
                alu_sel <= "000";
                alu1_reg_en <= '1';
            elsif(alu1_mode="000111") then
                alu_oper1 <= alu1_oper1;
                alu_oper2 <= alu_lshift;
                alu_sel <= "000";
                alu1_reg_en <= '1';
            elsif(alu1_mode(5 downto 2)="0010") then
                alu_oper1 <= alu1_oper1;
                alu_oper2 <= alu1_oper2;
                alu_sel <= "010";
                alu1_reg_en <= '1';
            elsif(alu1_mode(5 downto 2)="0000") then
                alu_oper1 <= alu1_oper1;
                alu_oper2 <= alu_imm6;
                alu_sel <= "000";
                alu1_reg_en <= '1';
            else
                alu1_reg_en <= '0';
            end if;
            alu1_reg_addr <= alu_reg_addr;
            alu1_reg_data <=alu_reg_data;
        end if;
    end process;

    ls_process : process(clk,ls1_oper,ls1_mode,ls1_imm6,ls1_imm9)
    begin
        if falling_edge(clk) and stall = '0' then
            if(ls1_mode="0111" or ls1_mode="0101") then
                ls_oper1 <= ls1_oper;
                ls_oper2 <= ls_imm6;
                ls_sel <= "000";
            elsif(ls1_mode="0000") then
                alu_oper1 <= ls_imm9;
                alu_oper2 <= "0000000000000000";
                alu_sel <= "000";
            end if;
        end if;
    end process;

    br_process : process(clk,br1_oper1,br1_oper2,br1_mode,br1_imm6,br1_imm9,br1_pc_in)
    begin
        if falling_edge(clk) and stall='0' then
            if(br1_mode="1000") then
                br_oper1 <= br1_pc_in;
                br_oper2 <= br_imm6;
                br_sel <= "000";
            elsif(br1_mode="1001") then
                br_oper1 <= br1_pc_in;
                br_oper2 <= br_imm9;
                br_sel <= "000";
            elsif(br1_mode="1010") then
                br_oper1 <= br1_oper2;
                br_oper2 <= "0000000000000000";
                br_sel <= "000";
            elsif(br1_mode="1011") then
                br_oper1 <= br1_oper1;
                br_oper2 <= br_imm9;
                br_sel <= "000";
            end if;
        end if;
    end process;

    handle_stall : process(clk,stall_pc1,stall_pc2,br1_pc_in)
    begin
        if falling_edge(clk) and stall = '1' then
            if(stall_pc1=br1_pc_in) then
                stall_signal <= '1';
                br_eq1 <= br_eq;
                br_eq2 <= not (br_eq);
            elsif(stall_pc2=br1_pc_in) then
                stall_signal <= '1';
                br_eq2 <= br_eq;
                br_eq1 <= not (br_eq);
            else
                stall_signal <= '0';
                br_eq1 <= br_eq;
                br_eq2 <= br_eq;
            end if;
        end if;
    end process;


    stall_out <= stall_signal;
    alu_reg_addr <= alu1_dest;
    alu_mode <= alu1_mode;
    ls_mode <= ls1_mode;
    br_mode <= br1_mode;
    ls_dest <= ls1_dest;
    br_pc <= br1_pc_in;
    alu_pc <= alu1_pc_in;
    ls_pc <= ls1_pc_in;

end architecture;