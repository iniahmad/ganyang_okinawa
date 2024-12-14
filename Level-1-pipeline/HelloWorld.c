#include <stdio.h>
#include <stdint.h>
#include "sleep.h"
#include "xparameters.h"

uint32_t *multiplier_p = (uint32_t *)XPAR_IP_VAE_PIPED_0_S00_AXI_BASEADDR;

// Fungsi untuk mengonversi float ke format binary 16-bit custom
uint16_t float_to_custom_binary(float float_value) {
    // Tentukan bit tanda (1 bit)
    uint16_t sign_bit = (float_value >= 0) ? 0 : 1;

    // Ambil nilai absolut dari float untuk pemrosesan lebih lanjut
    float abs_value = fabs(float_value);

    // Pisahkan bagian integer dan pecahan
    int integer_part = (int)abs_value;
    float fractional_part = abs_value - integer_part;

    // Buat variabel untuk menyimpan hasil akhir
    uint16_t result = 0;

    // Set bit tanda
    result |= (sign_bit << 15);

    // Konversi bagian integer ke dalam 4 bit dan masukkan ke dalam hasil (4 bit untuk integer part)
    result |= (integer_part & 0b1111) << 11;

    // Konversi bagian pecahan ke dalam 11 bit
    for (int i = 0; i < 11; i++) {
        fractional_part *= 2;
        int bit = (int)fractional_part;
        result |= (bit << (10 - i)); // Masukkan bit ke dalam hasil
        fractional_part -= bit;
    }

    return result;
}

// Fungsi untuk mengonversi custom 16-bit binary ke float
float binary_to_float(uint16_t binary_value) {
    // Ekstrak bit tanda (1 bit)
    int sign = (binary_value >> 15) & 1;

    // Ekstrak dan konversi bagian integer (bit 11-14)
    int integer_part = (binary_value >> 11) & 0b1111;

    // Ekstrak dan konversi bagian pecahan (bit 0-10)
    float fractional_part = 0.0;
    for (int i = 0; i < 11; i++) {
        if (binary_value & (1 << (10 - i))) {
            fractional_part += 1.0 / (1 << (i + 1)); // 1 / 2^(i + 1)
        }
    }

    // Gabungkan bagian integer dan pecahan
    float float_value = integer_part + fractional_part;

    // Terapkan tanda
    if (sign == 1) {
        float_value = -float_value;
    }

    return float_value;
}

// Fungsi untuk mencetak angka dalam format biner
void print_binary(unsigned int n) {
    for (int i = sizeof(n) * 8 - 1; i >= 0; i--) {
        printf("%d", (n >> i) & 1);  // Bitwise shift dan mask untuk mendapatkan setiap bit
        if (i % 4 == 0) printf(" ");  // Opsional: menambahkan spasi setiap 4 bit
    }
    printf("\n");
}

int main()
{
    printf("hello world\n");

    while (1)
    {
        // Mengisi nilai pada multiplier_p
        *(multiplier_p+0) = 0b0000100000000000;
        *(multiplier_p+1) = 0b0000000000000000;
        *(multiplier_p+2) = 0b0000100000000000;
        *(multiplier_p+3) = 0b0000000000000000;
        *(multiplier_p+4) = 0b0000100000000000;
        *(multiplier_p+5) = 0b0000000000000000;
        *(multiplier_p+6) = 0b0000100000000000;
        *(multiplier_p+7) = 0b0000000000000000;
        *(multiplier_p+8) = 0b0000100000000000;

        // Menampilkan input dalam format float
            printf("\nInput is X\n");
            printf("in0 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+0)));
            printf("in1 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+1)));
            printf("in2 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+2)));
            printf("in3 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+3)));
            printf("in4 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+4)));
            printf("in5 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+5)));
            printf("in6 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+6)));
            printf("in7 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+7)));
            printf("in8 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+8)));

            // Menampilkan output dalam format float
            printf("\nOutput:\n");
            printf("out0 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+9)));
            printf("out1 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+10)));
            printf("out2 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+11)));
            printf("out3 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+12)));
            printf("out4 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+13)));
            printf("out5 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+14)));
            printf("out6 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+15)));
            printf("out7 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+16)));
            printf("out8 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+17)));

        sleep(10);

        // Mengubah nilai lagi pada multiplier_p
        *(multiplier_p+0) = 0b0000100000000000;
        *(multiplier_p+1) = 0b0000100000000000;
        *(multiplier_p+2) = 0b0000100000000000;
        *(multiplier_p+3) = 0b0000100000000000;
        *(multiplier_p+4) = 0b0000000000000000;
        *(multiplier_p+5) = 0b0000100000000000;
        *(multiplier_p+6) = 0b0000100000000000;
        *(multiplier_p+7) = 0b0000100000000000;
        *(multiplier_p+8) = 0b0000100000000000;

        // Menampilkan input dalam format biner setelah perubahan
        printf("\nInput is O\n");
        // Menampilkan input dalam format float
            printf("in0 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+0)));
            printf("in1 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+1)));
            printf("in2 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+2)));
            printf("in3 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+3)));
            printf("in4 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+4)));
            printf("in5 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+5)));
            printf("in6 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+6)));
            printf("in7 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+7)));
            printf("in8 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+8)));

            // Menampilkan output dalam format float
            printf("\nOutput:\n");
            printf("out0 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+9)));
            printf("out1 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+10)));
            printf("out2 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+11)));
            printf("out3 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+12)));
            printf("out4 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+13)));
            printf("out5 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+14)));
            printf("out6 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+15)));
            printf("out7 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+16)));
            printf("out8 = %.4f\n", binary_to_float((uint16_t)*(multiplier_p+17)));

        sleep(10);
    }

    return 0;
}
