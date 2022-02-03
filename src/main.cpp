#include "stdio.h"
#include "pico/stdlib.h"
#include "hardware/pio.h"
#include "hardware/clocks.h"
#include "blink.pio.h"

int led = PICO_DEFAULT_LED_PIN;

extern "C" int main() {
    setup_default_uart();
    printf("Hello, world!\n");

    auto blink_prog = pio_add_program(pio0, &blink_program);
    auto blink_conf = blink_program_get_default_config(blink_prog);
    pio_gpio_init(pio0, led);
    pio_sm_set_consecutive_pindirs(pio0, 0, led, 1, true);
    sm_config_set_set_pins(&blink_conf, led, 1);
    pio_sm_init(pio0, 0, blink_prog, &blink_conf);
    pio0->txf[0] = clock_get_hz(clk_sys) / (2*4);
    pio_sm_set_enabled(pio0, 0, true);

    return 0;
}