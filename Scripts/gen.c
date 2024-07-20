#include <stdio.h>
#include <math.h>

#define CORES 2

void generator(int cores) {
    printf("--------------------------------------------- CORES = %d\n", cores);
    int i, j, k;
    for (k = 0; k < (int)log2(cores); k = k + 1) { // k = 0, 1, 2 { k < 3 }
        printf("---------------------------- %d\n", k);
        for (i = k * cores - ; i < cores / (int)pow(2, k); i = i + 2) { // i = 0, 1, 2 | 4, 2, 1 
            printf("------> %2d\n", i + ((int)log2(cores) * k * 2));
        }
    }
    return ;
}

int main(void) {
    
    // generator(CORES);
    // generator(CORES * 2);
    generator(CORES * 4);
    // generator(CORES * 8);
    
    return 0;
}