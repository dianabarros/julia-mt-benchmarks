#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <sys/resource.h>
#include <errno.h>

#define NUMBER_THREADS 4

int gcd(int u, int v) {
    // Cálculo recursivo de MDC
	if (v == 0)
		return u;
	return gcd(v, u % v);
}


void friendly_numbers(long int start, long int end) {
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
    #pragma omp parallel for private(i, ii, sum, done, factor, n)
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
    #pragma omp barrier
	// Itera sobre todos os números para avaliar friendlies
    int n_result = 0;

    #pragma omp parallel for private(i, j)
    for (i = 0; i < last; i++) {
		for (j = i + 1; j < last; j++) {
			if ((num[i] == num[j]) && (den[i] == den[j])) { // Se os critérios forem cumpridos, é friendly

                #pragma omp critical
                result_a[n_result] = the_num[i]; 
				result_b[n_result++] = the_num[j];
            }
		}
	}
	
	// Liberação de memória
	free(the_num);
	free(num);
	free(den);
}

int main(int argc, char **argv) {
	long int start;
	long int end;

    omp_set_num_threads(NUMBER_THREADS);

	start = atoi(argv[1]);
	end = atoi(argv[2]);
	friendly_numbers(start, end);

	struct rusage usage;
	int ret;
	ret = getrusage(RUSAGE_SELF, &usage);
	if(ret == 0)
        printf("Memory usage: %ld kilobytes\n", usage.ru_maxrss);
    else
        printf("Error in getrusage. errno = %d\n", errno);

	return EXIT_SUCCESS;
}
