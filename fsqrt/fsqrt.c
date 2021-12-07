#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void printdouble(double sq, int j){
    if (sq >= 2.0){
        printf("*****************error*****************\n");
        exit(1);
    }
    for (int i = 0; i < j; i++){
        if (sq >= 1.0){
            printf("1");
            sq = sq - 1.0;
        } else {
            printf("0");
        }
        sq = sq * 2.0;
    }
}

int main(){
    double sq;
    double sq_2;
    double di;
    double di_2;
    for (int i = 0; i < 512; i++){
        di = i;
        sq = sqrt((1.0 + di / 512) * 2.0);
        di_2 = i + 0.5;
        sq_2 = sqrt((1.0 + di_2 / 512) * 2.0);
        printf("\t\tram[%d] <= 36'b", i);
        printdouble((sq - 1.0) * 2.0, 23);
        printdouble(1.0 / sq_2, 13);
        printf(";\n");
    }
    for (int i = 0; i < 512; i++){
        di = i;
        sq = sqrt(1.0 + di / 512);
        di_2 = i;
        sq_2 = sqrt(1.0 + di_2 / 512);
        printf("\t\tram[%d] <= 36'b", i + 512);
        printdouble((sq - 1.0) * 2.0, 23);
        printdouble(1.0 / sq_2, 13);
        printf(";\n");
    }
}