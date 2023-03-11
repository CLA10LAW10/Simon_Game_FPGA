LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.env.stop;

ENTITY debounce_tb IS
END debounce_tb;

ARCHITECTURE Behavioral OF debounce_tb IS

    COMPONENT debounce IS
     GENERIC (
            clk_freq : INTEGER := 125_000_000;      --system clock frequency in Hz
            stable_time : INTEGER := 10);           --time button must remain stable in ms
        PORT (
            clk : IN STD_LOGIC;                     --input clock
            rst : IN STD_LOGIC;                     --asynchronous active high reset
            button : IN STD_LOGIC;                  --input signal to be debounced
            result : OUT STD_LOGIC);                --debounced signal
    END COMPONENT debounce;

    CONSTANT clk_freq_tb : INTEGER := 125_000_000;  --system clock frequency in Hz
    CONSTANT stable_time_tb : INTEGER := 10;        --time button must remain stable in ms

    SIGNAL clk_tb : STD_LOGIC;      -- Signal simulated clock 
    SIGNAL rst_tb : STD_LOGIC;      -- Signal simulated reset button
    SIGNAL button_tb : STD_LOGIC;   -- Signal simulated button input
    SIGNAL result_tb : STD_LOGIC;   -- Signal simulated output debounce result

    CONSTANT CP : TIME := 8ns;      -- Constant system period

BEGIN

    -- Instantiate the unit under test
    uut : debounce
    GENERIC MAP(
        clk_freq => clk_freq_tb,
        stable_time => stable_time_tb
    )
    PORT MAP(
        clk => clk_tb,
        rst => rst_tb,
        button => button_tb,
        result => result_tb
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
        wait for 10 * CP; -- Observe the unknown
        button_tb <= '0'; -- Initialize button to low

        -- Reset the module
        rst_tb <= '1';    
        wait for CP;
        rst_tb <= '0';

        -- Observe an invalid input
        button_tb <= '1';
        wait for 10 * CP;
        button_tb <= '0';       -- Button set low, valid input
        wait for 2000000 * CP; 
        button_tb <= '1';       -- Button set high, valid input
        wait for 2000000 * CP; 
        button_tb <= '0';       -- Button set low, invalid input
        wait for 20000 * CP;

        button_tb <= '1';       -- Button set high, invalid input
        wait for 10 * CP;
        button_tb <= '0';       -- Button set low, valid input
        wait for 2000000 * CP;
        button_tb <= '1';       -- Button set high, invalid input
        wait for 40 * CP;
        button_tb <= '0';       -- Button set low, invalid input
        wait for 40 * CP;
        button_tb <= '1';       -- Button set high, valid input
        wait for 2000000 * CP;
        button_tb <= '0';       -- Button set low, valid input
        wait for 200000 * CP;

        stop;
    END PROCESS;

END Behavioral;