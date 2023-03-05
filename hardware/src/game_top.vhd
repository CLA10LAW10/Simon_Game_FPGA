LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY number_guess IS
    PORT (
        clk : IN STD_LOGIC;                             -- Input clock
        btn : IN STD_LOGIC_VECTOR (3 downto 0);         -- Input buttons for guessing and reset
        leds : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);       -- Output LEDS, used when having the number shows
        red_led : OUT STD_LOGIC;                        -- Output RED LED, used to indicate a high number
        blue_led : OUT STD_LOGIC;                       -- Output BLUE LED, used to indicate a low nubmer
        green_led : OUT STD_LOGIC                       -- Output GREEN LED, used to inidcate the correct number
    );
END number_guess;

ARCHITECTURE Behavioral OF number_guess IS

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

    COMPONENT rand_gen IS
        PORT (
            clk, rst : IN STD_LOGIC;                    -- Input clock and reset
            seed : IN STD_LOGIC_VECTOR(7 DOWNTO 0);     -- Input Seed for initial value
            output : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)  -- Output Random generated value
        );
    END COMPONENT rand_gen;

    -- Constants for debounce
    CONSTANT clk_freq : INTEGER := 125_000_000; -- Consant system clock frequency in Hz
    CONSTANT stable_time : INTEGER := 10;       -- Constant 10 ms stable button time.
    CONSTANT stable_led : INTEGER := 1;         -- Constant 1 Second stable time

    -- Signals used debounce
    --SIGNAL secret_number : STD_LOGIC_VECTOR (3 DOWNTO 0);   -- Signal to pass secret number
    SIGNAL enter_db : STD_LOGIC;                            -- Signal to hold debounced enter button value

    -- States used for Simon Says Game
    type state_type is (RESET,LVL1,LVL2,LVL3,LVL4,LVL5,LVL6,LVL7,LVL8,LVL9,LVL10);
    signal current_state : state_type := RESET;

    -- Signals used for secret numbers
    SIGNAL sn1,sn2,sn3,sn4,sn5,sn6,sn7,sn8,sn9,sn10 : STD_LOGIC_VECTOR (3 DOWNTO 0); 

    -- Signals used to flash green LED
    SIGNAL flash : STD_LOGIC;                                           -- Signal to indicate when to flash the green LED
    SIGNAL count : INTEGER RANGE 0 TO clk_freq * stable_led / 2 := 0;   -- Signal count from 0 to 62_500_000, 0.5 Hz
    SIGNAL toggle : BOOLEAN := true;                                    -- Boolean toggle, used as a conditional to then toggle green LED.

    -- Procedure used as a delay to flash the green LED
    PROCEDURE delay(                        
        CONSTANT clk_freq : INTEGER;        -- Consant system clock frequency in Hz
        CONSTANT stable_led : INTEGER;      -- Constant 1 Second stable time
        SIGNAL toggle : INOUT BOOLEAN;      -- Boolean toggle to indicate when to toggle
        SIGNAL count : INOUT INTEGER) IS    -- Signal count from 0 to stable time as a delay
    BEGIN

        IF count = clk_freq * stable_led / 2 THEN   -- If 0.5 Hz, 1s Period is met
            toggle <= NOT toggle;                   -- Toggle to initiate LED toggle
            count <= 0;                             -- Reset counter to begin again
        ELSE                                        -- Not yet at 0.5Hz to meet a 1s period, keep counting.
            count <= count + 1;                     -- Count and continue delaying
        END IF;
    END PROCEDURE;

BEGIN

    -- Debounce show button input
    show_debounce : debounce
    GENERIC MAP(clk_freq => clk_freq, stable_time => stable_time)
    PORT MAP(clk => clk, rst => rst, button => show, result => show_db);

    -- Debounce enter button input
    enter_debounce : debounce
    GENERIC MAP(clk_freq => clk_freq,stable_time => stable_time)
    PORT MAP(clk => clk, rst => rst, button => enter, result => enter_db);

    -- Generate a random number with a seed of 0x4f
    scrt_num : rand_gen
    PORT MAP(clk => clk, rst => rst, seed => "01001111", output => secret_number);

 

    -- You win! Flash the green light! (Or did you hit show and enter the correct value ;)
    flash_green : PROCESS (flash, clk)
    BEGIN
        IF flash = '0' THEN                                     -- If flash it 0, do not flash
            green_led <= '0';                                   -- Keep green led off
        ELSE                                                    -- Flash is high, flash green LED
            IF rising_edge(clk) THEN
                IF toggle THEN                                  -- If toggle is high
                    green_led <= '1';                           -- turn green LED on
                    delay(clk_freq, stable_led, toggle, count); -- Deblay for 500 ms
                ELSE                                            -- If toggle is low
                    green_led <= '0';                           -- Turn green LED off
                    delay(clk_freq, stable_led, toggle, count); -- Deblay for 500 ms
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity sequential_input_checker is
    port (
        input_sig : in std_logic_vector(3 downto 0);
        output_sig : out std_logic
    );
end entity sequential_input_checker;

architecture behavioral of sequential_input_checker is
    signal input_reg : std_logic_vector(4 downto 0) := "00000"; -- Shift register to store previous 5 inputs
begin
    process (input_sig, input_reg)
    begin
        input_reg <= input_reg(3 downto 0) & input_sig; -- Shift in the current input

        if input_reg = "00010101" then
            output_sig <= '1'; -- Input pattern matches the desired sequence, set the output high
        else
            output_sig <= '0'; -- Input pattern doesn't match the desired sequence, set the output low
        end if;
    end process;
end architecture behavioral;
