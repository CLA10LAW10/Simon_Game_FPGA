library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity simon_says is
    port (
        clk       : in std_logic;                      -- Input clock
        btn       : in std_logic_vector (3 downto 0);  -- Input buttons for guessing and reset
        leds      : out std_logic_vector (3 downto 0); -- Output LEDS, will display game pattern
        red_led   : out std_logic;                     -- Output RED LED, used to indicate an end of game due to a wrong guess
        blue_led  : out std_logic;                     -- Output BLUE LED, used to indicate resulting scre of the game
        green_led : out std_logic                      -- Output GREEN LED, used to inidcate making all the way to level 10
    );
end simon_says;

architecture Behavioral of simon_says is

    component rand_gen is
        port (
            clk, rst : in std_logic;                     -- Input clock and reset
            seed     : in std_logic_vector(7 downto 0);  -- Input Seed for initial value
            output   : out std_logic_vector (3 downto 0) -- Output Random generated value
        );
    end component rand_gen;

    component single_pulse_detector is
        port (
            clk          : in std_logic;   -- Input clock
            rst          : in std_logic;   -- Asynchronous active high reset
            input_signal : in std_logic;   -- Input signal to detect
            output_pulse : out std_logic); -- Detected single pulse
    end component single_pulse_detector;

    component debounce is
        generic (
            clk_freq    : integer := 125_000_000; --system clock frequency in Hz
            stable_time : integer := 10);         --time button must remain stable in ms
        port (
            clk    : in std_logic;   --input clock
            rst    : in std_logic;   --asynchronous active high reset
            button : in std_logic;   --input signal to be debounced
            result : out std_logic); --debounced signal
    end component debounce;

    -- States used for Simon Says Game
    type state_type is (IDLE, RESET, LVL1, LVL2, LVL3, LVL4, LVL5, LVL6, LVL7, LVL8, LVL9, LVL10, THE_END, WIN, LOSE);
    signal current_state, next_state : state_type := RESET;
    signal rst                       : std_logic;
    signal button_reg                : std_logic_vector(39 downto 0) := (others => '0'); -- Shift register to store previous 10 inputs

    -- Signals used for secret numbers
    signal secret_number : std_logic_vector (39 downto 0);

    -- Signals used for debounce and button pulse
    signal btn_db    : std_logic_vector (3 downto 0);
    signal btn_pulse : std_logic_vector (3 downto 0);
    signal led_reg   : std_logic_vector (3 downto 0);

    -- Signals used to flash green LED
    constant stable_time : integer                       := 10;          --time button must remain stable in ms, Changed for simulation
    constant clk_freq    : integer                       := 125_000_000; --Change for simulation
    constant clk_cycles  : integer                       := 125_000_000; --Change for simulation
    signal flash_pattern : boolean                       := false; -- Signal to indicate when to flash the green LED
    signal reset_delay   : integer                       := 0;
    signal lose_delay    : integer                       := 0;
    signal win_delay     : integer                       := 0;
    signal count         : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal count1        : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal count2        : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal count3        : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal toggle        : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal toggle1       : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal toggle2       : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal toggle3       : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal level_won     : integer                       := 0;     -- Count the levels won/passed
    signal score         : integer                       := 0;     -- Used as a delay with the levels won
    signal count_pattern : integer                       := 0;     -- Used to increment the flashing pattern within a delay
    signal lose_int      : integer                       := 0;     -- Used as a delay for flashing the red led
    signal win_int       : integer                       := 0;     -- Used as a delay for flashing the green led
    signal lose_end      : boolean                       := false; -- Used as a flag to move to THE END from LOSE
    signal win_end       : boolean                       := false; -- Used as a flag to move to THE END from WIN

    ------------------------------------------------
    --------    Procedure Block     --------
    ------------------------------------------------
    -- Procedure used as a delay to flash the green LED
    procedure delay(
        constant clk_cycles : integer;          -- Consant system clock frequency in Hz
        signal toggle       : inout boolean;    -- Boolean toggle to indicate when to toggle
        signal count        : inout integer) is -- Signal count from 0 to stable time as a delay
    begin

        if count = clk_cycles - 1 then -- If 0.5 Hz, 1s Period is met
            toggle <= not toggle;          -- Toggle to initiate LED toggle
            count  <= 0;                   -- Reset counter to begin again
        else                           -- Not yet at 0.5Hz to meet a 1s period, keep counting.
            count <= count + 1;            -- Count and continue delaying
        end if;
    end procedure;

    -- Procedure used as a delay to flash the green LED
    procedure delay_pattern(
        constant clk_cycles : integer;          -- Consant system clock frequency in Hz
        signal increment    : inout integer;    -- Boolean toggle to indicate when to toggle
        signal count        : inout integer) is -- Signal count from 0 to stable time as a delay
    begin

        if count = clk_cycles then  -- If 0.5 Hz, 1s Period is met
            increment <= increment + 1; -- Toggle to initiate LED toggle
            count     <= 0;             -- Reset counter to begin again
        else                        -- Not yet at 0.5Hz to meet a 1s period, keep counting.
            count <= count + 1;         -- Count and continue delaying
        end if;
    end procedure;

