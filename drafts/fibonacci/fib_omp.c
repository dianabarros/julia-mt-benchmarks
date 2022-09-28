#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include <sys/time.h>
// #include <time.h>
#include <omp.h>

// #define MAX 20000
#define MAX 50000
#define LEN 25000

char seq[MAX][LEN];

void printarSeq(int ate){
	int tamanho = 0;
	for (int i = 0; i<ate+1 ; i++){
		tamanho = strlen(seq[i]);
		for (int k = tamanho-1; k>=0 ; k--){
			printf("%c",seq[i][k]);
		}
		printf("\n");
	}
}

double principal() {
	double tempoInicial,tempoFinal;
	int n, k, len,i;
	int aux, s;
	int a,b;

	tempoInicial = omp_get_wtime();
	seq[0][0] = '0';
	seq[0][1] = '\0';
	seq[1][0] = '1';
	seq[1][1] = '\0';
	
	#pragma omp parallel private(n,k,len,i,aux,s,a,b) shared(seq)
	{
		#pragma omp for 
		for (k = 2; k < MAX; k++){
			a= k-1;
			b= k-2;

			for (i = 0, aux = 0; seq[a][i] != '\0' && seq[b][i] != '\0'; i++) {
				s = seq[a][i] + seq[b][i] + aux - '0' - '0';
				aux = s / 10;
				seq[a + 1][i] = s % 10 + '0';
			}

			while (seq[a][i] != '\0') {
				s = seq[a][i] + aux - '0';
				aux = s / 10;
				seq[a + 1][i] = s % 10 + '0';
				i++;
			}

			while (seq[b][i] != '\0') {
				s = seq[b][i] + aux - '0';
				aux = s / 10;
				seq[a + 1][i] = s % 10 + '0';
				i++;
			}

			if (aux != 0)
				seq[a + 1][i++] = aux + '0';
			seq[a + 1][i] = '\0';
		}
	}

	tempoFinal = omp_get_wtime();
	tempoFinal = tempoFinal - tempoInicial;

	printf("Tempo de execucao: %.3f s\n",tempoFinal);
	fflush(stdout);
	return tempoFinal;
}


int main () {
	double soma=0;
	int repeticao = 10;
	int numThreads = 8;
	// for (;numThreads>0;numThreads--){
		// omp_set_num_threads(numThreads);
		// printf("numThreads: %d \n",numThreads);
		for (int i=0;i<repeticao;i++)
			soma = soma + principal();		
		printf("Media: %.3f s\n",soma/repeticao);
        printarSeq(10);
	// }
	return 1;
}