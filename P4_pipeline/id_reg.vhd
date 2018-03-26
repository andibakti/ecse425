library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_reg is 
	port(
		clock,rst:	in std_logic;
		pc_in: 		in std_logic_vector(31 downto 0);
		instruction_in: in std_logic_vector(31 downto 0);

		pc_out: 	out std_logic_vector(31 downto 0);
		instruction_out: out std_logic_vector(31 downto 0)
		);

end id_reg;

architecture arch of id_reg is


begin
    process(clock,rst)
	begin

	if rst = '1' then --reset all outputs
		pc_out <= (others=> '0');
		instruction_out <= (others=> '0');
	elsif rising_edge(clock) then --assign
		pc_out <= pc_in;
		instruction_out <= instruction_in;
	end if;
    end process;
end arch;