begin
    ------------------------------------------------
    --------    COMPONENT INSTANTIATION     --------
    ------------------------------------------------

    -- Generate statement for all 4 buttons
    debounce_gen : for i in 0 to 3 generate
        debounce_btn : debounce
        generic map(clk_freq => clk_freq, stable_time => stable_time)
        port map(clk => clk, rst => rst, button => btn(i), result => btn_db(i));
    end generate;

    -- Randome Number Generatoor, generate statement for all 10 random numbers 
    random_gen : for i in 0 to 9 generate
        secret_number_gen : rand_gen
        port map(
            clk    => clk,
            rst    => rst,
            seed   => (std_logic_vector(to_unsigned(i, 8))),
            output => secret_number(i * 4 + 3 downto i * 4) -- 
        );
    end generate;

    --Generate statement for all 4 debounced buttons
    single_pulse_gen : for i in 0 to 3 generate
        single_pulse_btn : single_pulse_detector
        port map(
            clk          => clk,
            rst          => rst,
            input_signal => btn_db(i),
            output_pulse => btn_pulse(i)
        );
    end generate;

    ------------------------------------------------
    ---------        PROCESS BLOCKS        ---------
    ------------------------------------------------

    -- Simon Game, main game process
    simon_says : process (current_state, clk, rst)
    begin

        -- Asynchronous reset 
        if rst = '1' then
            button_reg  <= (others => '0');
            level_won   <= 0;
            next_state  <= RESET;
            reset_delay <= 0;
        else
            -- When a button is pushed, store the value in a shift register as the LSBs
            if (rising_edge(clk)) then
                if btn_pulse /= "0000" then
                    button_reg <= button_reg(35 downto 0) & btn_pulse;
                end if;
                -- Every clock pulse, assign next state to the current state
                current_state <= next_state;

                ------------------------------------------------
                --------     RESET STATE      --------
                ------------------------------------------------
                -- If in the reset state, move to the LVL1
                if current_state = RESET then
                    if reset_delay = clk_cycles then -- If 0.5 Hz, 1s Period is met
                        next_state  <= LVL1;
                        reset_delay <= 0;               -- Reset counter to begin again
                    else                            -- Not yet at delay period, keep counting.
                        reset_delay <= reset_delay + 1; -- Count and continue delaying
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 1 STATE      --------
                ------------------------------------------------
                if current_state = LVL1 then                                   -- If the current state is level 1
                    if button_reg(3 downto 0) /= "0000" then                       -- And a guess of 1 input has been recieved
                        if (button_reg(3 downto 0) = secret_number(39 downto 36)) then -- Compare the 1 input to the MSBs of secret number which will be guess 1
                            button_reg <= (others => '0');                                 -- Correct input, wipe the button register
                            level_won  <= level_won + 1;                                   -- Increment the Level
                            next_state <= LVL2;                                            -- Next level is now level 2
                        else
                            next_state <= LOSE; -- Wrong input, go to lose stage
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 2 STATE      --------
                ------------------------------------------------
                if current_state = LVL2 then
                    if button_reg(7 downto 4) /= "0000" then
                        if (button_reg(7 downto 0) = secret_number(39 downto 32)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL3;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 3 STATE      --------
                ------------------------------------------------
                if current_state = LVL3 then
                    if button_reg(11 downto 8) /= "0000" then
                        if (button_reg(11 downto 0) = secret_number(39 downto 28)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL4;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 4 STATE      --------
                ------------------------------------------------
                if current_state = LVL4 then
                    if button_reg(15 downto 12) /= "0000" then
                        if (button_reg(15 downto 0) = secret_number(39 downto 24)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL5;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 5 STATE      --------
                ------------------------------------------------
                if current_state = LVL5 then
                    if button_reg(19 downto 16) /= "0000" then
                        if (button_reg(19 downto 0) = secret_number(39 downto 20)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL6;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 6 STATE      --------
                ------------------------------------------------
                if current_state = LVL6 then
                    if button_reg(23 downto 20) /= "0000" then
                        if (button_reg(23 downto 0) = secret_number(39 downto 16)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL7;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 7 STATE      --------
                ------------------------------------------------
                if current_state = LVL7 then
                    if button_reg(27 downto 24) /= "0000" then
                        if (button_reg(27 downto 0) = secret_number(39 downto 12)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL8;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 8 STATE      --------
                ------------------------------------------------
                if current_state = LVL8 then
                    if button_reg(31 downto 28) /= "0000" then
                        if (button_reg(31 downto 0) = secret_number(39 downto 8)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL9;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 9 STATE      --------
                ------------------------------------------------
                if current_state = LVL9 then
                    if button_reg(35 downto 32) /= "0000" then
                        if (button_reg(35 downto 0) = secret_number(39 downto 4)) then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= LVL10;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;
                ------------------------------------------------
                --------     LEVEL 10 STATE      --------
                ------------------------------------------------
                if current_state = LVL10 then
                    if button_reg(39 downto 36) /= "0000" then
                        if button_reg = secret_number then
                            button_reg <= (others => '0');
                            level_won  <= level_won + 1;
                            next_state <= WIN;
                        else
                            next_state <= LOSE;
                        end if;
                    end if;
                end if;

                if lose_end then
                    if lose_delay = clk_cycles then -- If 0.5 Hz, 1s Period is met
                        next_state <= THE_END;
                        lose_delay <= 0;              -- Reset counter to begin again
                    else                          -- Not yet at delay period, keep counting.
                        lose_delay <= lose_delay + 1; -- Count and continue delaying
                    end if;

                end if;

                if win_end then
                    if win_delay = clk_cycles then -- If 0.5 Hz, 1s Period is met
                        next_state <= THE_END;
                        win_delay  <= 0;            -- Reset counter to begin again
                    else                        -- Not yet at delay period, keep counting.
                        win_delay <= win_delay + 1; -- Count and continue delaying
                    end if;

                end if;
            end if;
        end if;
    end process;

    -- End of game. Lose / Win
    win_game : process (current_state, clk)
    begin
        if rising_edge(clk) then
            if current_state = WIN then
                if win_int < 10 * clk_cycles then

                    if toggle1 = true then
                        green_led <= '1';
                        win_int   <= win_int + 1;
                        delay(clk_cycles, toggle1, count1); -- Delay for 500 ms
                    else
                        green_led <= '0';
                        win_int   <= win_int + 1;
                        delay(clk_cycles, toggle1, count1); -- Delay for 500 ms
                    end if;
                else
                    win_end <= true;
                end if;

            else
                win_int   <= 0;
                green_led <= '0';
                win_end   <= false;
            end if;
        end if;
    end process;

    -- End of game. Lose / Win
    lose_game : process (current_state, clk)
    begin
        if rising_edge(clk) then
            if current_state = LOSE then
                if lose_int < 10 * clk_cycles then

                    if toggle2 = true then
                        red_led  <= '1';
                        lose_int <= lose_int + 1;
                        delay(clk_cycles, toggle2, count2); -- Delay for 500 ms
                    else
                        red_led  <= '0';
                        lose_int <= lose_int + 1;
                        delay(clk_cycles, toggle2, count2); -- Delay for 500 ms
                    end if;
                else
                    lose_end <= true;
                end if;

            else
                lose_int <= 0;
                red_led  <= '0';
                lose_end <= false;
            end if;
        end if;
    end process;

    -- End of game. Lose / Win
    score_game : process (current_state, clk)
    begin
        if rising_edge(clk) then
            if current_state = THE_END then
                if score < level_won * 2 * clk_cycles then
                    score <= score + 1;
                    if toggle3 then
                        blue_led <= '1';
                        delay(clk_cycles, toggle3, count3); -- Delay for 500 ms
                    else
                        blue_led <= '0';
                        delay(clk_cycles, toggle3, count3); -- Delay for 500 ms
                    end if;
                elsif score >= level_won * 2 * clk_cycles then
                    blue_led <= '0';
                end if;
            else
                blue_led <= '0';
                score    <= 0;
            end if;
        end if;
    end process;

    -- End of game. Lose / Win
    level_flash : process (clk, current_state, next_state)
    begin
        if rising_edge(clk) then
            if flash_pattern then
                if count_pattern <= (level_won + 1) then
                    case count_pattern is
                        when 1 =>
                            if count = 0 then
                                led_reg <= secret_number(39 downto 36);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 2 =>
                            if count = 0 then
                                led_reg <= secret_number(35 downto 32);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);

                        when 3 =>
                            if count = 0 then
                                led_reg <= secret_number(31 downto 28);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 4 =>
                            if count = 0 then
                                led_reg <= secret_number(27 downto 24);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 5 =>
                            if count = 0 then
                                led_reg <= secret_number(23 downto 20);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 6 =>
                            if count = 0 then
                                led_reg <= secret_number(19 downto 16);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 7 =>
                            if count = 0 then
                                led_reg <= secret_number(15 downto 12);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 8 =>
                            if count = 0 then
                                led_reg <= secret_number(11 downto 8);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 9 =>
                            if count = 0 then
                                led_reg <= secret_number(7 downto 4);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 10 =>
                            if count = 0 then
                                led_reg <= secret_number(3 downto 0);
                            elsif count = clk_cycles / 2 then
                                led_reg <= (others => '0');
                            end if;
                            delay_pattern(clk_cycles, count_pattern, count);
                        when others => led_reg <= (others => '0');
                    end case;
                else
                    count_pattern <= 0;
                    flash_pattern <= false;
                end if;
            else
                led_reg <= (others => '0');
            end if;

            if next_state = RESET or next_state = LOSE or next_state = THE_END or next_state = WIN then
                flash_pattern <= false;
            elsif current_state /= next_state then
                flash_pattern <= true;
                count_pattern <= count_pattern + 1;
            end if;
        end if;
    end process;

    ------------------------------------------------
    --------     CONCURRENT ASIGNMENTS      --------
    ------------------------------------------------

    rst <= '1' when btn = "0101" else
        '0';

    leds <= led_reg;

end Behavioral;