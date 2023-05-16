/*
 * mkflash.c
 *
 *  Created on: 2023-05-13 03:15
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define FIRMWARE_SIZE_APP_0_MAX  (64 * 1024)
#define FIRMWARE_SIZE_APP_1_MAX  (64 * 1024)

int main(int argc, char *argv[])
{
    uint32_t size;
    struct stat st;
    unsigned int c;
    unsigned char buf[256];

    FILE *fd_outfile;
    FILE *fd_fw0_data;
    FILE *fd_fw0_sign;
    FILE *fd_fw1_data;
    FILE *fd_fw1_sign;

    char *outfile = argv[1];
    char *fw0_data = argv[2];
    char *fw0_sign = argv[3];
    char *fw1_data = argv[4];
    char *fw1_sign = argv[5];

    if ((fd_outfile = fopen(outfile, "wb")) < 0) {
        printf("failed to open output file: %s\n", outfile);

        return -1;
    }

    if ((fd_fw0_data = fopen(fw0_data, "rb")) < 0) {
        printf("failed to open input file: %s\n", fw0_data);

        return -1;
    }

    if ((fd_fw0_sign = fopen(fw0_sign, "rb")) < 0) {
        printf("failed to open input file: %s\n", fw0_sign);

        return -1;
    }

    if ((fd_fw1_data = fopen(fw1_data, "rb")) < 0) {
        printf("failed to open input file: %s\n", fw1_data);

        return -1;
    }

    if ((fd_fw1_sign = fopen(fw1_sign, "rb")) < 0) {
        printf("failed to open input file: %s\n", fw1_sign);

        return -1;
    }

    stat(fw0_data, &st);
    size = st.st_size;

    // firmware 0 data
    char *data_buf = calloc(1, size);
    fread(data_buf, 1, size, fd_fw0_data);
    fwrite(data_buf, 1, size, fd_outfile);
    free(data_buf);
    data_buf = NULL;

    // firmware 0 padding
    size = FIRMWARE_SIZE_APP_0_MAX - st.st_size - 4 - 256;
    data_buf = calloc(1, size);
    fwrite(data_buf, 1, size, fd_outfile);
    free(data_buf);
    data_buf = NULL;

    // firmware 0 size
    size = st.st_size;
    fwrite(&size, 1, sizeof(size), fd_outfile);

    stat(fw0_sign, &st);
    size = st.st_size;

    // firmware 0 sign
    int i = 0;
    while (fscanf(fd_fw0_sign, "%02X", (unsigned int *)&c) > 0 && i < (int)sizeof(buf)) {
        buf[i++] = (unsigned char)c;
    }
    fwrite(buf, 1, sizeof(buf), fd_outfile);

    stat(fw1_data, &st);
    size = st.st_size;

    // firmware 1 data
    data_buf = calloc(1, size);
    fread(data_buf, 1, size, fd_fw1_data);
    fwrite(data_buf, 1, size, fd_outfile);
    free(data_buf);
    data_buf = NULL;

    // firmware 1 padding
    size = FIRMWARE_SIZE_APP_1_MAX - st.st_size - 4 - 256;
    data_buf = calloc(1, size);
    fwrite(data_buf, 1, size, fd_outfile);
    free(data_buf);
    data_buf = NULL;

    // firmware 1 size
    size = st.st_size;
    fwrite(&size, 1, sizeof(size), fd_outfile);

    stat(fw1_sign, &st);
    size = st.st_size;

    // firmware 1 sign
    i = 0;
    while (fscanf(fd_fw1_sign, "%02X", (unsigned int *)&c) > 0 && i < (int)sizeof(buf)) {
        buf[i++] = (unsigned char)c;
    }
    fwrite(buf, 1, sizeof(buf), fd_outfile);

    fclose(fd_outfile);

    fclose(fd_fw0_data);
    fclose(fd_fw0_sign);
    fclose(fd_fw1_data);
    fclose(fd_fw1_sign);

    return 0;
}
