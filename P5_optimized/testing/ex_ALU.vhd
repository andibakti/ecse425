library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ex_ALU is
    port(
        clock, rst: in std_logic;
        a: in std_logic_vector(31 downto 0);
	b: in std_logic_vector(31 downto 0);
	signExtendImmediate: in std_logic_vector(15 downto 0);
	sel: in std_logic_vector(5 downto 0);
	funct: in std_logic_vector(5 downto 0);
	
        zero: out std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end entity;

architecture arch of ex_ALU is
--declare signals
signal temp : std_logic_vector(31 downto 0);
signal temp2 : std_logic_vector(63 downto 0);
signal hi, lo: std_logic_vector(31 downto 0);
signal stall : std_logic;
signal zeroExtendImmediate: std_logic_vector(31 downto 0);


begin
    process (clock) begin
        if(rst = '1') then
            temp <= (OTHERS => '0');
        elsif rising_edge(clock) then
	    zeroExtendImmediate <= "0000000000000000" & signExtendImmediate;
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
							temp <= std_logic_vector(shift_left(unsigned(a), to_integer(signed(b)))); --shift left logical (unsigned)
						when "000010" =>
							temp <= std_logic_vector(shift_right(unsigned(a), to_integer(signed(b)))); --shift right logical
						when "000011" =>
							temp <= std_logic_vector(shift_right(signed(a), to_integer(signed(b)))); --shift right arithmetic (signed)
						when "011010" =>
							lo <= std_logic_vector(signed(a)/signed(b)); --div
							hi <= std_logic_vector(signed(a) mod signed(b)); --div
						when "011000" =>
							temp2 <= std_logic_vector(signed(a) * signed(b));--mul
							hi <= temp2(63 downto 32);
							lo <= temp2(31 downto 0);
						when "010000" =>
							temp <= hi;
						when "010010" =>
							temp <= lo;
						when "101010" => --set less than (slt)
							if(signed(a) < signed(b)) then
								temp <= X"00000001";
							else
								temp <= (others => '0');
							end if;
						when others =>
							temp <= (others => '0');
							-- stall
							stall <= '1';
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
					temp <= a and zeroExtendImmediate; --and immediate
				when "001101" => 
					temp <= a or zeroExtendImmediate; --or immediate
				when "001110" => 
					temp <= a xor zeroExtendImmediate; --xor immediate
				when "001111" => 
					temp <= std_logic_vector(shift_left(signed(a),16)); --load upper immediate
				when others => 
					temp <= (others => '0');
					-- stall
					stall <= '1';

				--when "????" =>  --branch on equal (beq)
				--		if(signed(a) = signed(b)) then
				--			temp <= ;
				--		else
				--			temp <= ;
				--		end if;
				--when "????" => temp <= ???? --branch on not equal (beq)
				--when "????" => temp <= ???? --jump
				--when "????" => temp <= ???? --jump register
				--when "????" => temp <= ???? --jump and link

				--when "????" => temp <= ???? --load word (lw)
				--when "????" => temp <= ???? --store word (sw)

			end case;

        end if;
    end process;
output <= temp;
zero <= stall;

end arch;
