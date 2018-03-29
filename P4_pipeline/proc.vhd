library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proc is
end proc;

architecture arch of proc is

component usign_Ext is
port(
	data_in: in std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(31 downto 0)
);
end component;

component sign_Ext is
port(
	data_in: in std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(31 downto 0)
);
end component;

component Register_File is
port(
	clk, rst, write_en: in std_logic;
	writedata: in std_logic_vector(31 downto 0);
	addr_write, addr_regA, addr_regB: in std_logic_vector(4 downto 0);
	read_regA, read_regB: in std_logic_vector(15 downto 0)
);
end component;

component PC_adder is
port(
	override: in std_logic;
	pc, override_pc: in std_logic_vector(31 downto 0);
	output: in std_logic_vector(31 downto 0)
);
end component;

component PC is
port(
	clock: in std_logic;
	input: in std_logic_vector(31 downto 0);
	reset: in std_logic;
	output: out std_logic_vector(31 downto 0)
);
end component;

component mux_2to1 is
port(
	SEL : in  STD_LOGIC;
	A : in  STD_LOGIC_VECTOR (31 downto 0);
	B : in  STD_LOGIC_VECTOR (31 downto 0);
	X : out STD_LOGIC_VECTOR (31 downto 0)
);
end component;

component mux_2to1 is
port(
	SEL : in  STD_LOGIC;
	A : in  STD_LOGIC_VECTOR (31 downto 0);
	B : in  STD_LOGIC_VECTOR (31 downto 0);
	X : out STD_LOGIC_VECTOR (31 downto 0)
);
end component;

component instr_memory is
port(
	clock: in std_logic;
	writedata: in std_logic_vector (31 downto 0);
	address: in std_logic_vector (31 downto 0);
	memwrite: in std_logic;
	memread: in std_logic;
	readdata: out std_logic_vector (31 downto 0);
	waitrequest: out std_logic
);
end component;

component id_reg is
port(
	clock,rst:	in std_logic;
	pc_in: 		in std_logic_vector(31 downto 0);
	instruction_in: in std_logic_vector(31 downto 0);

	opCode_out: 	out std_logic_vector(5 downto 0);
	reg1_out:	out std_logic_vector(4 downto 0);
	reg2_out:	out std_logic_vector(4 downto 0);
	reg_write_in: in std_logic_vector(4 downto 0);
	address_out:	out std_logic_vector(25 downto 0);
	immediateValue_out:	out std_logic_vector(15 downto 0);
	shamt_out:	out std_logic_vector(5 downto 0);
	funct_out:	out std_logic_vector(5 downto 0);
	reg_write_out: out std_logic_vector(4 downto 0);
	pc_out: out std_logic_vector(31 downto 0)
);
end component;

component hazard_detection is
port(
	 EN : in  std_logic
     ; regA_ex   : in   std_logic_vector (4 downto 0)
     ; regB_id   : in   std_logic_vector (4 downto 0)
     ; regA_id   : in   std_logic_vector (4 downto 0)
     ; hazOut : out  std_logic
);
end component;

component ex_ALU is
port(
    clock, rst: in std_logic;
    a: in std_logic_vector(31 downto 0);
	b: in std_logic_vector(31 downto 0);
	address_in: in std_logic_vector(25 downto 0);
	offset_in: in std_logic_vector(15 downto 0);
	shift_in: in std_logic_vector(5 downto 0);
	signExtendImmediate: in std_logic_vector(31 downto 0);
	uSignExtendImmediate: in std_logic_vector(31 downto 0);
	sel: in std_logic_vector(5 downto 0);
	funct: in std_logic_vector(5 downto 0);
	pc_in: in std_logic_vector(32 downto 0);
	regWrite_in: in std_logic_vector(4 downto 0);

    jump: out std_logic;
    mem: out std_logic;
    load: out std_logic;
    store: out std_logic;
    jumpAddress: out std_logic_vector(31 downto 0);
    memAddress: out std_logic_vector(31 downto 0);
    regWrite_out: out std_logic_vector(4 downto 0);
    result: out std_logic_vector(31 downto 0)
);
end component;

component data_memory is
port(
	clock: in std_logic;
	data_in: in std_logic_vector(31 downto 0):=(others => '0');
	do_load: in std_logic := '0';
	do_write: in std_logic := '0';
	writeMem: in std_logic;
	addr: in std_logic_vector(31 downto 0);
	reg_id_in: in std_logic_vector(4 downto 0);
	data_out: out std_logic_vector(31 downto 0);
	reg_id_out: out std_logic_vector(4 downto 0)

);
end component;


-- test signals
signal data_in_usign_ext : std_logic_vector(15 downto 0);
signal data_out_usign_ext : std_logic_vector(31 downto 0);

signal data_in_sign_ext : std_logic_vector(15 downto 0);
signal data_out_sign_ext : std_logic_vector(31 downto 0);

