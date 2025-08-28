#include <stdio.h>
#include <stdlib.h>
#include <execinfo.h>

#define BACKTRACE_STACK_SIZE 64

// 加了static就不能打印出函数名
void dump_stack(void)
{
	void *backtrace_stack[BACKTRACE_STACK_SIZE];
        size_t backtrace_size;
        char **backtrace_strings;

        /* get the backtrace (stack frames) */
        backtrace_size = backtrace(backtrace_stack, BACKTRACE_STACK_SIZE);
        backtrace_strings = backtrace_symbols(backtrace_stack, backtrace_size);

        printf("BACKTRACE: %lu stack frames:\n", (unsigned long)backtrace_size);

        if (backtrace_strings) {
                size_t i;

                for (i = 0; i < backtrace_size; i++)
                        printf(" #%zu %s\n", i, backtrace_strings[i]);

		free(backtrace_strings);
        }
}

void func2(void)
{
	dump_stack();
}

void func1(void)
{
	func2();
}

int main()
{
	func1();
	return 0;
}

