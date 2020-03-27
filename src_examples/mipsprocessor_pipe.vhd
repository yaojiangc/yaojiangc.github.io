-- Author: Yao Jiang Cheah, Alain Njipwo

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
LIBRARY work;

ENTITY mipsprocessor_pipe IS 
	PORT
	(
		Clock :  IN  STD_LOGIC;
		Reset :  IN  STD_LOGIC
	);
END mipsprocessor_pipe;

ARCHITECTURE bdf_type OF mipsprocessor_pipe IS 

COMPONENT register_file
	PORT(CLK : IN STD_LOGIC;
		 w_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 w_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT main_control
	PORT(i_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_reg_dest : OUT STD_LOGIC;
		 o_jump : OUT STD_LOGIC;
		 o_branch : OUT STD_LOGIC;
		 o_mem_to_reg : OUT STD_LOGIC;
		 o_mem_write : OUT STD_LOGIC;
		 o_ALU_src : OUT STD_LOGIC;
		 o_reg_write : OUT STD_LOGIC;
		 o_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 o_mem_read : out std_logic
	);
END COMPONENT;

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT imem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dmem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 stall : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT branch_comparator
	PORT( i_rs_data, i_rt_data : in std_logic_vector(31 downto 0);
  	    o_equal : out std_logic); -- '1' if A==B, '0' otherwise
END COMPONENT;

COMPONENT forwarding_unit 
	PORT(
		-- ID Stage Signals
		id_instruction : in std_logic_vector(31 downto 0);
		--END ID Stage Signals
	
		-- EX Stage signals
		ex_instruction : in std_logic_vector(31 downto 0);
		ex_reg_write : in std_logic;
		ex_write_reg_sel : in std_logic_vector(4 downto 0);
		ex_reg_dest : in std_logic;
		-- END EX Stage signals
		
		-- MEM Stage signals
		mem_instruction : in std_logic_vector(31 downto 0);
		mem_reg_dest   : in std_logic;
  	    mem_reg_write  : in std_logic;
		mem_write_reg_sel : in std_logic_vector(4 downto 0);
		-- END MEM Stage signals
		
		-- WB Stage signals
  	    wb_reg_write  : in std_logic;
		wb_instruction : in std_logic_vector(31 downto 0);
		wb_write_reg_sel : in std_logic_vector(4 downto 0);
		-- END WB Stage signals

		forwardA : out std_logic_vector(1 downto 0);
		forwardB : out std_logic_vector(1 downto 0);
		
		forward_rs : out std_logic;
		forward_rt : out std_logic
		
		);	
END COMPONENT;

COMPONENT mux4to1_32bit
	PORT(A,B,C,D: in std_logic_vector(31 downto 0);
		S: in std_logic_vector(1 downto 0);
        O: out std_logic_vector(31 downto 0));
END COMPONENT;

COMPONENT hazard_detection_unit
	port(		
		id_instruction : in std_logic_vector(31 downto 0);
		id_jump : in std_logic;
		id_branch : in std_logic;
		ex_instruction : in std_logic_vector(31 downto 0);
		ex_write_reg_sel : in std_logic_vector(4 downto 0);
		ex_mem_read : in std_logic;
		PC_Src : in std_logic;
		stall : out std_logic; 
		IF_ID_flush : out std_logic;
		ID_EX_flush : out std_logic
		);	
END COMPONENT;

--------- pipeline registers ----------------------------------------------------
COMPONENT if_id
	PORT(CLK	: in  std_logic;
  		id_flush, id_stall, ifid_reset : in std_logic;
       		if_instruction  : in std_logic_vector(31 downto 0);
       		id_instruction  : out std_logic_vector(31 downto 0);
       		if_pc_plus_4 : in std_logic_vector(31 downto 0);
      	 	id_pc_plus_4 : out std_logic_vector(31 downto 0)
		);
END COMPONENT;

COMPONENT id_ex
	PORT(CLK    : in  std_logic;
  		ex_flush, ex_stall, idex_reset : in std_logic;
  		id_instruction  : in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        ex_instruction  : out std_logic_vector(31 downto 0);
        id_pc_plus_4 : in std_logic_vector(31 downto 0);
       	ex_pc_plus_4 : out std_logic_vector(31 downto 0);

  	-- CONTROL signals
        id_reg_dest   : in std_logic;
  	    id_mem_to_reg : in std_logic;
  	    id_ALU_op 	 : in std_logic_vector(3 downto 0);
  	    id_mem_write  : in std_logic;
  	    id_ALU_src 	 : in std_logic;
  	    id_reg_write  : in std_logic;
		id_mem_read : in std_logic;
  	    ex_reg_dest   : out std_logic;
  	    ex_mem_to_reg : out std_logic;
  	    ex_ALU_op 	 : out std_logic_vector(3 downto 0);
  	    ex_mem_write  : out std_logic;
  	    ex_ALU_src 	 : out std_logic;
  	    ex_reg_write  : out std_logic;
		ex_mem_read : out std_logic;
  	-- END CONTROL signals

  	-- Register signals
  		id_rs_data : in std_logic_vector(31 downto 0);
  		id_rt_data : in std_logic_vector(31 downto 0);
  		ex_rs_data : out std_logic_vector(31 downto 0);
  		ex_rt_data : out std_logic_vector(31 downto 0);
  		id_rs_sel : in std_logic_vector(4 downto 0);
  		id_rt_sel : in std_logic_vector(4 downto 0);
  		id_rd_sel : in std_logic_vector(4 downto 0);
  		ex_rs_sel : out std_logic_vector(4 downto 0);
  		ex_rt_sel : out std_logic_vector(4 downto 0);
  		ex_rd_sel : out std_logic_vector(4 downto 0);
  	-- END Register signals

  		id_extended_immediate : in std_logic_vector(31 downto 0);
  		ex_extended_immediate : out std_logic_vector(31 downto 0)
  	    );
END COMPONENT;

COMPONENT ex_mem 
	PORT(CLK           : in  std_logic;
		mem_flush, mem_stall, exmem_reset : in std_logic;
		ex_instruction  : in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        mem_instruction  : out std_logic_vector(31 downto 0);
        ex_pc_plus_4 : in std_logic_vector(31 downto 0);
       	mem_pc_plus_4 : out std_logic_vector(31 downto 0);

  	-- CONTROL signals
        ex_reg_dest   : in std_logic;
  	    ex_mem_to_reg : in std_logic;
  	    ex_mem_write  : in std_logic;
  	    ex_reg_write  : in std_logic;
		ex_forwardA : in std_logic_vector(1 downto 0);
		ex_forwardB : in std_logic_vector(1 downto 0);
  	    mem_reg_dest   : out std_logic;
  	    mem_mem_to_reg : out std_logic;
  	    mem_mem_write  : out std_logic;
  	    mem_reg_write  : out std_logic;
  	-- END CONTROL signals

  	-- ALU signals
		ex_ALU_out : in std_logic_vector(31 downto 0);
		mem_ALU_out : out std_logic_vector(31 downto 0);
  	-- END ALU signals

	-- Register signals
		ex_mux4to1_B : in std_logic_vector(31 downto 0);
		mem_mux4to1_B : out std_logic_vector(31 downto 0);
  		ex_write_reg_sel : in std_logic_vector(4 downto 0); -- see the Reg. Dest. mux in the pipeline archteicture diagram
  		mem_write_reg_sel : out std_logic_vector(4 downto 0)
  	-- END Register signals
  	    );
END COMPONENT;

COMPONENT mem_wb
	PORT(CLK           : in  std_logic;
		wb_flush, wb_stall, memwb_reset : in std_logic;
		mem_instruction  : in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        wb_instruction  : out std_logic_vector(31 downto 0);
        mem_pc_plus_4 : in std_logic_vector(31 downto 0);
       	wb_pc_plus_4 : out std_logic_vector(31 downto 0);

		-- CONTROL signals
        mem_reg_dest   : in std_logic;
  	    mem_mem_to_reg : in std_logic;
  	    mem_reg_write  : in std_logic;
  	    wb_reg_dest   : out std_logic;
  	    wb_mem_to_reg : out std_logic;
  	    wb_reg_write  : out std_logic;
		-- END CONTROL signals

		-- ALU signals
		mem_ALU_out : in std_logic_vector(31 downto 0);
		wb_ALU_out : out std_logic_vector(31 downto 0);
		-- END ALU signals

		-- Memory signals
		mem_dmem_out : in std_logic_vector(31 downto 0);
		wb_dmem_out : out std_logic_vector(31 downto 0);
		-- END Memory signals

		-- Register signals
  		mem_write_reg_sel : in std_logic_vector(4 downto 0);
  		wb_write_reg_sel : out std_logic_vector(4 downto 0)
		-- END Register signals
  	    );
END COMPONENT;

signal	w_if_mux32 : std_logic_vector(31 downto 0);
signal	w_if_PC : std_logic_vector(31 downto 0);
signal	w_if_nextPC : std_logic_vector(31 downto 0);
signal	w_if_instruction : std_logic_vector(31 downto 0);
signal	w_if_PCinput : std_logic_vector(31 downto 0);
signal	w_id_instruction : std_logic_vector(31 downto 0);
signal	w_id_nextPC : std_logic_vector(31 downto 0);
signal	w_id_rs_data : std_logic_vector(31 downto 0);
signal	w_id_rt_data : std_logic_vector(31 downto 0);
signal	w_id_extended_immediate : std_logic_vector(31 downto 0);
signal	w_id_reg_dest : std_logic;
signal	w_id_jump : std_logic;
signal	w_id_branch : std_logic;
signal	w_id_mem_to_reg : std_logic;
signal	w_id_mem_write : std_logic;
signal	w_id_ALU_src : std_logic;
signal	w_id_reg_write : std_logic;
signal	w_id_ALU_op : std_logic_vector(3 downto 0);
signal	w_id_jump_address : std_logic_vector(31 downto 0);
signal	w_id_sll2_branch : std_logic_vector(31 downto 0);
signal	w_id_branch_address : std_logic_vector(31 downto 0);
signal	w_id_branch_comparator : std_logic;
signal	w_id_mem_read : std_logic;
signal	w_id_branch_mux32_A : std_logic_vector(31 downto 0);
signal	w_id_branch_mux32_B : std_logic_vector(31 downto 0);
signal	w_ex_instruction : std_logic_vector(31 downto 0);
signal	w_ex_nextPC : std_logic_vector(31 downto 0);
signal	w_ex_reg_dest : std_logic;
signal	w_ex_mem_to_reg : std_logic;
signal	w_ex_mem_write : std_logic;
signal	w_ex_ALU_src : std_logic;
signal	w_ex_reg_write : std_logic;
signal	w_ex_mem_read : std_logic;
signal	w_ex_ALU_op : std_logic_vector(3 downto 0);
signal	w_ex_rs_data : std_logic_vector(31 downto 0);
signal	w_ex_rt_data : std_logic_vector(31 downto 0);
signal	w_ex_extended_immediate : std_logic_vector(31 downto 0);
signal	w_ex_rs_sel : std_logic_vector(4 downto 0);
signal	w_ex_rt_sel : std_logic_vector(4 downto 0);
signal	w_ex_rd_sel : std_logic_vector(4 downto 0);
signal	w_ex_sll_2 : std_logic_vector(31 downto 0);
signal	w_ex_mux32 : std_logic_vector(31 downto 0);
signal	w_ex_ALU_out : std_logic_vector(31 downto 0);
signal	w_ex_ALU_zero : std_logic;
signal	w_ex_write_reg_sel : std_logic_vector(4 downto 0);
signal	w_ex_forwardA : std_logic_vector(1 downto 0);
signal	w_ex_forwardB : std_logic_vector(1 downto 0);
signal	w_forward_rt : std_logic;
signal	w_forward_rs : std_logic;
signal	w_ex_mux4to1_A : std_logic_vector(31 downto 0);
signal	w_ex_mux4to1_B	: std_logic_vector(31 downto 0);
signal	w_ex_mux32_rt	: std_logic_vector(31 downto 0);
signal	w_mem_instruction : std_logic_vector(31 downto 0);
signal	w_mem_nextPC : std_logic_vector(31 downto 0);
signal	w_mem_reg_dest : std_logic;
signal	w_mem_mem_to_reg : std_logic;
signal	w_mem_mem_write : std_logic;
signal	w_mem_reg_write : std_logic;
signal	w_mem_ALU_out : std_logic_vector(31 downto 0);
signal	w_mem_mux4to1_B : std_logic_vector(31 downto 0);
signal	w_mem_write_reg_sel : std_logic_vector(4 downto 0);
signal	w_PCSrc	: std_logic;
signal	w_mem_dmem_out : std_logic_vector(31 downto 0);
signal	w_wb_nextPC : std_logic_vector(31 downto 0);
signal	w_wb_instruction : std_logic_vector(31 downto 0);
signal	w_wb_reg_dest : std_logic;
signal	w_wb_mem_to_reg : std_logic;
signal	w_wb_reg_write : std_logic;
signal	w_wb_ALU_out : std_logic_vector(31 downto 0);
signal	w_wb_dmem_out : std_logic_vector(31 downto 0);
signal	w_wb_write_reg_sel : std_logic_vector(4 downto 0);
signal	w_wb_mux32 : std_logic_vector(31 downto 0);
signal	w_id_instruction_concat : std_logic_vector(31 downto 0);
signal	w_stall : std_logic;
signal	w_IF_ID_flush : std_logic;
signal	w_ID_EX_flush : std_logic;

BEGIN 

w_id_instruction_concat(25 downto 0) <= w_id_instruction(25 downto 0);
w_id_instruction_concat(31 downto 26) <= "000000";

---------Instruction Fetch (IF)----------------------------------------------------
inst_if_mux32 : mux21_32bit
PORT MAP(i_sel => w_PCSrc, 
		 i_0 => w_if_nextPC, 
		 i_1 => w_id_branch_address, 
		 o_mux => w_if_mux32
		 );
		 
inst_if_mux32_jump : mux21_32bit
PORT MAP(i_sel => w_id_jump, 
		 i_0 => w_if_mux32, 
		 i_1 => w_id_jump_address, 
		 o_mux => w_if_PCinput
		 );

inst_if_pc : pc_reg
PORT MAP(CLK => Clock,
		reset => Reset,
		stall => w_stall,
		 i_next_PC => w_if_PCinput,
		 o_PC => w_if_PC
		 );

inst_if_adder32 : adder_32
PORT MAP(i_A => w_if_PC,
		 i_B => "00000000000000000000000000000100",
		 o_F => w_if_nextPC
		 );
		 
inst_if_imem : imem
GENERIC MAP(depth_exp_of_2 => 10, mif_filename => "imem.mif")
PORT MAP(clock => Clock,
		 wren => '0',
		 address => w_if_PC(11 DOWNTO 2),
		 byteena => "1111",
		 data => "00000000000000000000000000000000",
		 q => w_if_instruction
		 );
		 
---------IF/ID Pipeline Register---------------------------------------------------
inst_ifid : if_id
PORT MAP(CLK =>	Clock,
  		id_flush => w_IF_ID_flush,--------
		id_stall => w_stall,--------
		ifid_reset => Reset,
       	if_instruction => w_if_instruction,
       	id_instruction => w_id_instruction,
       	if_pc_plus_4 => w_if_nextPC,
       	id_pc_plus_4 => w_id_nextPC
		);
		 
---------Intruction Decode (ID)----------------------------------------------------
inst_id_maincont : main_control
PORT MAP(i_instruction => w_id_instruction,
		 o_reg_dest => w_id_reg_dest,
		 o_jump => w_id_jump,
		 o_branch => w_id_branch,
		 o_mem_to_reg => w_id_mem_to_reg,
		 o_mem_write => w_id_mem_write,
		 o_ALU_src => w_id_ALU_src,
		 o_reg_write => w_id_reg_write,
		 o_ALU_op => w_id_ALU_op,
		 o_mem_read => w_id_mem_read
		 );

inst_id_reg : register_file
PORT MAP(CLK => Clock,
		 w_en => w_wb_reg_write, --control
		 reset => Reset,
		 rs_sel => w_id_instruction(25 downto 21),
		 rt_sel => w_id_instruction(20 downto 16),
		 w_data => w_wb_mux32,
		 w_sel => w_wb_write_reg_sel,
		 rs_data => w_id_rs_data, 
		 rt_data => w_id_rt_data 
		 );

inst_id_signex : sign_extender_16_32
PORT MAP(i_to_extend => w_id_instruction(15 downto 0),
		 o_extended => w_id_extended_immediate);
		 
inst_id_sll2_jump : sll_2
PORT MAP(i_to_shift => w_id_instruction_concat,
		 o_shifted => w_id_jump_address
		 );
		 		 
inst_id_sll2_branch : sll_2
PORT MAP(i_to_shift => w_id_extended_immediate,
		 o_shifted => w_id_sll2_branch
		 );
		
inst_id_adder32 : adder_32
PORT MAP(i_A => w_id_nextPC,
		 i_B => w_id_sll2_branch,
		 o_F => w_id_branch_address
		 );
		 
inst_id_branch_mux32_A : mux21_32bit
PORT MAP(i_sel => w_forward_rs,
		 i_0 => w_id_rs_data,
		 i_1 => w_mem_ALU_out,
		 o_mux => w_id_branch_mux32_A
		 );

inst_id_branch_mux32_B : mux21_32bit
PORT MAP(i_sel => w_forward_rt,
		 i_0 => w_id_rt_data,
		 i_1 => w_mem_ALU_out,
		 o_mux => w_id_branch_mux32_B
		 );
		 
inst_branch_comporator : branch_comparator
PORT MAP(i_rs_data => w_id_branch_mux32_A,
		i_rt_data => w_id_branch_mux32_B,
  	    o_equal => w_id_branch_comparator
		);
		
		
w_PCSrc <= w_id_branch_comparator AND w_id_branch;
		  
inst_hazard_detection_unit : hazard_detection_unit
PORT MAP(		
		id_instruction => w_id_instruction,
		id_jump => w_id_jump,
		id_branch => w_id_branch,
		ex_instruction => w_ex_instruction,
		ex_write_reg_sel => w_ex_write_reg_sel,
		ex_mem_read => w_ex_mem_read,
		PC_Src => w_PCSrc,
		stall => w_stall,
		IF_ID_flush => w_IF_ID_flush,
		ID_EX_flush => w_ID_EX_flush
		);	

---------ID/EX Pipeline Register---------------------------------------------------
inst_idex : id_ex
PORT MAP(CLK => Clock,
  		ex_flush => w_ID_EX_flush, --
		ex_stall => w_stall, --
		idex_reset => Reset,
  		id_instruction => w_id_instruction, 
       	ex_instruction => w_ex_instruction,
       	id_pc_plus_4 => w_id_nextPC,
       	ex_pc_plus_4 => w_ex_nextPC,


		-- CONTROL signals
        id_reg_dest => w_id_reg_dest,
  	    id_mem_to_reg => w_id_mem_to_reg,
  	    id_ALU_op => w_id_ALU_op,
  	    id_mem_write => w_id_mem_write,
  	    id_ALU_src => w_id_ALU_src,
		id_mem_read => w_id_mem_read,
  	    id_reg_write => w_id_reg_write,
  	    ex_reg_dest => w_ex_reg_dest,
  	    ex_mem_to_reg => w_ex_mem_to_reg,
  	    ex_ALU_op => w_ex_ALU_op,
  	    ex_mem_write => w_ex_mem_write,
  	    ex_ALU_src => w_ex_ALU_src,
  	    ex_reg_write => w_ex_reg_write,
		ex_mem_read => w_ex_mem_read,
		-- END CONTROL signals

		-- Register signals
  		id_rs_data => w_id_rs_data,
  		id_rt_data => w_id_rt_data,
  		ex_rs_data => w_ex_rs_data,
  		ex_rt_data => w_ex_rt_data,
  		id_rs_sel => w_id_instruction(25 downto 21),
  		id_rt_sel => w_id_instruction(20 downto 16),
  		id_rd_sel => w_id_instruction(15 downto 11),
  		ex_rs_sel => w_ex_rs_sel,
  		ex_rt_sel => w_ex_rt_sel,
  		ex_rd_sel => w_ex_rd_sel,
		-- END Register signals

  		id_extended_immediate => w_id_extended_immediate,
  		ex_extended_immediate => w_ex_extended_immediate
  	    );

-----------Instruction Execution (EX)---------------------------------------------
inst_ex_mux4to1_A : mux4to1_32bit
PORT MAP(A => w_ex_rs_data,
		B => w_wb_mux32,
		C => w_mem_ALU_out,
		D => "00000000000000000000000000000000",
		S => w_ex_forwardA,
        O => w_ex_mux4to1_A
		);
		
inst_ex_mux4to1_B : mux4to1_32bit
PORT MAP(A => w_ex_rt_data,
		B => w_wb_mux32,
		C => w_mem_ALU_out,
		D => "00000000000000000000000000000000",
		S => w_ex_forwardB,
        O => w_ex_mux4to1_B
		);
		
inst_ex_mux32 : mux21_32bit
PORT MAP(i_sel => w_ex_ALU_src,
		 i_0 => w_ex_mux4to1_B,
		 i_1 => w_ex_extended_immediate,
		 o_mux => w_ex_mux32
		 );
		
inst_ex_sll_2 : sll_2
PORT MAP(i_to_shift => w_ex_extended_immediate,
		 o_shifted => w_ex_sll_2
		 );
		 	 
inst_ex_alu : alu
PORT MAP(ALU_OP => w_ex_ALU_op,
		 i_A => w_ex_mux4to1_A,
		 i_B => w_ex_mux32,
		 shamt => "00000",
		 zero => w_ex_ALU_zero,
		 ALU_out => w_ex_ALU_out
		 );
		 
inst_ex_mux5 : mux21_5bit
PORT MAP(i_sel => w_ex_reg_dest,
		 i_0 => w_ex_rt_sel,
		 i_1 => w_ex_rd_sel,
		 o_mux => w_ex_write_reg_sel
		 );
		 
inst_forwarding_unit : forwarding_unit
PORT MAP(
		-- ID Stage Signals
		id_instruction => w_id_instruction,
		-- END ID Stage Signals

		-- EX Stage signals
		ex_instruction => w_ex_instruction,
		ex_reg_write => w_ex_reg_write,
		ex_write_reg_sel => w_ex_write_reg_sel,
		ex_reg_dest => w_ex_reg_dest,
		-- END EX Stage signals
		
		-- MEM Stage signals
		mem_instruction => w_mem_instruction,
		mem_reg_dest => w_mem_reg_dest,
  	    mem_reg_write => w_mem_reg_write,
		mem_write_reg_sel => w_mem_write_reg_sel,
		-- END MEM Stage signals
		
		-- WB Stage signals
  	    wb_reg_write => w_wb_reg_write,
		wb_instruction => w_wb_instruction,
		wb_write_reg_sel => w_wb_write_reg_sel,
		-- END WB Stage signals
		
		forwardA => w_ex_forwardA,
		forwardB => w_ex_forwardB,
		forward_rs => w_forward_rs,
		forward_rt => w_forward_rt
		);	
---------EX/MEM Pipeline Register---------------------------------------------------
inst_exmem : ex_mem
PORT MAP(CLK => Clock,
		mem_flush => '0', ----
		mem_stall => '0', ----
		exmem_reset => Reset,
		ex_instruction => w_ex_instruction, -- pass instruction along (useful for debugging)
        mem_instruction => w_mem_instruction,
        ex_pc_plus_4 => w_ex_nextPC,
       	mem_pc_plus_4 => w_mem_nextPC,

		-- CONTROL signals
        ex_reg_dest => w_ex_reg_dest,
  	    ex_mem_to_reg => w_ex_mem_to_reg,
  	    ex_mem_write => w_ex_mem_write,
  	    ex_reg_write => w_ex_reg_write,
		ex_forwardA => w_ex_forwardA,
		ex_forwardB => w_ex_forwardB,
  	    mem_reg_dest => w_mem_reg_dest,
  	    mem_mem_to_reg => w_mem_mem_to_reg,
  	    mem_mem_write => w_mem_mem_write,
  	    mem_reg_write => w_mem_reg_write,
		-- END CONTROL signals

		-- ALU signals
		ex_ALU_out => w_ex_ALU_out,
		mem_ALU_out => w_mem_ALU_out,
		-- END ALU signals

		-- Register signals
		ex_mux4to1_B => w_ex_mux4to1_B,
		mem_mux4to1_B => w_mem_mux4to1_B,
  		ex_write_reg_sel => w_ex_write_reg_sel, 
  		mem_write_reg_sel => w_mem_write_reg_sel
		-- END Register signals
  	    );
		 
		 
---------Memory (MEM)----------------------------------------------------------------
inst_mem_dmem : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => Clock,
		 wren => w_mem_mem_write,
		 address => w_mem_ALU_out(11 DOWNTO 2),
		 byteena => "1111",
		 data => w_mem_mux4to1_B,
		 q => w_mem_dmem_out
		 );

