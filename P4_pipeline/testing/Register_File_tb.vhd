LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY register_file_tb IS
END register_file_tb;

ARCHITECTURE arch OF register_file_tb IS

    COMPONENT register_file IS
    	PORT(
    		clk,rst : IN std_ulogic;
		write_en : IN std_ulogic;
    
		writedata : IN std_ulogic_vector(31 DOWNTO 0);
    
		addr_write : IN std_ulogic_vector(4 DOWNTO 0);
		addr_regA : IN std_ulogic_vector(4 DOWNTO 0);
		addr_regB : IN std_ulogic_vector(4 DOWNTO 0);
    
		read_regA : OUT std_ulogic_vector(31 DOWNTO 0);
		read_regB : OUT std_ulogic_vector(31 DOWNTO 0)
    	);
    END COMPONENT;

    SIGNAL clk: STD_LOGIC := '0';
    SIGNAL rst: STD_LOGIC := '0';
    CONSTANT clk_period : time := 1 ns;
    
    SIGNAL addr_regA: STD_LOGIC_VECTOR (4 downto 0);
    SIGNAL addr_regB: STD_LOGIC_VECTOR (4 downto 0);
    SIGNAL addr_write: STD_LOGIC_VECTOR (4 downto 0);
    
    SIGNAL write_en: STD_LOGIC := '0';
    
    SIGNAL writedata: STD_LOGIC_VECTOR (31 downto 0);
    
    SIGNAL read_regA: STD_LOGIC_VECTOR (31 downto 0);
    SIGNAL read_regB: STD_LOGIC_VECTOR (31 downto 0);


BEGIN
    
    rfile: register_file
    
    PORT MAP(
        clk => clk,
        rst => rst,
        
        read_regA => read_regA,
        read_regB => read_regB,
        
        writedata => writedata,
        write_en => write_en,
        
        addr_regA => addr_regA,
        addr_regB => addr_regB,
        addr_write => addr_write
    );

    clock_process : PROCESS
    BEGIN
        clk <= '1';
        wait for clock_period/2;
        clk <= '0';
        wait for clock_period/2;
    END PROCESS;

    test_process : PROCESS
    BEGIN

        wait for clock_period;

        -- test 1 : read reg 0 and do not write
        rst <= '0';
        addr_regA <= "00000";
        addr_regB <= "00000";
        write_en <='0';
        addr_write <= "00001";
        writedata <= "11100000000000000000000000000111";
		
        wait for clock_period;
		
        -- test 2 : read reg0 and write to reg1
        rst <= '0';
        addr_regA <= "00000";
        addr_regB <= "00000";
        write_en <='1';
        addr_write <= "00001";
        writedata <= "11100000000000000000000000000111";
		
        wait for clock_period;
		
        -- test 3: read reg1 and write to reg 4
        rst <= '0';
        addr_regA <= "00001";
        addr_regB <= "00001";
        write_en <='1';
        addr_write <= "00100";
        writedata <= "00000000000000000000000001111000";
		
        wait for clock_period;
		
        -- test 4 : read reg1 and reg4
        rst <= '0';
        addr_regA <= "00001";
        addr_regB <= "00100";
        write_en <='0';
        addr_write <= "00001";
        writedata <= "00000000000000000000000000000111";
		
        wait for clock_period;
		
        -- test 5 : reset
        rst <= '1';
        addr_regA <= "00001";
        addr_regB <= "00100";
        write_en <='0';
        addr_write <= "00001";
        writedata <= "00000000000000000000000000000111";
        
        wait for clock_period;
		
        -- test 6 : read reg1 and reg4 after reset
        rst <= '0';
        addr_regA <= "00001";
        addr_regB <= "00100";
        write_en <='0';
        addr_write <= "00001";
        writedata <= "00000000000000000000000000000111";
        
        WAIT;
    END PROCESS;

END arch;