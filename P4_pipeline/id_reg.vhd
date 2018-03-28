library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_reg is
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
		reg_write_out: in std_logic_vector(4 downto 0);
		pc_out: out std_logic_vector(31 downto 0);
		);

end id_reg;

architecture arch of id_reg is


begin
    process(clock,rst)

	begin

	if rst = '1' then --reset all outputs
		pc_out <= (others=> '0');
		opCode_out <= (others=> '0');
		reg1_out <= (others=> '0');
		reg2_out <= (others=> '0');
		address_out <= (others=> '0');
		immediateValue_out <= (others=> '0');
		shamt_out <= (others=> '0');
		funct_out <= (others=> '0');
		reg_write_out <= (others=> '0');
		pc_out <= (others => '0');
	elsif rising_edge(clock) then --assign

		if(instruction_in(25 downto 21) = reg_write_in OR instruction_in(20 downto 16) = reg_write_in) then
			-- STALL
			opCode_out <= "000000";
			reg1_out <= "00000";
			reg2_out <= "00000";
			reg_write_out <= "00000";
			func_out <= "100000";

		else
			opCode_out <= instruction_in(31 downto 26);
			reg1_out <= instruction_in(25 downto 21);
			reg2_out <= instruction_in(20 downto 16);
			address_out <= instruction_in(25 downto 0);
			immediateValue_out <= instruction_in(15 downto 0);
			shamt_out <= instruction_in(11 downto 6);
			funct_out <= instruction_in(5 downto 0);
			pc_out <= pc_in;
			reg_write_out <= reg_write_in;

		end if;
	end if;
    end process;
end arch;
