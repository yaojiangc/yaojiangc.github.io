-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- entity
entity generate_ppm is
port (	gen_reg0 : in std_logic_vector(31 downto 0);
		--counter : in std_logic_vector(31 downto 0); -- UNCOMMENT TO GET IT WORK IN AXI_PPM
		gen_reg1, gen_reg2, gen_reg3, gen_reg4, gen_reg5, gen_reg6 : in std_logic_vector(31 downto 0);
		CLK,CLR : in std_logic;
		ppm_out : out std_logic);
end generate_ppm;

-- architecture
architecture generate_ppm1 of generate_ppm is
	type state_type is (Idle,L1,L2,L3,L4,L5,L6,L7,CH1,CH2,CH3,CH4,CH5,CH6);
	signal PS,NS : state_type;
	signal counter : std_logic_vector(31 downto 0); -- for debug purpose, COMMENT THIS LINE WHEN USE
begin
	sync_proc: process(CLK,NS,CLR) 
	begin
		-- take care of the asynchronous input
		if (CLR = '1') then
			PS <= Idle;	
			counter <= (others=>'0');
		elsif (rising_edge(CLK)) then
			PS <= NS;
			if(counter <= 2000000) then
				counter <= counter + 1;
			else 
				counter <= (others => '0');
			end if;
		end if;
	end process sync_proc;
			
	comb_proc: process(PS,counter) 
	begin
		ppm_out <= '0';
		case PS is
			when Idle => 
				if (counter = 0) then NS <= L1;
				else
					 NS <= Idle;
					 ppm_out <= '1';
				end if;
				if (counter = 2000000) then
					---debug--counter <= (others=>'0');
				end if;

			
			when L1 => 
				if (counter = 40000) then NS <= CH1; 
				else NS <= L1; ppm_out <= '0';
				end if;
				
			when CH1 => 
				if (counter = (40000+gen_reg1)) then NS <= L2;
				else NS <= CH1; ppm_out <= '1';
				end if;

			when L2 => 
				if (counter = (80000+gen_reg1)) then NS <= CH2;
				else NS <= L2; ppm_out <= '0';
				end if;

			when CH2 => 
				if (counter = (80000+gen_reg1+gen_reg2)) then NS <= L3;
				else NS <= CH2; ppm_out <= '1';
				end if;

			when L3 => 
				if (counter = (120000+gen_reg1+gen_reg2)) then NS <= CH3;
				else NS <= L3; ppm_out <= '0';
				end if;

			when CH3 => 
				if (counter = (120000+gen_reg1+gen_reg2+gen_reg3)) then NS <= L4;
				else NS <= CH3; ppm_out <= '1';
				end if;

			when L4 => 
				if (counter = (160000+gen_reg1+gen_reg2+gen_reg3)) then NS <= CH4;			
				else NS <= L4; ppm_out <= '0';
				end if;

			when CH4 => 
				if (counter = (160000+gen_reg1+gen_reg2+gen_reg3+gen_reg4)) then NS <= L5;	
				else NS <= CH4; ppm_out <= '1';
				end if;

			when L5 => 
				if (counter = (200000+gen_reg1+gen_reg2+gen_reg3+gen_reg4)) then NS <= CH5;
				else NS <= L5; ppm_out <= '0';
				end if;

			when CH5 => 
				if (counter = (200000+gen_reg1+gen_reg2+gen_reg3+gen_reg4+gen_reg5)) then NS <= L6;	
				else NS <= CH5; ppm_out <= '1';
				end if;

			when L6 => 
				if (counter = (240000+gen_reg1+gen_reg2+gen_reg3+gen_reg4+gen_reg5)) then NS <= CH6;
				else NS <= L6; ppm_out <= '0';
				end if;

			when CH6 => 
				if (counter = (240000+gen_reg1+gen_reg2+gen_reg3+gen_reg4+gen_reg5+gen_reg6)) then NS <= L7;
				else NS <= CH6; ppm_out <= '1';
				end if;

			when L7 => 
				if (counter = (280000+gen_reg1+gen_reg2+gen_reg3+gen_reg4+gen_reg5+gen_reg6)) then NS <= Idle;
				else NS <= L7; ppm_out <= '0';
				end if;				
			
			when others => -- the catch-all condition
				NS <= Idle; -- make it to these two statements
		end case;
	end process comb_proc;
end generate_ppm1;