library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_reg is 
	port(
		clock: in std_logic;
		pc_in: in std_logic_vector(31 downto 0);
		instruction_in: in std_logic_vector(31 downto 0);


		pc_out: out std_logic_vector(31 downto 0);
		instruction_out: out std_logic_vector(31 downto 0);
		reg1_out: out std_logic_vector(31 downto 0);
		reg2_out: out std_logic_vector(31 downto 0)
		);

end id_reg;

architecture arch of id_reg is


begin



end arch;
