--adapted from example 12-15 of quartus design and synthesis handbook
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity data_memory is
	generic(
		ram_size : integer := 8192
	);
	port (
		clock: in std_logic;
		data_in: in std_logic_vector(31 downto 0):=(others => '0');
		do_load: in std_logic := '0';
		do_write: in std_logic := '0';
		writeMem: in std_logic;
		reg_id_in: in std_logic_vector(4 downto 0);
		addr: in std_logic_vector(31 downto 0);
		data_out: out std_logic_vector(31 downto 0);
		reg_id_out: out std_logic_vector(4 downto 0)
		--mem_data: out std_logic_vector(31 downto 0);
	);
end data_memory;

architecture rtl of data_memory is

type MEM is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
signal ram_block: MEM;

begin
	--this is the main section of the sram model
	mem_process: process (clock)
	begin
		--this is a cheap trick to initialize the sram in simulation
		if(now < 1 ps)then
			for i in 0 to ram_size-1 loop
				ram_block(i) <= std_logic_vector(to_signed(0,32));
			end loop;
		end if;


		if rising_edge(clock) then
			--sw
			if(do_write = '1') then
				ram_block(to_integer(unsigned(addr))) <= data_in;
				data_out <= data_in;
			--lw
			elsif(do_load = '1') then
				data_out <= ram_block(to_integer(unsigned(addr)));
			else
				data_out <= data_in;
			end if;

			reg_id_out <= reg_id_in;
		end if;

	end process;

	write_file: process(writeMem)
		--file memory_file : text open write_mode is "memory.txt";
		file memory_file : text;
		variable line_num: line;
		variable file_status : file_open_status;
		variable reg_value : std_logic_vector(31 downto 0);

		variable ram_size : integer := 32768;
		variable endLoop : integer;

		begin

		--size
		endLoop := ram_size/4;

		if (writeMem = '1') then
			file_open(memory_file, "memory.txt", write_mode);

			for i in 1 to endLoop loop
				for j in 1 to 4 loop
					--ex j = 1 : 7 downto 0
					reg_value(8*j-1 downto 8*j-8) := ram_block(i*4 + j-5);
				end loop;
				write(line_num, reg_value);
				writeline(memory_file, line_num);
			end loop;
			file_close(memory_file);
		end if;
	end process;

end rtl;
