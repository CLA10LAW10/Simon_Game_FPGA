library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity simon_says is
    -- generic (
    --     clk_cycles : integer := 10
    -- );
    port (
        clk       : in std_logic;                      -- Input clock
        btn       : in std_logic_vector (3 downto 0);  -- Input buttons for guessing and reset
        leds      : out std_logic_vector (3 downto 0); -- Output LEDS, used when having the number shows
        red_led   : out std_logic;                     -- Output RED LED, used to indicate a high number
        blue_led  : out std_logic;                     -- Output BLUE LED, used to indicate a low nubmer
        green_led : out std_logic                      -- Output GREEN LED, used to inidcate the correct number
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

    -- States used for Simon Says Game
    type state_type is (IDLE, RESET, LVL1, LVL2, LVL3, LVL4, LVL5, LVL6, LVL7, LVL8, LVL9, LVL10, THE_END, WIN, LOSE);
    signal current_state, next_state : state_type := RESET;
    signal rst                       : std_logic;

    -- Signal used to shift bits
    signal button_reg : std_logic_vector(39 downto 0) := (others => '0'); -- Shift register to store previous 10 inputs

    -- Signals used for secret numbers
    signal secret_number : std_logic_vector (39 downto 0);

    -- Signals used for secret numbers
    signal btn_pulse : std_logic_vector (3 downto 0);

    -- Signals used to flash green LED
    constant clk_cycles  : integer                       := 25;
    constant stable_led  : integer                       := 1;     -- Constant 1 ms stable time
    signal flash_pattern : boolean                       := false; -- Signal to indicate when to flash the green LED
    signal count         : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal count1        : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal count2        : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal count3        : integer range 0 to clk_cycles := 0;     -- Signal count from 0 to 62_500_000, 0.5 Hz
    signal toggle        : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal toggle1       : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal toggle2       : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal toggle3       : boolean                       := true;  -- Boolean toggle, used as a conditional to then toggle green LED.
    signal level_won     : integer                       := 0;
    signal score         : integer                       := 0;
    signal count_pattern : integer                       := 0;
    signal lose_int      : integer                       := 0;
    signal win_int       : integer                       := 0;
    signal lose_end      : boolean                       := false;
    signal win_end       : boolean                       := false;

    ------------------------------------------------
    --------    Procedure Block     --------
    ------------------------------------------------
    -- Procedure used as a delay to flash the green LED
    procedure delay(
        constant clk_cycles : integer;          -- Consant system clock frequency in Hz
        constant stable_led : integer;          -- Constant 1 Second stable time
        signal toggle       : inout boolean;    -- Boolean toggle to indicate when to toggle
        signal count        : inout integer) is -- Signal count from 0 to stable time as a delay
    begin

        if count = clk_cycles then -- If 0.5 Hz, 1s Period is met
            toggle <= not toggle;      -- Toggle to initiate LED toggle
            count  <= 0;               -- Reset counter to begin again
        else                       -- Not yet at 0.5Hz to meet a 1s period, keep counting.
            count <= count + 1;        -- Count and continue delaying
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

    random_gen : for i in 0 to 9 generate
        secret_number_gen : rand_gen
        port map(
            clk    => clk,
            rst    => rst,
            seed   => (std_logic_vector(to_unsigned(i, 8))),
            output => secret_number(i * 4 + 3 downto i * 4) -- 
        );
    end generate;

    single_pulse_gen : for i in 0 to 3 generate
        single_pulse_btn : single_pulse_detector
        port map(
            clk          => clk,
            rst          => rst,
            input_signal => btn(i),
            output_pulse => btn_pulse(i)
        );
    end generate;

    ------------------------------------------------
    ---------        PROCESS BLOCKS        ---------
    ------------------------------------------------

    simon_says : process (current_state, clk)
    begin

        -- Reset and Store up to 10 levels
        if rst = '1' then
            button_reg <= (others => '0');
            level_won  <= 0;
            next_state <= RESET;
        else
            if (rising_edge(clk)) then
                if btn_pulse /= "0000" then
                    button_reg <= button_reg(35 downto 0) & btn_pulse;
                end if;
            end if;
            current_state <= next_state;

            ------------------------------------------------
            --------     RESET STATE      --------
            ------------------------------------------------
            if current_state = RESET then
                next_state <= LVL1;
                --flash_pattern <= true;
            end if;
            ------------------------------------------------
            --------     LEVEL 1 STATE      --------
            ------------------------------------------------
            if current_state = LVL1 then
                if button_reg(3 downto 0) /= "0000" then                       -- No input
                    if (button_reg(3 downto 0) = secret_number(39 downto 36)) then -- Check button input and MSBs of the secret number
                        button_reg <= (others => '0');
                        level_won  <= level_won + 1;
                        next_state <= LVL2;
                    else
                        next_state <= LOSE;
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
                next_state <= THE_END;
            end if;

            if win_end then
                next_state <= THE_END;
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
                        delay(clk_cycles, stable_led, toggle1, count1); -- Delay for 500 ms
                    else
                        green_led <= '0';
                        win_int   <= win_int + 1;
                        delay(clk_cycles, stable_led, toggle1, count1); -- Delay for 500 ms
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
                        delay(clk_cycles, stable_led, toggle2, count2); -- Delay for 500 ms
                    else
                        red_led  <= '0';
                        lose_int <= lose_int + 1;
                        delay(clk_cycles, stable_led, toggle2, count2); -- Delay for 500 ms
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
                if score <= level_won * 2 * clk_cycles then
                    score    <= score + 1;
                    if toggle3 then
                        blue_led <= '1';
                        delay(clk_cycles, stable_led, toggle3, count3); -- Delay for 500 ms
                    else
                        blue_led <= '0';
                        delay(clk_cycles, stable_led, toggle3, count3); -- Delay for 500 ms
                    end if;
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
                            leds <= secret_number(39 downto 36);
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 2 =>
                            leds <= secret_number(35 downto 32);
                            delay_pattern(clk_cycles, count_pattern, count);
                        when 3 =>
                            leds <= secret_number(31 downto 28);
                            delay_pattern(clk_cycles,count_pattern,count);
                        when 4 =>
                            leds <= secret_number(27 downto 24);
                            delay_pattern(clk_cycles,count_pattern,count);
                        when 5 =>
                            leds <= secret_number(23 downto 20);
                            delay_pattern(clk_cycles,count_pattern,count);
                        when 6 =>
                            leds <= secret_number(19 downto 16);
                            delay_pattern(clk_cycles,count_pattern,count);
                        when 7 =>
                            leds <= secret_number(15 downto 12);
                            delay_pattern(clk_cycles,count_pattern,count);
                        when 8 =>
                            leds <= secret_number(11 downto 8);
                            delay_pattern(clk_cycles,count_pattern,count);
                        when 9 =>
                            leds <= secret_number(7 downto 4);
                            delay_pattern(clk_cycles,count_pattern,count);
                        when 10 =>
                            leds                <= secret_number(3 downto 0);
                        when others => leds <= (others => '0');

                    end case;

                    --count_pattern <= count_pattern + 1;
                else
                    count_pattern <= 0;
                    flash_pattern <= false;
                end if;
            else
                leds <= (others => '0');
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

end Behavioral;