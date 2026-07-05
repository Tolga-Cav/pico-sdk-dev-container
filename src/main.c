#include <stdio.h>
#include "pico/stdlib.h"

// Simple sanity-check program:
//   - blinks the onboard LED
//   - prints a counter over USB serial so you can verify the serial
//     monitor setup works end-to-end.

int main() {
    stdio_init_all();

#ifdef PICO_DEFAULT_LED_PIN
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
#endif

    int count = 0;
    while (true) {
#ifdef PICO_DEFAULT_LED_PIN
        gpio_put(PICO_DEFAULT_LED_PIN, 1);
#endif
        printf("Hello from Pico 2! count = %d\n", count++);
        sleep_ms(500);
#ifdef PICO_DEFAULT_LED_PIN
        gpio_put(PICO_DEFAULT_LED_PIN, 0);
#endif
        sleep_ms(500);
    }

    return 0;
}
