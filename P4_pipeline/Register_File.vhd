library IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

ENTITY Register_File IS

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

END Register_File;


ARCHITECTURE arch OF Register_File IS

	TYPE registers IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL register_file: registers := (
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000"
    );


BEGIN

	register_process: PROCESS (clk)
	BEGIN

    	IF (rst = '1') THEN

        	FOR i IN 0 TO 31 LOOP
				register_file(i) <= "00000000000000000000000000000000";
			END LOOP;

            read_regA <= "00000000000000000000000000000000";
            read_regB <= "00000000000000000000000000000000";

        ELSIF (rising_edge(clk)) THEN

			IF (write_en = '1') THEN
                if(addr_write = "00000" OR addr_write = "UUUUU") then
                    read_regA <= register_file(to_integer(unsigned(addr_regA)));
                    read_regB <= register_file(to_integer(unsigned(addr_regB)));
                else
				    register_file(to_integer(unsigned(addr_write))) <= writedata;

                    if(addr_regA = addr_write) then
                        read_regA <= writedata;
                    end if;

                    if(addr_regB = addr_write) then
                        read_regB <= writedata;
                    end if;

                end if;
            else
                read_regA <= register_file(to_integer(unsigned(addr_regA)));
                read_regB <= register_file(to_integer(unsigned(addr_regB)));
			END IF;




		END IF;
	END PROCESS;

    -- this process writes the contents of the registers to an output text file
    write_file : process(clk)
        file reg_file : text;
        variable line_num: line;
        variable file_status : file_open_status;
        variable reg_value : std_logic_vector(31 downto 0);

        begin

        if(write_en = '1') then
            file_open(file_status,reg_file, "register_file.txt", write_mode);

            for i in 0 to 31 loop
                write(line_num, register_file(i));
                writeline(reg_file, line_num);
            end loop;
            file_close(reg_file);
        end if;

    end process;

END arch;
