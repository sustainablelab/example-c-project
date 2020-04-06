#include <stdio.h>

extern int util(int);

int main(int argc, char **argv)
{
    printf("Hi.");
    return util(argc);
}
