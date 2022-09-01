#include <stdio.h>
#include <stdlib.h>
#include <openssl/md5.h>
#include <string.h>
#include <sys/time.h>
#include <omp.h>

#define MAX 10

int isOver = 0;
char letters[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
/*
 * Print a digest of MD5 hash.
*/
// void print_digest(unsigned char * hash){
// 	int x;

// 	for(x = 0; x < MD5_DIGEST_LENGTH; x++)
//         	printf("%02x", hash[x]);
// 	printf("\n");
// }


/*
 * Convert hexadecimal string to hash byte.
*/
void strHex_to_byte(char * str, unsigned char * hash){
	char * pos = str;
	int i;

	for (i = 0; i < MD5_DIGEST_LENGTH/sizeof *hash; i++) {
		sscanf(pos, "%2hhx", &hash[i]);
		pos += 2;
	}
}

int main(int argc, char **argv) {
	char str[MAX+1];
	int lenMax = MAX;
	int len;
	int c, v, b, c1, v1, b1, c2, v2, b2, c3, v3;
	int ok = 0, r, idx = 0;
	int isOver2 = 0;
	char hash1_str[2*MD5_DIGEST_LENGTH+1];
	double end;
	double start;
	
	// struct timeval tstart, tend, tstart2, tend2;
	unsigned char hash1[MD5_DIGEST_LENGTH]; // password hash
	unsigned char hash2[MD5_DIGEST_LENGTH]; // string hashes
	unsigned char digest[16];
	unsigned char digest2[16];

	// Input:
	// r = scanf("%s", hash1_str);

	// Check input.
	// if (r == EOF || r == 0)
	// {
	// 	fprintf(stderr, "Error!\n");
	// 	exit(1);
	// }
	
	// gettimeofday(&tstart, NULL);
	
	if (strlen(argv[1]) < sizeof(hash1_str)) {
		strcpy(hash1_str, argv[1]);
	} else {
		printf("aaaaaa");
		exit(1);
	}
	strHex_to_byte(hash1_str, hash1);
	memset(hash2, 0, MD5_DIGEST_LENGTH);
	// Generate all possible passwords of different sizes.

	////Senhas com 1 caracter
	memset(str, 0, 2);
	for (c = 0; c < strlen(letters); ++c) {
		str[0] = letters[c];
		MD5((unsigned char *) str, strlen(str), hash2);
		if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
			// printf("found: %s\n", str);
			isOver = 1;
		}
	}

    //Senhas com 2 caracteres
	memset(str, 0, 3);
	for (c = 0; c < strlen(letters) && (isOver == 0); ++c) {
		str[0] = letters[c];
		for (v = 0; v < strlen(letters) && (isOver == 0); ++v) {
			str[1] = letters[v];
			MD5((unsigned char *) str, strlen(str), hash2);
			if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
				// printf("found: %s\n", str);
				isOver = 1;
			}
		}
	}

	//Senhas com 3 caracteres
	memset(str, 0, 4);
	for (c = 0; c < strlen(letters) && (isOver == 0); ++c) {
		str[0] = letters[c];
		for (v = 0; v < strlen(letters) && (isOver == 0); ++v) {
			str[1] = letters[v];
			for (b = 0; b < strlen(letters) && (isOver == 0); ++b) {
				str[2] = letters[b];
				MD5((unsigned char *) str, strlen(str), hash2);
				if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
					// printf("found: %s\n", str);
					isOver = 1;
				}
			}
		}
	}
	
	// omp_set_num_threads(12);
	if (isOver == 0) {
	//Senhas com 4 caracteres
	// # pragma omp parallel private(str, c, v, b, c1, v1, b1, c2, v2, b2, c3, v3, hash2) shared(letters, hash1_str, hash1, isOver)
	{
		// printf("This is thread number: %d\n", omp_get_thread_num());
		memset(str, 0, 5);
		#pragma omp for
		for (c = 0; c < strlen(letters); ++c) {
			str[0] = letters[c];
			if (isOver == 0) {
				for (v = 0; v < strlen(letters); ++v) {
					str[1] = letters[v];
					if (isOver == 0) {
						for (b = 0; b < strlen(letters); ++b) {
							str[2] = letters[b];
							if (isOver == 0) {
								for (c1 = 0; c1 < strlen(letters); ++c1){
									str[3] = letters[c1];
									MD5((unsigned char *) str, strlen(str), hash2);
									if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
										// printf("found: %s\n", str);
										#pragma omp critical
										isOver = 1;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	}
		
	if (isOver == 0) {
	//Senhas com 5 caracteres
	// # pragma omp parallel private(str, c, v, b, c1, v1, b1, c2, v2, b2, c3, v3, hash2) shared(letters, hash1_str, hash1, isOver)
	{
		//Senhas com 5 caracteres
		memset(str, 0, 6);
		#pragma omp for
		for (c = 0; c < strlen(letters); ++c) {
			str[0] = letters[c];
			if (isOver == 0) {
				for (v = 0; v < strlen(letters); ++v) {
					str[1] = letters[v];
					if (isOver == 0) {
						for (b = 0; b < strlen(letters); ++b) {
							str[2] = letters[b];
							if (isOver == 0) {
								for (c1 = 0; c1 < strlen(letters); ++c1){
									str[3] = letters[c1];
									if (isOver == 0) {
										for (v1 = 0; v1 < strlen(letters); ++v1){
											str[4] = letters[v1];
											MD5((unsigned char *) str, strlen(str), hash2);
											if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
												// printf("found: %s\n", str);
												#pragma omp critical
												isOver = 1;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	}

	if (isOver == 0) {
	//Senhas com 6 caracteres
	// # pragma omp parallel private(str, c, v, b, c1, v1, b1, c2, v2, b2, c3, v3, hash2) shared(letters, hash1_str, hash1, isOver)
	{
			//Senhas com 6 caracteres
			memset(str, 0, 7);
			#pragma omp for
			for (c = 0; c < strlen(letters); ++c) {
				str[0] = letters[c];
				if (isOver == 0) {
					for (v = 0; v < strlen(letters); ++v) {
						str[1] = letters[v];
						if (isOver == 0) {
							for (b = 0; b < strlen(letters); ++b) {
								str[2] = letters[b];
								if (isOver == 0) {
									for (c1 = 0; c1 < strlen(letters); ++c1){
										str[3] = letters[c1];
										if (isOver == 0) {
											for (v1 = 0; v1 < strlen(letters); ++v1){
												str[4] = letters[v1];
												if (isOver == 0) {
													for (b1 = 0; b1 < strlen(letters); ++b1){
														str[5] = letters[b1];
														MD5((unsigned char *) str, strlen(str), hash2);
														if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
															// printf("found: %s\n", str);
															#pragma omp critical
															isOver = 1;
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
	}
	}
	
	if (isOver == 0) {
	//Senhas com 7 caracteres
	// # pragma omp parallel private(str, c, v, b, c1, v1, b1, c2, v2, b2, c3, v3, hash2) shared(letters, hash1_str, hash1, isOver)
	{
			//Senhas com 7 caracteres
			memset(str, 0, 8);
			#pragma omp for
			for (c = 0; c < strlen(letters); ++c) {
				str[0] = letters[c];
				if (isOver == 0) {
					for (v = 0; v < strlen(letters); ++v) {
						str[1] = letters[v];
						if (isOver == 0) {
							for (b = 0; b < strlen(letters); ++b) {
								str[2] = letters[b];
								if (isOver == 0) {
									for (c1 = 0; c1 < strlen(letters); ++c1){
										str[3] = letters[c1];
										if (isOver == 0) {
											for (v1 = 0; v1 < strlen(letters); ++v1){
												str[4] = letters[v1];
												if (isOver == 0) {
													for (b1 = 0; b1 < strlen(letters); ++b1){
														str[5] = letters[b1];
														if (isOver == 0) {
															for (c2 = 0; c2 < strlen(letters); ++c2){
																str[6] = letters[c2];
																MD5((unsigned char *) str, strlen(str), hash2);
																if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
																	// printf("found: %s\n", str);
																	#pragma omp critical
																	isOver = 1;
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
	}
	}
	//Senhas com 8 caracteres
	if (isOver == 0) {
		
	// # pragma omp parallel private(str, c, v, b, c1, v1, b1, c2, v2, b2, c3, v3, hash2) shared(letters, hash1_str, hash1, isOver)
	{
			//Senhas com 8 caracteres
			memset(str, 0, 9);
			#pragma omp for
			for (c = 0; c < strlen(letters); ++c) {
				str[0] = letters[c];
				if (isOver == 0) {
					for (v = 0; v < strlen(letters); ++v) {
						str[1] = letters[v];
						if (isOver == 0) {
							for (b = 0; b < strlen(letters); ++b) {
								str[2] = letters[b];
								if (isOver == 0) {
									for (c1 = 0; c1 < strlen(letters); ++c1){
										str[3] = letters[c1];
										if (isOver == 0) {
											for (v1 = 0; v1 < strlen(letters); ++v1){
												str[4] = letters[v1];
												if (isOver == 0) {
													for (b1 = 0; b1 < strlen(letters); ++b1){
														str[5] = letters[b1];
														if (isOver == 0) {
															for (c2 = 0; c2 < strlen(letters); ++c2){
																str[6] = letters[c2];
																if (isOver == 0) {
																	for (v2 = 0; v2 < strlen(letters); ++v2){
																		str[7] = letters[v2];
																		MD5((unsigned char *) str, strlen(str), hash2);
																		if((strncmp((char*)hash1, (char*)hash2, MD5_DIGEST_LENGTH)) == 0){
																			// printf("found: %s\n", str);
																			#pragma omp critical
																			isOver = 1;
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
	}
	}
	// gettimeofday(&tend, NULL);
	// printf("Tempo de execução: %ld microseconds\n", ((tend.tv_sec * 1000000 + tend.tv_usec) - (tstart.tv_sec * 1000000 + tstart.tv_usec)));
	exit(0);
}
