library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--*----------------------------------------maybe import something

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
	signal default_waitrequest : std_logic := '1';
	type state_type is (default, write_valid, write_invalid, read_valid, read_invalid_dirty);
	signal next_state, current_state: state_type;

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
            		current_state <= S0;
		elsif (rising_edge(clock)) then
		   	current_state <= next_state;
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
							when "00" => rowFound(31 downto 0)  <= s_writedata;
							when "01" => rowFound(63 downto 32)  <= s_writedata;
							when "10" => rowFound(95 downto 64)  <= s_writedata;
							when "11" => rowFound(127 downto 96)  <= s_writedata;
						end case;
						s_waitrequest <= '0'; 	--data is on the bus 

						next_state <= default;

			-- If the block is not in the cache (or invalid), we load from memory
			when write_invalid =>
						--load block from memory, avalon interface + fsm-write
						if(read_state = done) then ---------------------------

							next_state <= write_valid;
						end if;

			when read_valid =>
						-- select the word to be read
						case (s_addr(1 downto 0)) is
							when "00" =>  s_readdata <= rowFound(31 downto 0);  
							when "01" =>  s_readdata <= rowFound(63 downto 32);
							when "10" =>  s_readdata <= rowFound(95 downto 64);
							when "11" =>  s_readdata <= rowFound(127 downto 96);
						end case;

						s_waitrequest <= '0'; 	--data is on the bus 
						next_state <= default;
			when read_invalid =>
						--load block from memory, avalon interface+fsm_read
						if(read_state = done) then ---------------------------

							next_state <= read_valid;
						end if;

			when read_invalid_dirty =>
						--first write to mem the old block then read (which is done in read_invalid state)
						if(write_state = done) then ---------------------------
							next_state <= read_invalid;
						end if;

			end case;
	end process; --end of state_logic fsm-------------------------------------------------------------------


	-- read fsm for the avalon interface
	read_process: process(s_addr, m_waitrequest)

		if(counter = '16') then
			next_state_read <= done_read;
			counter <= '0';		 			 --reset counter
		elsif( m_waitrequest = '0') then
			next_state_read <= reading;
			counter <= counter + 1;
			ram(to_integer(unsigned(s_addr(6 downto 2))))
			ram() <= m_readdata;
		else 
			m_read <= '1';
			m_addr <= to_integer(unsigned(s_addr) + counter);
		end if;

		read_state <= default

	end process; --end of the read_process

						--only up here dont look down

-------------------------------------------------------------------------------------------------------------------------------------

	process: process(clock, s_addr, s_write)
	begin
		if (rising_edge(clock)) then
			if(s_write = '1') then
				--look up the cache 
				rowFound <= ram(to_integer(unsigned(s_addr(6 downto 2))));	-- 5 bits needed to find the correct index in a 4096 bit (word aligned)


				if(rowFound(135 downto 128) = s_addr(14 downto 7)) then	--check if the tag is the same

					if(rowFound(137) = '1') then --ie is the bit valid? (1 = a hit)
						
						-- select the word to be replaced

						rowFound(136) <= '1';	--set the bit to be dirty
						--then update the cache
						ram(to_integer(unsigned(s_addr(6 downto 2)))) <=  rowFound; 	--move this
						
					else 
						--	not valid => miss => go look in memory + get new block (write back the old block if dirty)				

						m_write <= '1';
						m_addr <= to_integer(unsigned(s_addr));
						m_writedata <= s_writedata(31 downto 24);
						-- call write process / state macine stuff wait for memory then do other words



					end if;
				else 
				-- miss go look in memory and get new block
					m_write <= '1';
					m_addr <= to_integer(unsigned(s_addr));
					m_writedata <= s_writedata;
					
					--do the same as before ie call write process 

				end if;

			elsif (s_read = '1') then

				rowFound <= ram(to_integer(unsigned(s_addr(6 downto 2)))); 	-- 5 bits needed to find the correct index of the 32 blocks

				if(rowFound(135 downto 128) = s_addr(14 downto 7)) then

					if(rowFound(137) = '1') then --ie is the bit valid? (1 = a hit)
						
						-- select the word to be read
						case (s_addr(1 downto 0)) is
							when "00" =>  s_readdata <= rowFound(31 downto 0);  
							when "01" =>  s_readdata <= rowFound(63 downto 32);
							when "10" =>  s_readdata <= rowFound(95 downto 64);
							when "11" =>  s_readdata <= rowFound(127 downto 96);
						end case;

						s_waitrequest <= '0'; 	--data is on the bus 
						
					else
						--	not valid => miss => go look in memory	
						--	(if the block to be replaced is dirty, send the old block to a buffer, save the new block and service the read
						--		then write back the correct value in memory.)	

						m_read <= '1';
						m_addr <= to_integer(unsigned(s_addr));
						wait until m_waitrequest = '0';
						s_readdata <= m_readdata;

						--check if bit dirty if so do write then read

					end if;
				else

				--same thing as above


				-- miss go look in memory
					m_read <= '1';
					m_addr <= to_integer(unsigned(s_addr));
					wait until m_waitrequest = '0';
					s_readdata <= m_readdata;
			


				end if;

			end if; -- if (s_write)
		end if; --rising edge
	end process;

	--Setting the default wait request value
	s_waitrequest <= default_waitrequest;

-- make circuits here

end arch;