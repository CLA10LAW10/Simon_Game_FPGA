library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rand_gen is
    port (
        clk, rst : in std_logic;                     -- Input clock and reset
        seed     : in std_logic_vector(7 downto 0);  -- Input Seed for initial value
        output   : out std_logic_vector (3 downto 0) -- Output Random generated value
    );
end rand_gen;

architecture Behavioral of rand_gen is

    signal currstate : std_logic_vector (7 downto 0); -- Used to show current state of the shifting registers
    signal nextstate : std_logic_vector (7 downto 0); -- Used to hold the next state of the shifting registers
    signal feedback  : std_logic;                     -- Signal to hold the feedback bit
    signal random    : std_logic_vector (3 downto 0);

begin

    -- Generate a random value WHILE holding the reset button.
    stateReg : process (clk, seed, rst)
        variable seed_check : natural range 0 to 1 := 0; -- Variable to be used if the seed should be checked
    begin
        if rst = '0' and seed_check = 0 then -- Seed while the reset is low
            currstate <= seed;                   -- Seed the current state of registers
            seed_check := 1;                     -- Shift registers have been seeded
        elsif (rising_edge (clk)) then
            currstate <= nextstate;          -- Store shifted registers
            if rst = '1' then                -- Reset button is held down. OUTPUT PSEUDO RANDOM NUMBERS!!
                seed_check := 0;                 -- Seed bit reset
                random <= currstate(7 downto 4); -- Only output while the reset button is held, stop when reset is released
            end if;
        end if;
    end process;

    simon_output : process (random)
    begin
        if (random <= "0011") then
            output <= "0001";
        elsif (random > "0011" and random <= "0111") then
            output <= "0010";
        elsif (random > "0111" and random <= "1100") then
            output <= "0100";
        elsif (random > "1100" and random <= "1111") then
            output <= "1000";
        else
            output <= "0001";
        end if;
    end process;

    feedback  <= currstate(4) xor currstate(3) xor currstate(2) xor currstate(0); -- Jumble bits out to make it random and set the bit to feedback
    nextstate <= feedback & currstate(7 downto 1);                                -- Shift registers

end Behavioral;