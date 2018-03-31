-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
-- CREATED		"Mon Mar 26 11:25:43 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY P4 IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		writeMem :  IN  STD_LOGIC;
		Reset :  IN  STD_LOGIC
	);
END P4;

ARCHITECTURE bdf_type OF P4 IS 

COMPONENT signext
	PORT(data_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT usignext
	PORT(data_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 write_en : IN STD_LOGIC;
		 addr_regA : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 addr_regB : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 addr_write : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 writedata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 read_regA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 read_regB : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux_2to1
	PORT(SEL : IN STD_LOGIC;
		 A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 X : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc
	PORT(clock : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 input : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_adder
	PORT(override : IN STD_LOGIC;
		 override_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT data_memory
GENERIC (ram_size : INTEGER
			);
	PORT(clock : IN STD_LOGIC;
		 writeMem : IN STD_LOGIC;
		 ALU_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 WB_buffer_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 WB_buffer_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT id_reg
	PORT(clock : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 instruction_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 address_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
		 funct_out : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 immediateValue_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 opCode_out : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 reg1_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 reg2_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 shamt_out : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END COMPONENT;

COMPONENT instr_memory
GENERIC (clock_period : STRING;
			mem_delay : STRING;
			ram_size : INTEGER
			);
	PORT(clock : IN STD_LOGIC;
		 memwrite : IN STD_LOGIC;
		 memread : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 writedata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 waitrequest : OUT STD_LOGIC;
		 readdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ex_alu
	PORT(clock : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 sel : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 signExtendImmediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 uSignExtendImmediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	instruction_out :  STD_LOGIC_VECTOR(31 DOWNTO 26);
SIGNAL	PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	readdata :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 



b2v_inst : signext
PORT MAP(data_in => SYNTHESIZED_WIRE_14,
		 data_out => SYNTHESIZED_WIRE_12);


b2v_inst1 : usignext
PORT MAP(data_in => SYNTHESIZED_WIRE_14,
		 data_out => SYNTHESIZED_WIRE_13);


b2v_inst10 : register_file
PORT MAP(clk => CLK,
		 rst => Reset,
		 addr_regA => SYNTHESIZED_WIRE_2,
		 addr_regB => SYNTHESIZED_WIRE_3,
		 read_regA => SYNTHESIZED_WIRE_9,
		 read_regB => SYNTHESIZED_WIRE_10);


b2v_inst2 : mux_2to1
PORT MAP(A => SYNTHESIZED_WIRE_15,
		 X => SYNTHESIZED_WIRE_7);


b2v_inst3 : pc
PORT MAP(clock => CLK,
		 reset => Reset,
		 input => SYNTHESIZED_WIRE_5,
		 output => PC);


b2v_inst4 : pc_adder
PORT MAP(override => SYNTHESIZED_WIRE_6,
		 override_pc => SYNTHESIZED_WIRE_7,
		 pc => PC,
		 output => SYNTHESIZED_WIRE_5);


b2v_inst5 : data_memory
GENERIC MAP(ram_size => 32768
			)
PORT MAP(clock => CLK,
		 writeMem => writeMem,
		 ALU_in => SYNTHESIZED_WIRE_15,
		 opcode => instruction_out);


b2v_inst7 : id_reg
PORT MAP(instruction_in => readdata,
		 pc_in => PC,
		 funct_out => SYNTHESIZED_WIRE_11,
		 immediateValue_out => SYNTHESIZED_WIRE_14,
		 reg1_out => SYNTHESIZED_WIRE_2,
		 reg2_out => SYNTHESIZED_WIRE_3);


b2v_inst8 : instr_memory
GENERIC MAP(clock_period => 1000000 fs,
			mem_delay =>  fs,
			ram_size => 32768
			)
PORT MAP(clock => CLK,
		 memread => writeMem,
		 address => PC,
		 readdata => readdata);


b2v_inst9 : ex_alu
PORT MAP(clock => CLK,
		 rst => Reset,
		 a => SYNTHESIZED_WIRE_9,
		 b => SYNTHESIZED_WIRE_10,
		 funct => SYNTHESIZED_WIRE_11,
		 sel => instruction_out,
		 signExtendImmediate => SYNTHESIZED_WIRE_12,
		 uSignExtendImmediate => SYNTHESIZED_WIRE_13,
		 zero => SYNTHESIZED_WIRE_6,
		 output => SYNTHESIZED_WIRE_15);


END bdf_type;