LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY data_memory_tb IS
END data_memory_tb;

ARCHITECTURE arch OF data_memory_tb IS

    COMPONENT data_memory IS
	generic(
		ram_size : integer := 32768
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
    END COMPONENT;

    SIGNAL clk: STD_LOGIC := '0';
    CONSTANT clk_period : time := 1 ns;
    
	SIGNAL data_in: std_logic_vector(31 downto 0):=(others => '0');
	SIGNAL do_load: std_logic := '0';
	SIGNAL do_write: std_logic := '0';
	SIGNAL writeMem: std_logic := '0';
	SIGNAL reg_id_in: std_logic_vector(4 downto 0);
	SIGNAL addr: std_logic_vector(31 downto 0);
	SIGNAL data_out: std_logic_vector(31 downto 0);
	SIGNAL reg_id_out: std_logic_vector(4 downto 0);


BEGIN
    
	
	--dut => Device Under Test
    dut: data_memory
	GENERIC MAP( ram_size => 15  )
    PORT MAP( 
        clk,
        data_in,
        do_load,
        do_write,
		writeMem,
        reg_id_in,
		addr


    );

    clock_process : PROCESS
    BEGIN
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    END PROCESS;

    test_process : PROCESS
    BEGIN

		-- test 2 : read reg0 and write to reg1
        wait for clk_period;
        data_in <= "00000000000000000000000000000001";
        do_load <= '0';
        do_write <='0';
        writeMem <= '0';
		addr <= "00000000000000000000000000000001";
        reg_id_in <= "00000";
		
		-- test 2 : read reg0 and write to reg1
		wait for clk_period;
        data_in <= "00000000000000000000000000000001";
        do_load <= '0';
        do_write <='0';
        writeMem <= '0';
		addr <= "00000000000000000000000000000001";
        reg_id_in <= "00001";
        
        WAIT;
    END PROCESS;

END arch;