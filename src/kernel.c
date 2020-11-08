#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <stdio.h>
#include "kernel/cpu.h"
#include "kernel/interrupts.h"
#include "kernel/terminal.h"
#include "kernel/keyboard.h"
#include "kernel/pci.h"
#include <bootboot.h>
extern BOOTBOOT bootboot;
extern uint8_t fb;
extern unsigned char environment[4096];

#ifndef __ARGIR_BUILD_COMMIT__
#define __ARGIR_BUILD_COMMIT__ "balls"
#endif

static void print_logo();

/**
 * Kernel entry.
 */
void _start()
{
    // terminal_init(bootboot.fb_width, bootboot.fb_height, &fb,
    //               bootboot.fb_scanline);
    // print_logo();

    // interrupts_disable();
    __asm__ volatile("push %rbp\n\t"
                     "mov %rsp, %rbp\n\t"
                     "cli\n\t"
                     "nop\n\t"
                     "pop %rbp\n\t");
    // retq causes invalid opcode exception -> ran out of stack space?

    //    0:	55                   	push   %rbp
    //    1:	48 89 e5             	mov    %rsp,%rbp
    //    4:	fa                   	cli
    //    5:	90                   	nop
    //    6:	5d                   	pop    %rbp
    //    7:	c3                   	retq

    // gdt_init();
    // interrupts_init();
    // keyboard_init();
    // init_pci();

    // interrupts_enable();

    for (;;) {
        keyboard_main();

        __asm__ volatile("hlt");
    }
}

static void print_logo()
{
    printf(
        "\n                                @@\\\n"
        "                                \\__|\n"
        "   @@@@@@\\   @@@@@@\\   @@@@@@\\  @@\\  @@@@@@\\   @@@@@@\\   @@@@@@@\\\n"
        "   \\____@@\\ @@  __@@\\ @@  __@@\\ @@ |@@  __@@\\ @@  __@@\\ @@  _____|\n"
        "   @@@@@@@ |@@ |  \\__|@@ /  @@ |@@ |@@ |  \\__|@@ /  @@ |\\@@@@@@\\\n"
        "  @@  __@@ |@@ |      @@ |  @@ |@@ |@@ |      @@ |  @@ | \\____@@\\\n"
        "  \\@@@@@@@ |@@ |      \\@@@@@@@ |@@ |@@ |      \\@@@@@@  |@@@@@@@  |\n"
        "   \\_______|\\__|       \\____@@ |\\__|\\__|       \\______/ \\_______/\n"
        "                      @@\\   @@ |\n"
        "                      \\@@@@@@  |\n"
        "                       \\______/\n\n"
        "Argir x86_64\n"
        "Build " __ARGIR_BUILD_COMMIT__ "\n\n");
}
