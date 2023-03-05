LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.env.stop;

ENTITY number_guess_tb IS

END number_guess_tb;

ARCHITECTURE Behavioral OF number_guess_tb IS

    COMPONENT number_guess IS
        PORT (
            clk : IN STD_LOGIC;                             -- Input clock
            rst : IN STD_LOGIC;                             -- Input rst, used to reset the game
            show : IN STD_LOGIC;                            -- Input show to SHOW the answer to the player
            enter : IN STD_LOGIC;                           -- Input enter, used to indicate a guessing value.
            switches : IN STD_LOGIC_VECTOR (3 DOWNTO 0);    -- Input switches, used to guess the secret number
            leds : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);       -- Output LEDS, used when having the number shows
            red_led : OUT STD_LOGIC;                        -- Output RED LED, used to indicate a high number
            blue_led : OUT STD_LOGIC;                       -- Output BLUE LED, used to indicate a low nubmer
            green_led : OUT STD_LOGIC                       -- Output GREEN LED, used to inidcate the correct number
        );
    END COMPONENT number_guess;

    SIGNAL clk_tb : STD_LOGIC;                          -- Signal simulated clock 
    SIGNAL rst_tb : STD_LOGIC;                          -- Signal simulated reset button
    SIGNAL show_tb : STD_LOGIC;                         -- Signal simulated show button
    SIGNAL enter_tb : STD_LOGIC;                        -- Signal simulated enter button
    SIGNAL switches_tb : STD_LOGIC_VECTOR (3 DOWNTO 0); -- Signal simulated 4 bit input to guess secret number
    SIGNAL leds_tb : STD_LOGIC_VECTOR (3 DOWNTO 0);     -- Signal simulated output LED
    SIGNAL red_led_tb : STD_LOGIC;                      -- Signal simulated red output LED
    SIGNAL blue_led_tb : STD_LOGIC;                     -- Signal simulated blue output LED
    SIGNAL green_led_tb : STD_LOGIC;                    -- Signal simulated green output LED

    CONSTANT CP : TIME := 8ns;

BEGIN

    -- Instantiate the unit under test
    uut : number_guess
    PORT MAP(
        clk => clk_tb,
        rst => rst_tb,
        show => show_tb,
        enter => enter_tb,
        switches => switches_tb,
        leds => leds_tb,
        red_led => red_led_tb,
        blue_led => blue_led_tb,
        green_led => green_led_tb
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
    input_gen : PROCESS
    BEGIN

        -- Initialize to 0 and reset
        rst_tb <= '1';
        show_tb <= '0';
        enter_tb <= '0';
        switches_tb <= "0000";
        WAIT FOR 2000000 * CP;

        -- Reset to seed random number generator
        -- Generate a random number
        rst_tb <= '0';
        WAIT FOR 2000000 * CP;
        rst_tb <= '1';
        WAIT FOR 2000000 * CP;
        rst_tb <= '0';
        WAIT FOR 2000000 * CP;

        -- Show the secret number
        show_tb <= '1';
        WAIT FOR 2000000 * CP;
        show_tb <= '0';
        WAIT FOR 2000000 * CP;

        -- Reset the secret value
        rst_tb <= '1';
        WAIT FOR 1885999 * CP;
        rst_tb <= '0';
        WAIT FOR 2000000 * CP;

        -- Guess a low number
        -- Oberve the blue LED
        switches_tb <= "0001";
        WAIT FOR 2000000 * CP;

        enter_tb <= '1';
        WAIT FOR 2000000 * CP;
        enter_tb <= '0';
        WAIT FOR 2000000 * CP;

        -- Guess a high number 
        -- Observe the red LED
        switches_tb <= "1111";
        WAIT FOR 2000000 * CP;

        enter_tb <= '1';
        WAIT FOR 2000000 * CP;
        enter_tb <= '0';
        WAIT FOR 2000000 * CP;

        -- Guess the correct number
        -- Observe the flashing green LED
        switches_tb <= "1101";
        WAIT FOR 2000000 * CP;

        enter_tb <= '1';
        WAIT FOR 2000000 * CP;
        enter_tb <= '0';
        WAIT FOR 125_000_000 * CP;

        stop;
    END PROCESS;

END Behavioral;