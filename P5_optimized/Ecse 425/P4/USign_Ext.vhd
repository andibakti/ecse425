LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY usignext IS
    PORT (
        data_in: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        data_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END usignext;

ARCHITECTURE arch OF usignext IS

BEGIN
process (data_in)
begin
	data_out(31 downto 16) <= "0000000000000000";
	data_out(15 downto 0) <= data_in;
end process;
END arch;
