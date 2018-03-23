library IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY registerfile IS

	PORT (
	clk,rst : IN std_logic;
	write_en : IN std_logic;
    
	writedata : IN std_logic_vector(31 DOWNTO 0);
    
	addr_write : IN std_logic_vector(4 DOWNTO 0);
	addr_regA : IN std_logic_vector(4 DOWNTO 0);
	addr_regB : IN std_logic_vector(4 DOWNTO 0);
    
	read_regA : OUT std_logic_vector(31 DOWNTO 0);
	read_regB : OUT std_logic_vector(31 DOWNTO 0)
	);
    
END registerfile;


ARCHITECTURE arch OF registerfile IS 
	
	TYPE registers IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL register_file: registers := (OTHERS => "00000000000000000000000000000000"); --initialize all entries of the array
	
BEGIN

	PROCESS (clk)
	BEGIN
	
    	IF (rst = '1') THEN
        	
        	FOR i IN 0 TO 31 LOOP
			register_file(i) <= "00000000000000000000000000000000";
		END LOOP;
        	
        ELSIF (rising_edge(clk)) THEN
	
		IF (write_en = '1') THEN
			register_file(to_integer(unsigned(addr_write))) <= writedata;
		END IF;
		
		read_regA <= register_file(to_integer(unsigned(addr_regA)));
		read_regB <= register_file(to_integer(unsigned(addr_regB)));
		
	END IF;
	END PROCESS;
    
END arch;

