const pico = @cImport({
    @cInclude("stdio.h");
    @cInclude("pico/stdlib.h");
});

export fn main() c_int {
    _ = pico.setup_default_uart();
    _ = pico.printf("Hello, world!\n");
    const led = pico.PICO_DEFAULT_LED_PIN;
    pico.gpio_init(led);
    pico.gpio_set_dir(led, pico.GPIO_OUT != 0);
    pico.gpio_put(led, true);
    while (true) {
        pico.gpio_put(led, true);
        pico.sleep_ms(500);
        pico.gpio_put(led, false);
        pico.sleep_ms(500);
    }
    return 0;
}
