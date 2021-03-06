#ifndef __ARGIR__TERMINAL_H
#define __ARGIR__TERMINAL_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

void terminal_scroll_up(size_t n);
void terminal_clear();
void terminal_write_char(const char str);
void terminal_write(const char *str);
void terminal_init(uint64_t *framebuffer, size_t screen_width,
                   size_t screen_height, size_t fb_pitch);

#endif /* __ARGIR__TERMINAL_H */
