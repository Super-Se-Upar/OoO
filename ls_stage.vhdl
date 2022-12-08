-- 3 ex
-- 1 alu + 1 l/s + branching

library ieee ;
use ieee.std_logic_1164.all ;
USE ieee.numeric_std.ALL;
use work.array_pkg.all;
entity ls_rs_stage is
    generic(
        rs_size: integer := 16
        -- there are 8 architectural registers
    ); 
    port(
        clk, stall, reset: in std_logic;  --system ip
        pc_in_1, pc_in_2:  in std_logic_vector(15 downto 0); --id stage
        opcode_1, opcode_2: in std_logic_vector(3 downto 0); --id stage
        imm6_1, imm6_2: in std_logic_vector(5 downto 0);  -- id stage
        imm9_1, imm9_2 : in std_logic_vector(8 downto 0);  -- id stage
        r_a_1, r_b_1, r_a_2, r_b_2: in std_logic_vector(15 downto 0);  --rr stage
        v_b_1, v_b_2: in std_logic;  --from rr
        prf_data_bus: in prf_data_array(0 to rs_size*2-1);-- (busy) (16 BIT DATA)  --from prf
        prf_addr_bus: out addr_array(0 to rs_size*2-1);

        mem_read_data_bus: in std_logic_vector(15 downto 0); -- from data memory
        mem_write_addr_bus: out std_logic_vector(15 downto 0); -- addr for writing
        mem_write_en: out std_logic; -- to memory to enable write
        mem_write_data_bus: out std_logic_vector(15 downto 0);
        mem_read_addr_bus: out std_logic_vector(15 downto 0) -- memory read addr

    );
end entity ls_rs_stage;

architecture bham2 of ls_rs_stage is
    type opcode_vector is array(0 to rs_size-1) of std_logic_vector(3 downto 0);
    type opr_vector is array(0 to rs_size-1) of std_logic_vector(15 downto 0);
    type imm6_vector is array(0 to rs_size-1) of std_logic_vector(5 downto 0);
    type imm9_vector is array(0 to rs_size-1) of std_logic_vector(8 downto 0);
    type count_vector is array(0 to rs_size-1) of integer;
    signal opcode: opcode_vector := (others=>(others=>'0')); 

    signal opr_1: opr_vector := (others=>(others=>'0')); 
    signal opr_2: opr_vector := (others=>(others=>'0')); 

    signal dest: opr_vector := (others=>(others=>'0')); 
    -- val : validity of rs entry
    signal val: std_logic_vector(0 to rs_size-1)  := (others=>'0');

    signal val_1: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    signal val_2: std_logic_vector(0 to rs_size-1)  := (others=>'0');

    signal imm6: imm6_vector := (others=>(others=>'0')); 
    signal imm9: imm9_vector  := (others=>(others=>'0'));
    signal head_pointer: integer := 0;
    signal tail_pointer: integer := 0;
begin
    process(clk)
    variable temp_opcode: opcode_vector := (others=>(others=>'0'));
    
    variable temp_opr_1: opr_vector := (others=>(others=>'0')); 
    variable temp_opr_2: opr_vector := (others=>(others=>'0'));
    variable temp_dest: opr_vector := (others=>(others=>'0')); 
    -- val : validity of rs entry
    variable temp_val: std_logic_vector(0 to rs_size-1)  := (others=>'0');

    variable temp_val_1: std_logic_vector(0 to rs_size-1)  := (others=>'0');
    variable temp_val_2: std_logic_vector(0 to rs_size-1)  := (others=>'0');

    variable temp_imm6: imm6_vector := (others=>(others=>'0')); 
    variable temp_imm9: imm9_vector  := (others=>(others=>'0'));

    variable temp_head_pointer: integer := 0;
    variable temp_tail_pointer: integer := 0;
    begin 

        if falling_edge(clk) then
            mem_write_en <= '0';
            temp_opcode := opcode;
            temp_opr := opr;

            temp_dest := dest;
            temp_val := val;
            temp_val_1 := val_1;
            temp_val_2 := val_2;
            temp_imm6 := imm6;
            temp_imm9 := imm9;
            temp_head_pointer := head_pointer;
            temp_tail_pointer := tail_pointer;

            if temp_val(temp_head_pointer) = '1' and temp_val_1(temp_head_pointer) = '1' then
                -- wb initiate
                if temp_opcode(temp_head_pointer) = "1100" then
                    
                    mem_write_addr_bus <= temp_opr;
                    mem_write_data_bus <= temp_opr;
                    mem_write_en <= '1';
                    temp_head_pointer = (temp_head_pointer+1) rem rs_size;
                else if;
            end if;

            if(temp_ready(i) = '1' and ((temp_opcode(i) = "0111") or (temp_opcode(i) = "0000") or (temp_opcode(i) = "0101") or (temp_opcode(i) = "1100") or (temp_opcode(i) = "1101"))) then
                if temp_count(i) > age_ls1 then
                    age_ls1 := temp_count(i);
                    ls1_oper <= temp_opr_1(i);
                    ls1_dest <= temp_dest(i);
                    ls1_imm6 <= temp_imm6(i);
                    ls1_imm9 <= temp_imm9(i);
                    ls1_mode <= temp_opcode(i);
                    ls1_pc <= temp_pc(i);
                end if;
            end if;
          
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
        end if;
    end process;
end architecture;