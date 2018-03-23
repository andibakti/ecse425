library IEEE;
use IEEE.std_logic_1164.all;

ENTITY registerfile IS

	PORT (
    clk,rst : IN std_ulogic;
	write_en : IN std_ulogic;
    
	writedata : IN std_ulogic_vector(31 DOWNTO 0);
    
	addr_write : IN std_ulogic_vector(4 DOWNTO 0);
	addr_regA : IN std_ulogic_vector(4 DOWNTO 0);
	addr_regB : IN std_ulogic_vector(4 DOWNTO 0);
    
	read_regA : OUT std_ulogic_vector(31 DOWNTO 0);
	read_regB : OUT std_ulogic_vector(31 DOWNTO 0)
	);
    
END regfile;


ARCHITECTURE arch OF registerfile IS 
	
    TYPE registers IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL register_file: registers := (OTHERS => "00000000000000000000000000000000"); --initialize all entries of the array

BEGIN
    
	PROCESS (clk)
	BEGIN
    
    	IF (rst = '1') THEN
        	
            register_file := (OTHERS => "00000000000000000000000000000000");
    
		ELSIF (rising_edge(clk)) THEN
        	    
            ELSIF (write_en = '1') THEN
				register_file(to_integer(unsigned(addr_write))) <= rd_data;
			END IF;
            
            
			read_regA <= register_store(to_integer(unsigned(addr_regA)));
			read_regB <= register_store(to_integer(unsigned(addr_regB)));
            
		END IF;
	END PROCESS;
    
END arch;