---------MEM/WB Pipeline Register---------------------------------------------------
inst_memwb : mem_wb
PORT MAP(CLK => Clock,
		wb_flush => '0',
		wb_stall => '0', ---
		memwb_reset => Reset,
		mem_instruction => w_mem_instruction, -- pass instruction along (useful for debugging)
       	wb_instruction => w_wb_instruction,
        mem_pc_plus_4 => w_mem_nextPC,
       	wb_pc_plus_4 => w_wb_nextPC,

		-- CONTROL signals
       	mem_reg_dest => w_mem_reg_dest,
  		mem_mem_to_reg => w_mem_mem_to_reg,
  	    mem_reg_write => w_mem_reg_write,
  	    wb_reg_dest => w_wb_reg_dest,
  	    wb_mem_to_reg => w_wb_mem_to_reg,
  	    wb_reg_write => w_wb_reg_write,
		-- END CONTROL signals

		-- ALU signals
		mem_ALU_out => w_mem_ALU_out,
		wb_ALU_out => w_wb_ALU_out,
		-- END ALU signals

		-- Memory signals
		mem_dmem_out => w_mem_dmem_out,
		wb_dmem_out => w_wb_dmem_out,
		-- END Memory signals

		-- Register signals
  		mem_write_reg_sel => w_mem_write_reg_sel,
  		wb_write_reg_sel => w_wb_write_reg_sel
		-- END Register signals
  	    );

---------Write Back (WB)-_----------------------------------------------------------
inst_wb_mux32 : mux21_32bit
PORT MAP(i_sel => w_wb_mem_to_reg,
		 i_0 => w_wb_ALU_out,
		 i_1 => w_wb_dmem_out,
		 o_mux => w_wb_mux32
		 );

END bdf_type;