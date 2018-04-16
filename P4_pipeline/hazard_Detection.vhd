library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection is
    port ( clk : in  std_logic
         ; reg_write_id_reg : in   std_logic_vector (4 downto 0)
         ; reg_write_alu : in   std_logic_vector (4 downto 0)
         ; reg_write_mem : in   std_logic_vector (4 downto 0)
         ; instr : in   std_logic_vector (31 downto 0)
         ; hazOut : out  std_logic
        );
end hazard_detection;

architecture arch of hazard_detection is

begin

  process (clk)
  begin
    if(rising_edge(clk)) then
      if (reg_write_id_reg /= "00000" AND ((reg_write_id_reg = instr(15 downto 11)) OR (reg_write_id_reg = instr(20 downto 16)))) then
      --HAZARD DETECTED
          hazOut <= '1';

  	  elsif (reg_write_alu /= "00000" AND ((reg_write_alu = instr(15 downto 11)) OR (reg_write_alu = instr(20 downto 16)))) then
  		--HAZARD DETECTED
          hazOut <= '1';

      elsif (reg_write_mem /= "00000" AND ((reg_write_mem = instr(15 downto 11)) OR (reg_write_mem = instr(20 downto 16)))) then
          --HAZARD DETECTED
          hazOut <= '1';

      else
          hazOut <= '0';
      end if;
    end if;
  end process;

end arch;

