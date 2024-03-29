-- 3 ex
-- 1 alu + 1 l/s + branching

library ieee ;
use ieee.std_logic_1164.all ;
USE ieee.numeric_std.ALL;
use work.array_pkg.all;
entity rs_stage is
    generic(
        rs_size: integer := 16
        -- there are 8 architectural registers
    ); 
    port(
        clk, reset: in std_logic;  --system ip
        pc_in_1, pc_in_2:  in std_logic_vector(15 downto 0); --id stage
        opcode_1, opcode_2: in std_logic_vector(3 downto 0);  --id stage
        alu_op_1, alu_op_2: in std_logic_vector(1 downto 0);  -- id stage
        imm6_1, imm6_2: in std_logic_vector(5 downto 0);  -- id stage
        imm9_1, imm9_2 : in std_logic_vector(8 downto 0);  -- id stage
        r_1, r_2, r_3, r_4, r_5, r_6: in std_logic_vector(15 downto 0);  --rr stage
        v_2, v_3, v_5, v_6 : in std_logic;  --from rr
        prf_data_bus: in prf_data_array(0 to rs_size*2-1);-- (busy) (16 BIT DATA)  --from prf
        prf_addr_bus: out addr_array(0 to rs_size*2-1);  --from prf
        alu1_dest , ls1_dest : out std_logic_vector(15 downto 0);  
        alu1_oper1, alu1_oper2, ls1_oper: out std_logic_vector(15 downto 0);  
        alu1_imm6 : out std_logic_vector(5 downto 0);
        alu1_pc : out std_logic_vector(15 downto 0);
        ls1_imm6 : out std_logic_vector(5 downto 0);
        ls1_imm9 : out std_logic_vector(8 downto 0);
        ls1_pc : out std_logic_vector(15 downto 0);
        br1_mode: out std_logic_vector(3 downto 0);
        br1_oper1, br1_oper2 : out std_logic_vector(15 downto 0);
        br1_imm6 : out std_logic_vector(5 downto 0);
        br1_imm9 : out std_logic_vector(8 downto 0);
        br1_pc : out std_logic_vector(15 downto 0);
        alu1_mode: out std_logic_vector(5 downto 0);
        ls1_mode: out std_logic_vector(3 downto 0);
        branch_mode: out std_logic_vector(2 downto 0)
    );
end entity rs_stage;

architecture bham of rs_stage is
    type opcode_vector is array(0 to rs_size-1) of std_logic_vector(3 downto 0);
    type alu_op_vector is array(0 to rs_size-1) of std_logic_vector(1 downto 0);
    type opr_vector is array(0 to rs_size-1) of std_logic_vector(15 downto 0);
    type imm6_vector is array(0 to rs_size-1) of std_logic_vector(5 downto 0);
    type imm9_vector is array(0 to rs_size-1) of std_logic_vector(8 downto 0);
    type count_vector is array(0 to rs_size-1) of integer;
    signal opcode: opcode_vector := (others=>(others=>'0')); 
    signal alu_op: alu_op_vector := (others=>(others=>'0'));
    signal opr_1: opr_vector := (others=>(others=>'0')); 
    signal opr_2: opr_vector := (others=>(others=>'0')); 
    signal dest: opr_vector := (others=>(others=>'0')); 
    -- val : validity of rs entry
    signal val: std_logic_vector(0 to rs_size-1)  := (others=>'0');

    signal val_1: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    signal val_2: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    signal imm6: imm6_vector := (others=>(others=>'0')); 
    signal imm9: imm9_vector  := (others=>(others=>'0')); 
    -- ready : inst ready to be issued
    signal ready: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    signal count: count_vector := (others=>0);