signal clk_reg_file, rst_reg_file, write_en_reg_file: std_logic;
signal writedata_reg_file: std_logic_vector(31 downto 0);
signal addr_write_reg_file, addr_regA_reg_file, addr_regB_reg_file: std_logic_vector(4 downto 0);
signal read_regA_reg_file, read_regB_reg_file: std_logic_vector(15 downto 0);

signal override_pc_add: std_logic;
signal pc_pc_add, override_pc_pc_add: std_logic_vector(31 downto 0);
signal output_pc_add: std_logic_vector(31 downto 0);

signal clock_pc: std_logic;
signal input_pc: std_logic_vector(31 downto 0);
signal reset_pc: std_logic;
signal output_pc: std_logic_vector(31 downto 0); 

signal SEL_mux:  STD_LOGIC;
signal A_mux :  STD_LOGIC_VECTOR (31 downto 0);
signal B_mux :  STD_LOGIC_VECTOR (31 downto 0);
signal X_mux :  STD_LOGIC_VECTOR (31 downto 0);

signal clock_instr_mem:  std_logic;
signal writedata_instr_mem:  std_logic_vector (31 downto 0);
signal address_instr_mem:  std_logic_vector (31 downto 0);
signal memwrite_instr_mem:  std_logic;
signal memread_instr_mem:  std_logic;
signal readdata_instr_mem:  std_logic_vector (31 downto 0);
signal waitrequest_instr_mem:  std_logic;

signal clock,rst_id_reg:	 std_logic;
signal pc_in_id_reg:		 std_logic_vector(31 downto 0);
signal instruction_in_id_reg:  std_logic_vector(31 downto 0);
signal reg_write_out_id_reg:  std_logic_vector(4 downto 0);
signal reg_write_in_id_reg:  std_logic_vector(4 downto 0);
signal opCode_out_id_reg: std_logic_vector(5 downto 0);
signal reg1_out_id_reg: std_logic_vector(4 downto 0);
signal reg2_out_id_reg: std_logic_vector(4 downto 0);
signal address_out_id_reg: std_logic_vector(25 downto 0);
signal immediateValue_out_id_reg: std_logic_vector(15 downto 0);
signal shamt_out_id_reg: std_logic_vector(5 downto 0);
signal funct_out_id_reg: std_logic_vector(5 downto 0);
signal pc_out_id_reg: std_logic_vector(31 downto 0);

signal EN_hazard_dect : std_logic;
signal regA_ex_hazard_dect : std_logic_vector (4 downto 0);
signal regB_id_hazard_dect : std_logic_vector (4 downto 0);
signal regA_id_hazard_dect : std_logic_vector (4 downto 0);
signal hazOut_hazard_dect : std_logic;

signal clock_ex_alu, rst_ex_alu: std_logic;
signal a_ex_alu: std_logic_vector(31 downto 0);
signal b_ex_alu: std_logic_vector(31 downto 0);
signal address_in_ex_alu: std_logic_vector(25 downto 0);
signal offset_in_ex_alu: std_logic_vector(15 downto 0);
signal shift_in_ex_alu: std_logic_vector(5 downto 0);
signal signExtendImmediate_ex_alu: std_logic_vector(31 downto 0);
signal uSignExtendImmediate_ex_alu: std_logic_vector(31 downto 0);
signal sel_ex_alu: std_logic_vector(5 downto 0);
signal funct_ex_alu: std_logic_vector(5 downto 0);
signal pc_in_ex_alu: std_logic_vector(32 downto 0);
signal regWrite_in_ex_alu: std_logic_vector(4 downto 0);
signal jump_ex_alu: std_logic;
signal mem_ex_alu: std_logic;
signal load_ex_alu: std_logic;
signal store_ex_alu: std_logic;
signal jumpAddress_ex_alu: std_logic(31 downto 0);
signal memAddress_ex_alu: std_logic(31 downto 0);
signal regWrite_out_ex_alu: std_logic_vector(4 downto 0);
signal result_ex_alu: std_logic_vector(31 downto 0);


signal clock_data_mem: std_logic;
signal data_in_data_mem: std_logic_vector(31 downto 0):=(others => '0');
signal do_load_data_mem: std_logic := '0';
signal do_write_data_mem: std_logic := '0';
signal reg_id_in_data_mem: std_logic_vector(4 downto 0);
signal writeMem_data_mem: std_logic;
signal addr_data_mem: std_logic_vector(31 downto 0);
signal data_out_data_mem:  std_logic_vector(31 downto 0);
signal reg_id_out_data_mem:  std_logic_vector(4 downto 0);




--signal s_addr : std_logic_vector (31 downto 0);

begin
usign_ext_instance: usign_Ext
port map(
	);

sign_ext_instance: sign_Ext
port map(
	);


end;
