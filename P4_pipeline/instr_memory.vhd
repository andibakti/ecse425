--adapted from example 12-15 of quartus design and synthesis handbook
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity instr_memory is
	generic(
		ram_size : integer := 32768;
		mem_delay : time := 0 ns;
		clock_period : time := 1 ns
	);
	port (
		clock: in std_logic;
		writedata: in std_logic_vector (31 downto 0);
		address: in std_logic_vector (31 downto 0);
		memwrite: in std_logic;
		memread: in std_logic;
		readdata: out std_logic_vector (31 downto 0);
		waitrequest: out std_logic
	);
end instr_memory;

architecture rtl of instr_memory is
	type mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal ram_block: mem;
	signal read_address_reg: integer range 0 to ram_size-1;
	signal write_waitreq_reg: std_logic := '1';
	signal read_waitreq_reg: std_logic := '1';
begin
	--this is the main section of the sram model
	mem_process: process (clock)
		file program_file : text;
		variable x_line	: line;
		variable x: std_logic_vector(31 downto 0);
		variable file_status : file_open_status;
		variable i: integer:= 0;
		--variable x_in	: std_logic_vector(31 downto 0);
	begin
		--this is a cheap trick to initialize the sram in simulation
		if(now < 1 ps) then
			for j in 0 to ram_size-1 loop
				ram_block(j) <= std_logic_vector(to_unsigned(j,32));
			end loop;

			file_open(program_file, "program.txt", read_mode);

			i := 0;

			while not endfile(program_file) loop
				readline(program_file, x_line);
				read(x_line, x);
				ram_block(i) <= x;
				i := i + 1;
			end loop;
			file_close(program_file);
		end if;

		--this is the actual synthesizable sram block
		if (clock'event and clock = '1') then
			if (memwrite = '1') then
				ram_block(to_integer(unsigned(address))) <= writedata;
			end if;
		read_address_reg <= to_integer(unsigned(address));
		end if;
	end process;
	readdata <= ram_block(read_address_reg);


	--the waitrequest signal is used to vary response time in simulation
	--read and write should never happen at the same time.
	waitreq_w_proc: process (memwrite)
	begin
		if(memwrite'event and memwrite = '1')then
			write_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;

		end if;
	end process;

	waitreq_r_proc: process (memread)
	begin
		if(memread'event and memread = '1')then
			read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		end if;
	end process;
	waitrequest <= write_waitreq_reg and read_waitreq_reg;


end rtl;
