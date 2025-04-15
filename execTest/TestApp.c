// Save this as TestApp.c in your project directory
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int global_value = 42;

void print_message(const char* message) {
    printf("[TestApp] %s\n", message);
}

int add_numbers(int a, int b) {
    printf("[TestApp] Adding %d + %d\n", a, b);
    return a + b;
}

int main() {
    printf("[TestApp] Process ID: %d\n", getpid());
    printf("[TestApp] Global value address: %p\n", &global_value);

    while(1) {
        printf("[TestApp] Global value is: %d\n", global_value);
        print_message("Running...");
        int result = add_numbers(5, 7);
        printf("[TestApp] Result: %d\n", result);
        sleep(2);
    }

    return 0;
}