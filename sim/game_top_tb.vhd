library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity simon_says_tb is

end simon_says_tb;

architecture Behavioral of simon_says_tb is

    component simon_says is
        -- generic (
        --     clk_cycles : integer := 10;
        -- );
        port (
            clk       : in std_logic;                      -- Input clock
            btn       : in std_logic_vector (3 downto 0);  -- Input buttons for guessing and reset
            leds      : out std_logic_vector (3 downto 0); -- Output LEDS, used when having the number shows
            red_led   : out std_logic;                     -- Output RED LED, used to indicate a high number
            blue_led  : out std_logic;                     -- Output BLUE LED, used to indicate a low nubmer
            green_led : out std_logic                      -- Output GREEN LED, used to inidcate the correct number
        );
    end component simon_says;

    constant clk_cycles_tb : integer := 100;
    signal clk_tb       : std_logic; -- Signal simulated clock 
    signal btn_tb       : std_logic_vector (3 downto 0);
    signal leds_tb      : std_logic_vector (3 downto 0); -- Signal simulated output LED
    signal red_led_tb   : std_logic;                     -- Signal simulated red output LED
    signal blue_led_tb  : std_logic;                     -- Signal simulated blue output LED
    signal green_led_tb : std_logic;                     -- Signal simulated green output LED

    constant CP : time := 8ns;

begin

    -- Instantiate the unit under test
    uut : simon_says
    -- GENERIC MAP(
    --     clk_cycles => clk_cycles_tb
    -- )
    port map(
        clk       => clk_tb,
        btn       => btn_tb,
        leds      => leds_tb,
        red_led   => red_led_tb,
        blue_led  => blue_led_tb,
        green_led => green_led_tb
    );

    -- Clock generation process
    clk_gen : process
    begin
        clk_tb <= '1';
        wait for CP/2;
        clk_tb <= '0';
        wait for CP/2;
    end process;

    -- Input vector
    input_gen : process
    begin

        btn_tb <= "0101"; -- Reset
        wait for (7 * CP);

        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);

        btn_tb <= "0100"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010";
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 4
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 4
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0001"; -- Level 5
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 4
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0001"; -- Level 5
        wait for (clk_cycles_tb * CP);
        btn_tb <= "1000"; -- Level 6
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 4
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0001"; -- Level 5
        wait for (clk_cycles_tb * CP);
        btn_tb <= "1000"; -- Level 6
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 7
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 4
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0001"; -- Level 5
        wait for (clk_cycles_tb * CP);
        btn_tb <= "1000"; -- Level 6
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 7
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 8
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 4
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0001"; -- Level 5
        wait for (clk_cycles_tb * CP);
        btn_tb <= "1000"; -- Level 6
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 7
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 8
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Button Delay due to single pulse detector
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 9
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait for (clk_cycles_tb * CP);

        btn_tb <= "0100"; -- Level 1
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 2
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 3
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 4
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0001"; -- Level 5
        wait for (clk_cycles_tb * CP);
        btn_tb <= "1000"; -- Level 6
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0010"; -- Level 7
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 8
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Button Delay due to single pulse detector
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0100"; -- Level 9
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0001"; -- Level 10
        wait for (clk_cycles_tb * CP);
        btn_tb <= "0000"; -- Delay in Game
        wait;
        -- wait for (5 * CP);

        -- btn_tb <= "0101"; -- Reset
        -- wait for (clk_cycles_tb * CP);
        -- btn_tb <= "0100"; -- Bad Guess
        -- wait for (clk_cycles_tb * CP);
        -- wait;

        --stop;

    end process;

end Behavioral;