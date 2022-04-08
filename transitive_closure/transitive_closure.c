#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <omp.h>
#include <stdint.h>

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0') 

int nNodes;
unsigned char* graph;
int bytes_per_row;
const unsigned char c_remainder_lookup[] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01};
void warshall();
void read();
void write(FILE *fl);



void write(FILE *fl){
  int j, r;
  for (r = 0; r < nNodes; r++){
    for (j = 0; j < bytes_per_row; j++){
      fprintf( fl, BYTE_TO_BINARY_PATTERN, BYTE_TO_BINARY(graph[r * bytes_per_row + j]));
    }
    fprintf( fl, "\n");
  }
  fprintf( fl, "\n\n");
}

void read (){

  char line[50];
  char* token;
  int size = 50;

  int r;
  int c;

  while(fgets(line,size,stdin)){
    token = strtok(line," "); // split using space as divider
    if(*token == 'p') {

      token = strtok(NULL," "); // sp

      token = strtok(NULL," "); // no. of vertices
      nNodes = atoi(token);

      token = strtok(NULL," "); // no. of directed edges
      bytes_per_row = (nNodes + 7) / 8;
      graph = calloc(sizeof(unsigned char), nNodes * bytes_per_row);
      if (graph == NULL) {
        printf( "Error in graph allocation: NULL!\n");
        exit( EXIT_FAILURE);
      }

    } else if(*token == 'a'){
      token = strtok(NULL," ");
      r = atoi(token)-1;

      token = strtok(NULL," ");
      c = atoi(token)-1;
      int c_int_div = c/8;
      token = strtok(NULL," ");
      graph[bytes_per_row*r + c_int_div] = graph[bytes_per_row*r + c_int_div] | c_remainder_lookup[c%8];

    }
  }
}


void warshall(){
  int c, r, j, c_int_div;
  unsigned char column_bit;
  for (c = 0; c < nNodes; c++){
    c_int_div = c/8;
    column_bit = c_remainder_lookup[c%8];
    #pragma omp parallel for private(r, j) shared(graph, c, c_int_div, column_bit, nNodes, bytes_per_row)
    for (r = 0; r < nNodes; r++){
      if (r != c && (graph[r * bytes_per_row + c_int_div]&column_bit)){
        for (j = 0; j < bytes_per_row; j++){
          graph[r * bytes_per_row + j] = graph[r * bytes_per_row + j] | graph[c * bytes_per_row + j];
        }
      }
    }
  }
}
void warshall_old(){
  int i, j, k;
  for (k = 0; k < nNodes; k++){
    #pragma omp parallel for default(none) private(i, j) shared(graph, k, nNodes)
    for (i = 0; i < nNodes; i++){
      if (i != k && graph[i * nNodes + k]){
        for (j = 0; j < nNodes; j++)
          graph[i * nNodes + j] = graph[i * nNodes + j] || graph[k * nNodes + j];
      }
    }
  }
}


int main( int argc, char *argv[] ){
  struct timespec start, lap1, lap2, finish;
  clock_gettime(CLOCK_MONOTONIC, &start);

  read();

  clock_gettime(CLOCK_MONOTONIC, &lap1);
  write(stdout);
  clock_gettime(CLOCK_MONOTONIC, &lap2);

  warshall();

  clock_gettime(CLOCK_MONOTONIC, &finish);
  write(stdout);
  unsigned long long int time_read = (lap1.tv_sec-start.tv_sec)*1000000000 + lap1.tv_nsec - start.tv_nsec;
  unsigned long long int time_warshall = (finish.tv_sec-lap2.tv_sec)*1000000000 + finish.tv_nsec - lap2.tv_nsec;
  fprintf(stdout, "parse time:\t%llu ns\n", time_read);
  fprintf(stdout, "process time:\t%llu ns\n", time_warshall);
  free(graph);

  return 0;
}
