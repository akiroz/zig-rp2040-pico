const pico = @cImport({
    @cInclude("stdio.h");
    @cInclude("pico/stdlib.h");
});

const led = pico.PICO_DEFAULT_LED_PIN;

export fn main() c_int {
    _ = pico.setup_default_uart();
    _ = pico.printf("Hello, world!\n");
    return 0;
}
