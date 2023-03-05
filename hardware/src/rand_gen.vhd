LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rand_gen IS
    PORT (
        clk, rst : IN STD_LOGIC;                    -- Input clock and reset
        seed : IN STD_LOGIC_VECTOR(7 DOWNTO 0);     -- Input Seed for initial value
        output : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)  -- Output Random generated value
    );
END rand_gen;

ARCHITECTURE Behavioral OF rand_gen IS

    SIGNAL currstate : STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Used to show current state of the shifting registers
    SIGNAL nextstate : STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Used to hold the next state of the shifting registers
    SIGNAL feedback : STD_LOGIC;                        -- Signal to hold the feedback bit

BEGIN

    -- Generate a random value WHILE holding the reset button.
    stateReg : PROCESS (clk, seed, rst)
        VARIABLE seed_check : NATURAL RANGE 0 TO 1 := 0; -- Variable to be used if the seed should be checked
    BEGIN
        IF rst = '0' AND seed_check = 0 THEN        -- Seed while the reset is low
            currstate <= seed;                      -- Seed the current state of registers
            seed_check := 1;                        -- Shift registers have been seeded
        ELSIF (rising_edge (clk)) THEN
            currstate <= nextstate;                 -- Store shifted registers
            IF rst = '1' THEN                       -- Reset button is held down. OUTPUT PSEUDO RANDOM NUMBERS!!
                seed_check := 0;                    -- Seed bit reset
                output <= currstate(7 DOWNTO 4);    -- Only output while the reset button is held, stop when reset is released
            END IF;
        END IF;
    END PROCESS;

    feedback <= currstate(4) XOR currstate(3) XOR currstate(2) XOR currstate(0);    -- Jumble bits out to make it random and set the bit to feedback
    nextstate <= feedback & currstate(7 DOWNTO 1);                                  -- Shift registers

END Behavioral;