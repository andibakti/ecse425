library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ex_ALU is
    port(
        clock, rst: in std_logic;
        a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		address_in: in std_logic_vector(25 downto 0);
		offset_in: in std_logic_vector(15 downto 0);
		shift_in: in std_logic_vector(4 downto 0);
		signExtendImmediate: in std_logic_vector(31 downto 0);
    	uSignExtendImmediate: in std_logic_vector(31 downto 0);
		sel: in std_logic_vector(5 downto 0);
		funct: in std_logic_vector(5 downto 0);
		pc_in: in std_logic_vector(31 downto 0);
		regWrite_in: in std_logic_vector(4 downto 0);

        jump: out std_logic;
        mem: out std_logic;
        load: out std_logic;
        store: out std_logic;
        jumpAddress: out std_logic_vector( 31 downto 0);
        memAddress: out std_logic_vector(31 downto 0);
        regWrite_out: out std_logic_vector(4 downto 0);
        result: out std_logic_vector(31 downto 0)
   	);
end entity;

architecture arch of ex_ALU is
--declare signals
signal temp,jA, memAddr: std_logic_vector(31 downto 0);
signal hi, lo: std_logic_vector(31 downto 0);
signal memoryCheck,jumpCheck,storeCheck,loadCheck: std_logic;

begin
    process (clock) begin
        if(rst = '1') then
            temp <= (OTHERS => '0');
        elsif rising_edge(clock) then
            case sel is
				when "000000" =>
					case funct is
						when "100000" =>
							temp <= std_logic_vector(signed(a) + signed(b)); --add
						when "100010" =>
							temp <= std_logic_vector(signed(a) - signed(b));--sub
						when "100100" =>
							temp <= a and b;--and
						when "100111" =>
							temp <= a nor b;--nor
						when "100101" =>
							temp <= a or b;--or
						when "100011" =>
							temp <= a xor b;--xor
						when "000000" =>
							temp <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(shift_in)))); --shift left logical (unsigned)
						when "000010" =>
							temp <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(shift_in)))); --shift right logical
						when "000011" =>
							temp <= std_logic_vector(shift_right(signed(a), to_integer(signed(shift_in)))); --shift right arithmetic (signed)
						when "011010" =>
							lo <= std_logic_vector(signed(a)/signed(b)); --div
							hi <= std_logic_vector(signed(a) mod signed(b)); --div
						when "011000" =>
							temp <= std_logic_vector(signed(a)*signed(b));--mul
						when "010000" =>
							temp <= hi;
						when "010010" =>
							temp <= lo;
						when "001000" => --jump register
							jumpCheck <= '1'; 
							jA <= b;
						when "101010" => --set less than (slt)
							if(signed(a) < signed(b)) then
								temp <= X"00000001";
							else
								temp <= (others => '0');
							end if;
						when others =>
							temp <= (others => '0');
							jumpCheck <= '0';
							memoryCheck <= '0';
							loadCheck <= '0';
							storeCheck <= '0';
					end case;

				when "001000" =>
					temp <= std_logic_vector(signed(a) + signed(signExtendImmediate));--add immediate
				when "001010" => --set less than immediate (slti)
						if(signed(a) < signed(signExtendImmediate)) then
							temp <= X"00000001";
						else
							temp <= (others => '0');
						end if;
				when "001100" =>
					temp <= a and uSignExtendImmediate; --and immediate
				when "001101" =>
					temp <= a or uSignExtendImmediate; --or immediate
				when "001110" =>
					temp <= a xor uSignExtendImmediate; --xor immediate
				when "001111" =>
					temp <= std_logic_vector(shift_left(signed(a),16)); --load upper immediate
				when "000100" =>  --branch on equal (beq)
					if(signed(a) = signed(b)) then
						jumpCheck <= '1';
					else
						jumpCheck <= '0';
					end if;
					jA <= std_logic_vector(signed(offset_in) + signed(pc_in));
				when "000101" => --branch on not equal (beq)
					if(signed(a) = signed(b)) then
						jumpCheck <= '0';
					else
						jumpCheck <= '1';
					end if;
					jA <= std_logic_vector(signed(offset_in) + signed(pc_in));
				when "000010" => --jump
					jumpCheck <= '1'; 
					jA <= address_in;
				when "000011" => --jump and link
					jumpCheck <= '1';
					jA <= address_in;
				when "100011" => --load word (lw)
					memoryCheck <= '1';
					loadCheck <= '1';
					storeCheck <= '0';
					--R[rt] = M[R[rs]+SignExtImm] 
					memAddr <= std_logic_vector(signed(a) + signed(signExtendImmediate));

				when "101011" => --store word (sw)
					memoryCheck <= '1';
					storeCheck <= '1';
					loadCheck <= '0';
					--M[R[rs]+SignExtImm] = R[rt] 
					memAddr <= std_logic_vector(signed(a) + signed(signExtendImmediate)); 
				when others =>
					temp <= (others => '0');
					jumpCheck <= '0';
					memoryCheck <= '0';
					loadCheck <= '0';
					storeCheck <= '0';
			end case;

        end if;
    end process;
result <= temp;
jump <= jumpCheck;
jumpAddress <= jA;
memAddress <= memAddr;
mem <= memoryCheck;
store <= storeCheck;
load <= loadCheck;
regWrite_out <= regWrite_in;

end arch;
