// Compiling:
// MacOs: gcc -dynamiclib -o friend_seq.dylib shared_lib_friendly_seq.c
// Linux: gcc -c -fpic shared_lib_friendly.c
//        gcc -shared -o libfriendly.so shared_lib_friendly.o
//        export LD_LIBRARY_PATH=<lib_path>:$LD_LIBRARY_PATH

#include <stdio.h>
#include <stdlib.h>

int gcd(int u, int v) {
    // Cálculo recursivo de MDC
	if (v == 0)
		return u;
	return gcd(v, u % v);
}


int friendly_numbers(long int start, long int end) {

    // Ultimo indice se começarmos do 0 no intervalo
	long int last = end - start + 1;

	// Crianção das variáveis e alocação de memória
	long int *the_num;
	the_num = (long int*) malloc(sizeof(long int) * last);
	long int *num;
	num = (long int*) malloc(sizeof(long int) * last);
	long int *den;
	den = (long int*) malloc(sizeof(long int) * last);
	long int *result_a;
	result_a = (long int*) malloc(sizeof(long int) * last);
	long int *result_b;
	result_b = (long int*) malloc(sizeof(long int) * last);

	long int i, j, factor, ii, sum, done, n;

	// Calculará e registrará a soma dos divisores
	for (i = start; i <= end; i++) {
		ii = i - start; // index começando do 0
		sum = 1 + i; // Primeira soma (1 + o proprio numero)
		the_num[ii] = i; // Registrando o numero sendo avaliado
		done = i; // Definindo o limite de parada do teste de divisor
		factor = 2; // fator divisão, que começa em 2

		// Calcula a soma dos divisores do número
		while (factor < done) {
			if ((i % factor) == 0) {
				sum += (factor + (i / factor));
				if ((done = i / factor) == factor)
					sum -= factor;
			}
			factor++;
		} // Adicionar o tempo de while, criando uma variavel e somando o tempo de rodagem de cada while


		num[ii] = sum; // Registra a soma
		den[ii] = i; // Registando o número avaliado para dividir pelo MDC
		n = gcd(num[ii], den[ii]); // Máximo divisor comum entre a soma e o número, que deve ser o prório numero
		num[ii] /= n; // Divide a soma pelo MDC
		den[ii] /= n; // Divide o número pelo MDC
	} // end for
	// Itera sobre todos os números para avaliar friendlies
    int n_result = 0;


    for (i = 0; i < last; i++) {
		for (j = i + 1; j < last; j++) {
			if ((num[i] == num[j]) && (den[i] == den[j])) { // Se os critérios forem cumpridos, é friendly
 //               #pragma omp critical

                result_a[n_result] = the_num[i];
				result_b[n_result++] = the_num[j];
                //printf("%ld e %ld sao amigos\n", the_num[i], the_num[j]);
            }
		}
	}
	
	// Liberação de memória
	free(the_num);
	free(num);
	free(den);
    return 10;
}