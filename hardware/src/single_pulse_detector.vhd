LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY single_pulse_detector IS
    PORT (
        clk : IN STD_LOGIC;             -- Input clock
        rst : IN STD_LOGIC;             -- Asynchronous active high reset
        input_signal : IN STD_LOGIC;    -- Input signal to detect
        output_pulse : OUT STD_LOGIC);  -- Detected single pulse
END single_pulse_detector;

ARCHITECTURE Behavioral OF single_pulse_detector IS

    SIGNAL ff1 : STD_LOGIC; -- Input flip-flop
    SIGNAL ff2 : STD_LOGIC; -- Input flip-flop

BEGIN

    PROCESS (clk, rst)
    BEGIN

        IF rst = '1' THEN           -- Asynchronous active high reset
            ff1 <= '0';             -- Clear input flipflop 1.
            ff2 <= '0';             -- Clear input flipflop 2.
        ELSIF rising_edge(clk) THEN
            ff1 <= input_signal;    -- Store input value in 1st ff.
            ff2 <= ff1;             -- Store 1st ff value in 2nd ff.

        END IF;

    END PROCESS;

    output_pulse <= ff1 AND NOT ff2; -- Detect rising edge.

END Behavioral;