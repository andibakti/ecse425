library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;

	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_write : in std_logic;
	s_waitrequest : out std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_writedata : in std_logic_vector (31 downto 0);


    --	Connected with memory
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

-- declare signals here
	type mem_array is array(32-1 downto 0) of std_logic_vector(137 downto 0);
	signal ram: mem_array;
	signal rowFound : std_logic_vector(137 downto 0);
	type state_type is (init, default, write_valid, write_invalid, read_valid, read_invalid, read_invalid_dirty);
	signal next_state, current_state: state_type := init;


	signal row : std_logic_vector(137 downto 0);
	signal r_counter,  w_counter : integer;

	type read_state_type is (default, reading, done_read);
	signal next_state_read, read_state: read_state_type := default;

	type write_state_type is (default, writing, done_write);
	signal next_state_write, write_state: write_state_type := default;
	--bit table
	----------------------------------------------------------------------
	--|137 Valid | 136 Dirty | 135   Tag   128 | 127     Block Data     0 |
	----------------------------------------------------------------------


	-- How data is stored (Big Endian)
	-- Word table stored in data block
	------------------------------------------
	--| 127   96 | 95   64 | 65   32 | 31   0 |
	------------------------------------------


begin

	--go to next state at rising edge
	--asynchronous reset
	states: process (clock, reset)
	begin
		if (reset = '1') then
            current_state <= init;
		elsif (rising_edge(clock)) then
		   	current_state <= next_state;
			read_state <= next_state_read;
		end if;
	end process;

	--
	--
	state_logic: process(current_state, s_addr, s_read, s_write)
	begin
		case current_state is

			--	In default we check if there is a read, write, or nothing.
			-- 	Depending on this input and if all the conditions match
			--	then we determine the correct next state.
			when init =>
				for i in 0 to 31 loop
					ram(i)(137) <= '0';
				end loop;
			when default =>	--do all checks

						s_waitrequest <= '1'; 	--waiting for requests

							rowFound <= ram(to_integer(unsigned(s_addr(6 downto 2))));	-- 5 bits needed to find the correct index in a 4096 bit (word aligned)

							if(s_write = '1') then

								--go to write state
								if(rowFound(135 downto 128) = s_addr(14 downto 7)) then	--check if the tag is the same
									if(rowFound(137) = '1') then --ie is the bit valid? (1 = a hit)
										next_state <= write_valid;
									else
										next_state <= write_invalid;
									end if;
								else
									next_state <= write_invalid;
								end if;

							elsif(s_read = '1') then
								if(rowFound(137) = '1') then --ie is the bit valid? (1 = a hit)
									if(rowFound(135 downto 128) = s_addr(14 downto 7)) then	--check if the tag is the same
										next_state <= read_valid;
									else
										if(rowFound(135) = '1') then --ie is the bit dirty
											next_state <= read_invalid_dirty;
										else
											next_state <= read_invalid;
										end if;
									end if;
								else
									next_state <= read_invalid;

								end if;
							end if;

			--	If the block is found and valid we write to the correct word and
			--	set the wait request to be '0'.
			--
			when write_valid =>
						case (s_addr(1 downto 0)) is
							when "00"   => rowFound(31 downto 0)    <= s_writedata;
							when "01"   => rowFound(63 downto 32)   <= s_writedata;
							when "10"   => rowFound(95 downto 64)   <= s_writedata;
							when others => rowFound(127 downto 96)  <= s_writedata;
						end case;
						s_waitrequest <= '0'; 	--data is on the bus

						next_state <= default;

			-- If the block is not in the cache (or invalid), we load from memory
			when write_invalid =>
						--load block from memory, avalon interface + fsm-write
						if(read_state = done_read) then ---------------------------

							next_state <= write_valid;
						end if;

			when read_valid =>
						-- select the word to be read
						case (s_addr(1 downto 0)) is
							when "00"   =>  s_readdata <= rowFound(31 downto 0);
							when "01"   =>  s_readdata <= rowFound(63 downto 32);
							when "10"   =>  s_readdata <= rowFound(95 downto 64);
							when others =>  s_readdata <= rowFound(127 downto 96);
						end case;

						s_waitrequest <= '0'; 	--data is on the bus
						next_state <= default;
			when read_invalid =>
						if(read_state = done_read) then ---------------------------

							next_state <= read_valid;
						end if;

			when read_invalid_dirty =>
						--first write to mem the old block then read (which is done in read_invalid state)
						if(write_state = done_write) then ---------------------------
							next_state <= read_invalid;
						end if;

			end case;
	end process; --end of state_logic fsm-------------------------------------------------------------------


	-- read fsm for the avalon interface
	read_process: process(s_addr, m_waitrequest)
	begin
		case read_state is
			when default =>
				if (current_state = write_invalid OR current_state = read_invalid) then
					next_state_read <= reading;
				end if;
			 -- Do nothing
			when reading =>
				row <= ram(to_integer(unsigned(s_addr(6 downto 2))));
				if(r_counter = 16) then
					row(137) <= '1'; -- Valid
					row(136) <= '0'; -- Not dirty
					row(135 downto 128) <= s_addr(14 downto 7); -- Tag
					ram(to_integer(unsigned(s_addr(6 downto 2)))) <= row;
					next_state_read <= done_read;
					r_counter <= 0;		 			 --reset r_counter
				elsif( m_waitrequest = '0') then
					next_state_read <= reading;
					r_counter <= r_counter + 1;
					row(8*(10 + r_counter) downto 8*(10 + r_counter - 1)) <= m_readdata; -- 10 is the data offset in the block
				else
					m_read <= '1';

				end if;

			when done_read =>
				next_state_read <= default;
			end case;
	end process; --end of the read_process

	-- write fsm for the avalon interface
	write_process: process(s_addr, m_waitrequest)
	begin
		case write_state is
			when default =>
				if (current_state = write_invalid OR current_state = read_invalid_dirty) then
					next_state_write <= writing;
				end if;
			 -- Do nothing
			when writing =>
				if(w_counter = 16) then
					next_state_write <= done_write;
					w_counter <= 0;		 			 --reset counter
				elsif( m_waitrequest = '0') then
					next_state_write <= writing;
					w_counter <= w_counter + 1;
				else
					m_write <= '1';
					m_writedata <= rowFound(8*(10 + w_counter) downto 8*(10 + w_counter - 1));
				end if;

			when done_write =>
				next_state_write <= default;
			end case;
	end process; --end of the write_process

	m_addr <= to_integer(unsigned(s_addr(14 downto 0)) + w_counter + r_counter);


end arch;
