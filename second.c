#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int max(int x, int y)
{
    if (x >= y)
    {
        return x;
    }
    return y;
}

int split(char c, char *str, char *prefix)
{
    int j = 0;
    while (str[j] != c)
        j++;
    memcpy(prefix, str, j);
    prefix[j] = '\0';
    return j + 1;
}

int main()
{
    char key[] = ":,;";
    char buf[8192];
    char *pch;
    int n;
    int game = 1;
    char tok[8192] = {0};

    int sum_1 = 0;
    int sum_2 = 0;

    FILE *fp;
    fp = fopen("second.txt", "r");
    if (fp == NULL)
    {
        printf("Not able to open the file.");
        return -1;
    }
    while (fgets(buf, sizeof buf, fp) != NULL)
    {
        int red = 0;
        int green = 0;
        int blue = 0;
        pch = strpbrk(buf, ":;,");
        while (pch != NULL)
        {
            pch += 2;
            pch += split(' ', pch, tok);
            n = atoi(tok);

            switch (pch[0])
            {
            case 'r':
                red = max(n, red);
                break;
            case 'g':
                green = max(n, green);
                break;
            case 'b':
                blue = max(n, blue);
                break;
            default:
                printf("fail: %s", pch);
                return -1;
            }
            pch = strpbrk(pch, ":;,");
        }
        if (red <= 12 && green <= 13 && blue <= 14)
            sum_1 += game;
        sum_2 += red * green * blue;
        game++;
    }
    fclose(fp);

    printf("first sum: %d\n", sum_1);
    printf("second sum: %d\n", sum_2);

    return 0;
}
