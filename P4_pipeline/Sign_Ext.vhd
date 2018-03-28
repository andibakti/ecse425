LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY signext IS
    PORT (
        data_in: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        data_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END signext;

ARCHITECTURE arch OF signext IS

BEGIN
process (data_in)
begin
	if data_in(15) = '1' then
		data_out(31 downto 15) <= "10000000000000000";
	else
		data_out(31 downto 15) <= "00000000000000000";
	end if;
	data_out(14 downto 0) <= data_in(14 downto 0);
end process;
END arch;
