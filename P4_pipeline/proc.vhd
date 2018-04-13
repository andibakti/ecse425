library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proc is
port(clock, reset: in std_logic
	--instruction: in std_logic_vector(31 downto 0)
	--TODO-----------------------------------------------

	);
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
	read_regA, read_regB: out std_logic_vector(31 downto 0)
);
end component;

component PC_adder is
port(
	override: in std_logic;
	pc, override_pc: in std_logic_vector(31 downto 0);
	output_add: out std_logic_vector(31 downto 0)
);
end component;

component PC is
port(
	clock: in std_logic;
	input: in std_logic_vector(31 downto 0);
	reset: in std_logic;
	output_pc: out std_logic_vector(31 downto 0)
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
	ex_ALU_result_in: in std_logic_vector(31 downto 0);
	ex_ALU_result_out: out std_logic_vector(31 downto 0);
	opCode_out: 	out std_logic_vector(5 downto 0);
	reg1_out:	out std_logic_vector(4 downto 0);
	reg2_out:	out std_logic_vector(4 downto 0);
	reg_write_in: in std_logic_vector(4 downto 0);
	address_out:	out std_logic_vector(25 downto 0);
	immediateValue_out:	out std_logic_vector(15 downto 0);
	shamt_out:	out std_logic_vector(4 downto 0);
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
	shift_in: in std_logic_vector(4 downto 0);
	signExtendImmediate: in std_logic_vector(31 downto 0);
	uSignExtendImmediate: in std_logic_vector(31 downto 0);
	sel: in std_logic_vector(5 downto 0);
	funct: in std_logic_vector(5 downto 0);
	pc_in: in std_logic_vector(31 downto 0);
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

signal clk: std_logic;
signal rst:std_logic;
constant clk_period : time := 1 ns;


-- test signals
signal data_in_usign_ext : std_logic_vector(15 downto 0);
signal data_out_usign_ext : std_logic_vector(31 downto 0);

signal data_in_sign_ext : std_logic_vector(15 downto 0);
signal data_out_sign_ext : std_logic_vector(31 downto 0);

signal write_en_reg_file: std_logic;
signal writedata_reg_file: std_logic_vector(31 downto 0);
signal addr_write_reg_file, addr_regA_reg_file, addr_regB_reg_file: std_logic_vector(4 downto 0);
signal read_regA_reg_file, read_regB_reg_file: std_logic_vector(31 downto 0);

signal override: std_logic;
signal program_counter, override_pc: std_logic_vector(31 downto 0);
signal output_pc_add: std_logic_vector(31 downto 0);

signal input_pc: std_logic_vector(31 downto 0);
signal output_pc: std_logic_vector(31 downto 0); 

signal SEL_mux:  STD_LOGIC;
signal A_mux :  STD_LOGIC_VECTOR (31 downto 0);
signal B_mux :  STD_LOGIC_VECTOR (31 downto 0);
signal X_mux :  STD_LOGIC_VECTOR (31 downto 0);

signal writedata_instr_mem:  std_logic_vector (31 downto 0);
signal address_instr_mem:  std_logic_vector (31 downto 0);
signal memwrite_instr_mem:  std_logic;
signal memread_instr_mem:  std_logic;
signal readdata_instr_mem:  std_logic_vector (31 downto 0);
signal waitrequest_instr_mem:  std_logic;

signal pc_in_id_reg:		 std_logic_vector(31 downto 0);
signal instruction_in_id_reg:  std_logic_vector(31 downto 0);
signal reg_write_out_id_reg:  std_logic_vector(4 downto 0);
signal reg_write_in_id_reg:  std_logic_vector(4 downto 0);
signal ex_ALU_result_in_id_reg: std_logic_vector(31 downto 0);
signal ex_ALU_result_out_id_reg: std_logic_vector(31 downto 0);
signal opCode_out_id_reg: std_logic_vector(5 downto 0);
signal reg1_out_id_reg: std_logic_vector(4 downto 0);
signal reg2_out_id_reg: std_logic_vector(4 downto 0);
signal address_out_id_reg: std_logic_vector(25 downto 0);
signal immediateValue_out_id_reg: std_logic_vector(15 downto 0);
signal shamt_out_id_reg: std_logic_vector(4 downto 0);
signal funct_out_id_reg: std_logic_vector(5 downto 0);
signal pc_out_id_reg: std_logic_vector(31 downto 0);

signal EN_hazard_dect : std_logic;
signal regA_ex_hazard_dect : std_logic_vector (4 downto 0);
signal regB_id_hazard_dect : std_logic_vector (4 downto 0);
signal regA_id_hazard_dect : std_logic_vector (4 downto 0);
signal hazOut_hazard_dect : std_logic;

signal a_ex_alu: std_logic_vector(31 downto 0);
signal b_ex_alu: std_logic_vector(31 downto 0);
signal address_in_ex_alu: std_logic_vector(25 downto 0);
signal offset_in_ex_alu: std_logic_vector(15 downto 0);
signal shift_in_ex_alu: std_logic_vector(4 downto 0);
signal signExtendImmediate_ex_alu: std_logic_vector(31 downto 0);
signal uSignExtendImmediate_ex_alu: std_logic_vector(31 downto 0);
signal sel_ex_alu: std_logic_vector(5 downto 0);
signal funct_ex_alu: std_logic_vector(5 downto 0);
signal pc_in_ex_alu: std_logic_vector(31 downto 0);
signal regWrite_in_ex_alu: std_logic_vector(4 downto 0);
signal jump_ex_alu: std_logic;
signal mem_ex_alu: std_logic;
signal load_ex_alu: std_logic;
signal store_ex_alu: std_logic;
signal jumpAddress_ex_alu: std_logic_vector(31 downto 0);
signal memAddress_ex_alu: std_logic_vector(31 downto 0);
signal regWrite_out_ex_alu: std_logic_vector(4 downto 0);
signal result_ex_alu: std_logic_vector(31 downto 0);


signal data_in_data_mem: std_logic_vector(31 downto 0):=(others => '0');
signal do_load_data_mem: std_logic := '0';
signal do_write_data_mem: std_logic := '0';
signal reg_id_in_data_mem: std_logic_vector(4 downto 0);
signal writeMem_data_mem: std_logic;
signal addr_data_mem: std_logic_vector(31 downto 0);
signal data_out_data_mem:  std_logic_vector(31 downto 0);
signal reg_id_out_data_mem:  std_logic_vector(4 downto 0);


--INTERSTAGE REGISTERS (not used)
signal IF_ID_reg: std_logic_vector(31 downto 0);
signal ID_EX_reg: std_logic_vector(31 downto 0);
signal EX_MEM_reg: std_logic_vector(31 downto 0);
signal MEM_WB_reg: std_logic_vector(31 downto 0);



--signal s_addr : std_logic_vector (31 downto 0);

begin
usign_ext_instance: usign_Ext
port map(
	data_in => data_in_usign_ext,
	data_out => data_out_usign_ext
	);

sign_ext_instance: sign_Ext
port map(
	data_in => data_in_sign_ext,
	data_out => data_out_sign_ext
	);

register_file_instance: register_file
port map(
	clk => clk,
	rst => rst,
	write_en => write_en_reg_file,
	writedata => writedata_reg_file,
	addr_write => addr_write_reg_file,
	addr_regA => addr_regA_reg_file,
	addr_regB => addr_regB_reg_file,
	read_regA => read_regA_reg_file,
	read_regB => read_regB_reg_file
	);

pc_adder_instance: pc_adder
port map(
	override => override,
	pc => program_counter,
	override_pc => override_pc,
	output_add => output_pc_add
	);

pc_instance: pc
port map(
	clock => clk,
	input => input_pc,
	reset => rst,
	output_pc => output_pc
	);

mux_2to1_instance1: mux_2to1
port map(
	sel => SEL_mux,
	a => A_mux,
	b => B_mux,
	x => X_mux
	);

instr_memory_instance: instr_memory
port map(
	clock => clk,
	writedata => writedata_instr_mem,
	address => address_instr_mem,
	memwrite => memwrite_instr_mem,
	memread => memread_instr_mem,
	readdata => readdata_instr_mem,
	waitrequest => waitrequest_instr_mem
	);

id_reg_instance: id_reg
port map(
	clock => clk,
	rst => rst,
	pc_in => pc_in_id_reg,
	instruction_in => instruction_in_id_reg,
	ex_ALU_result_in => ex_ALU_result_in_id_reg,
	ex_ALU_result_out => ex_ALU_result_out_id_reg, 
	opCode_out => opCode_out_id_reg,
	reg1_out => reg1_out_id_reg,
	reg2_out => reg2_out_id_reg,
	reg_write_in => reg_write_in_id_reg,
	address_out =>address_out_id_reg,
	immediateValue_out => immediateValue_out_id_reg,
	shamt_out => shamt_out_id_reg,
	funct_out => funct_out_id_reg,
	reg_write_out => reg_write_out_id_reg,
	pc_out => pc_out_id_reg
	);

hazard_detection_instance: hazard_detection
port map(
	en => EN_hazard_dect,
	regA_ex => regA_ex_hazard_dect,
	regA_id => regA_id_hazard_dect,
	regB_id => regB_id_hazard_dect,
	hazOut => hazOut_hazard_dect
	);

ex_alu_instance: ex_ALU
port map(
	clock => clk,
	rst => rst,
	a => a_ex_alu,
	b => b_ex_alu,
	address_in => address_in_ex_alu,
	offset_in => offset_in_ex_alu,
	shift_in  => shift_in_ex_alu,
	signExtendImmediate => signExtendImmediate_ex_alu,
	uSignExtendImmediate => uSignExtendImmediate_ex_alu,
	sel => sel_ex_alu,
	funct => funct_ex_alu,
	pc_in => pc_in_ex_alu,
	regWrite_in => regWrite_in_ex_alu,
	jump => jump_ex_alu,
	mem => mem_ex_alu,
	load => load_ex_alu,
	store => store_ex_alu,
	jumpAddress => jumpAddress_ex_alu,
	memAddress => memAddress_ex_alu,
	regWrite_out => regWrite_out_ex_alu,
	result => result_ex_alu
	);

data_memory_instance: data_memory
port map(
	clock => clk,
	data_in => data_in_data_mem,
	do_load => do_load_data_mem,
	do_write => do_write_data_mem,
	writeMem => writeMem_data_mem,
	addr => addr_data_mem,
	reg_id_in => reg_id_in_data_mem,
	data_out => data_out_data_mem,
	reg_id_out => reg_id_out_data_mem
	);


clk <= clock;
rst <= reset;



--clk_process : process
--begin
--  clk <= '0';
--  wait for clk_period/2;
--  clk <= '1';
--  wait for clk_period/2;
--end process;

main : process(clock, reset)
	begin
		if(rising_edge(clock)) then


			--pc <- pc-add
			override <= jump_ex_alu;
			override_pc <= jumpAddress_ex_alu;

			input_pc <= output_pc_add;

			--pc of pc adder <- output of pc
			program_counter <= output_pc;

			data_in_sign_ext <= immediateValue_out_id_reg;
			data_in_usign_ext <= immediateValue_out_id_reg;



			---- instr_mem/ id_reg-----------------
			memread_instr_mem <= '1';
			address_instr_mem <= output_pc;
			pc_in_id_reg <= output_pc;
			--because we simulate little to no delay this if statement is always true
			--if(falling_edge(waitrequest_instr_mem)) then
			--	IF_ID_reg <= 		
			--end if;
			pc_in_id_reg <= output_pc; 
			instruction_in_id_reg <= readdata_instr_mem;
			reg_write_in_id_reg <= reg_id_out_data_mem;


			--id_reg/register_file---------------
			--write_en_reg_file <= '1';
			addr_regA_reg_file <= reg1_out_id_reg;
			addr_regB_reg_file <= reg2_out_id_reg;


			--register_file/ex_alu----------------
			pc_in_ex_alu <= pc_out_id_reg;
			a_ex_alu <= read_regA_reg_file;
			b_ex_alu <= read_regB_reg_file;
			address_in_ex_alu <= address_out_id_reg;
			shift_in_ex_alu <= shamt_out_id_reg;
			signExtendImmediate_ex_alu <= data_out_sign_ext;
			uSignExtendImmediate_ex_alu <= data_out_usign_ext;
			sel_ex_alu <= opCode_out_id_reg;
			funct_ex_alu <= funct_out_id_reg;
			pc_in_ex_alu <= pc_in_id_reg;
			regWrite_in_ex_alu <= reg_write_out_id_reg;

			--ex_alu/data_mem
			ex_ALU_result_in_id_reg <= result_ex_alu;
			reg_id_in_data_mem <= regWrite_out_ex_alu;

			if(mem_ex_alu = '1') then
				if(load_ex_alu = '1') then

					do_load_data_mem <= '1';
					--R[rt] = M[R[rs]+SignExtImm] 
					addr_data_mem <= memAddress_ex_alu; --load

					write_en_reg_file <= '1';
					--store result in register (write back)
					addr_write_reg_file <= regWrite_out_ex_alu; 
					writedata_reg_file <= data_out_data_mem;

				elsif(store_ex_alu = '1') then
				    --M[R[rs]+SignExtImm] = R[rt] 
				    do_write_data_mem <= '1';
					data_in_data_mem <= b_ex_alu;
					addr_data_mem <= memAddress_ex_alu;
				end if;	
			else
				--write back
				--store into the appropriate register the result from alu
				write_en_reg_file <= '1';
				addr_write_reg_file <= reg_write_out_id_reg;
				writedata_reg_file <= ex_ALU_result_out_id_reg;
			end if;

			--hazard detection
			--EN_hazard_dect <= '1';
			--regA_ex_hazard_dect <= reg

		end if;

end process;


end;