begin
    

    process(clk)
    variable temp_opcode: opcode_vector := (others=>(others=>'0'));
    variable temp_alu_op: alu_op_vector := (others=>(others=>'0')); 
    variable temp_pc: opr_vector := (others=>(others=>'0'));
    
    variable temp_opr_1: opr_vector := (others=>(others=>'0')); 
    variable temp_opr_2: opr_vector := (others=>(others=>'0')); 
    variable temp_dest: opr_vector := (others=>(others=>'0')); 
    -- val : validity of rs entry
    variable temp_val: std_logic_vector(0 to rs_size-1)  := (others=>'0');

    variable temp_val_1: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    variable temp_val_2: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    variable temp_imm6: imm6_vector := (others=>(others=>'0')); 
    variable temp_imm9: imm9_vector  := (others=>(others=>'0'));
    -- ready : inst ready to be issued
    variable temp_ready: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    variable temp_count: count_vector := (others=>0);
    variable age_alu1, age_ls1, age_branch: integer := 0;
    begin  
        temp_opcode := opcode;
        temp_alu_op := alu_op;
        temp_opr_1 := opr_1;
        temp_opr_2 := opr_2;
        temp_dest := dest;
        temp_val := val;
        temp_val_1 := val_1;
        temp_val_2 := val_2;
        temp_imm6 := imm6;
        temp_imm9 := imm9;
        temp_ready := ready;
        temp_count := count;
        
        --temp_

        age_alu1 := 0;
        age_ls1 := 0;
        age_ls1 := 0;
    
        age_branch := 0;
        alu1_mode <= (others=>'1');
        br1_mode <= (others=>'1');
        if falling_edge(clk) then
            for i in 0 to rs_size-1 loop
                -- alu
                if(temp_ready(i) = '1' and ((temp_opcode(i) = "0001") or (temp_opcode(i) = "0010"))) then
                    if temp_count(i) > age_alu1 then
                        age_alu1 := temp_count(i);
                        alu1_dest <= temp_dest(i);
                        alu1_oper1 <= temp_opr_1(i);
                        alu1_oper2 <= temp_opr_2(i);
                        alu1_imm6 <= temp_imm6(i);
                        alu1_mode(5 downto 2) <= temp_opcode(i);
                        alu1_mode(1 downto 0) <= temp_alu_op(i);
                        alu1_pc <= temp_pc(i);
                    end if;
                end if;

                -- branch
                if(temp_ready(i) = '1' and ((temp_opcode(i) = "1000") or (temp_opcode(i) = "1010") or (temp_opcode(i) = "1001") or (temp_opcode(i) = "1011"))) then
                    if temp_count(i) > age_branch then
                        age_branch := temp_count(i);
                        br1_oper1 <= temp_opr_1(i);
                        br1_imm6 <= temp_imm6(i);
                        br1_imm9 <= temp_imm9(i);
                        br1_mode <= temp_opcode(i);
                        br1_pc <= temp_pc(i);
                    end if;
                end if;
            end loop;
            if opcode_1 /= "1111" then
                for i in 0 to rs_size-1 loop
                    if temp_val(i) = '0' then
                        temp_opcode(i) := opcode_1;
                        temp_pc(i) := pc_in_1;
                        temp_alu_op(i) := alu_op_1;
                        temp_opr_1(i) := r_2;
                        temp_opr_2(i) := r_3;
                        temp_dest(i) := r_1;
                        temp_val(i) := '1';
                        temp_val_1(i) := v_2;
                        temp_val_2(i) := v_3;
                        temp_imm6(i) := imm6_1;
                        temp_imm9(i) := imm9_1;
                        temp_ready(i) := '0';
                        temp_count(i) := 0;
                        exit;    
                    end if;
                end loop; 
            end if;
            
            if opcode_2 /= "1111" then
                for i in 0 to rs_size-1 loop
                    if temp_val(i) = '0' then
                        temp_opcode(i) := opcode_2;
                        temp_alu_op(i) := alu_op_2;
                        temp_pc(i) := pc_in_2;
                        temp_opr_1(i) := r_5;
                        temp_opr_2(i) := r_6;
                        temp_dest(i) := r_4;
                        temp_val(i) := '1';
                        temp_val_1(i) := v_5;
                        temp_val_2(i) := v_6;
                        temp_imm6(i) := imm6_2;
                        temp_imm9(i) := imm9_2;
                        temp_ready(i) := '0';
                        temp_count(i) := 0;
                        exit;    
                    end if;
                end loop;
            end if;

            for i in 0 to rs_size-1 loop
                prf_addr_bus(i*2)(16) <= temp_val_1(i);
                prf_addr_bus(i*2)(15 downto 0) <= temp_opr_1(i);
    
                prf_addr_bus(i*2+1)(16) <= temp_val_2(i);
                prf_addr_bus(i*2+1)(15 downto 0) <= temp_opr_2(i);
            end loop;
            
            for i in 0 to rs_size-1 loop
                if temp_val(i) = '1' then

                    temp_val_1(i) := prf_data_bus(i*2)(16);
                    temp_opr_1(i) := prf_data_bus(i*2)(15 downto 0);
        
                    temp_val_2(i) := prf_data_bus(i*2+1)(16);
                    temp_opr_2(i) := prf_data_bus(i*2+1)(15 downto 0);
                    
                    temp_ready(i) := temp_val_1(i) and temp_val_2(i);
                end if;
                temp_count(i) := temp_count(i)+1;
            end loop;

        end if;
        opcode <= temp_opcode;
        opr_1 <= temp_opr_1;
        opr_2 <= temp_opr_2;
        dest <= temp_dest;
        val <= temp_val;
        val_1 <= temp_val_1;
        val_2 <= temp_val_2;
        imm6 <= temp_imm6;
        imm9 <= temp_imm9;
        ready <= temp_ready;
        count <= temp_count;
    end process;
end architecture;