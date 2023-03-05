library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity rand_gen_tb is
end rand_gen_tb;

architecture Behavioral of rand_gen_tb is

component rand_gen IS
    PORT (
        clk, rst : IN STD_LOGIC;                    -- Input clock and reset
        seed : IN STD_LOGIC_VECTOR(7 DOWNTO 0);     -- Input Seed for initial value
        output : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)  -- Output Random generated value
    );
END component rand_gen;

signal clk_tb : STD_LOGIC;                          -- Signal simulated clock 
signal rst_tb : STD_LOGIC;                          -- Signal simulated reset button
signal seed_tb : STD_LOGIC_VECTOR (7 DOWNTO 0);     -- Signal simulated seed value
signal output_tb : STD_LOGIC_VECTOR (3 DOWNTO 0);   -- Signal simulated output

constant CP : time := 10ns;

begin

-- Instantiate the unit under test
uut : rand_gen 
    port map (
        clk => clk_tb,
        rst => rst_tb,
        seed => seed_tb,
        output => output_tb
    );

    -- Clock generation process
    clk_gen : PROCESS
    BEGIN
        clk_tb <= '0';
        WAIT FOR CP/2;
        clk_tb <= '1';
        WAIT FOR CP/2;
    END PROCESS;

   -- Input vector
    input_gen : process
    BEGIN

        wait for CP; -- Observe the unknown
        seed_tb <= "01001111"; -- Seed the module
        wait for CP;

        -- Reset the module and let it generate random numbers
        rst_tb <= '0';
        wait for 5 * CP;
        rst_tb <= '1';
        wait for 5 * CP;

        -- Wait to observe a single value is help when reset is low.
        -- No more generating
        rst_tb <= '0';
        wait for 5 * CP;

        -- Reset again to observe the random generation
        -- Until once again held low to see the generated output
        rst_tb <= '1';
        wait for 3 * CP;
        rst_tb <= '0';
        wait for 7 * CP;
        stop;
    end process;

end Behavioral;