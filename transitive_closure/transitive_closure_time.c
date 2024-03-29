// MacOS compile
// /usr/local/opt/llvm/bin/clang -fopenmp -L/usr/local/opt/llvm/lib transitive_closure_time.c -o tct

#include <stdio.h>
#include <stdlib.h>
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


int main( int argc, char *argv[] ){

  read();

  double start_time; 
	double end_time; 
	start_time = omp_get_wtime(); 
  warshall();
  end_time = omp_get_wtime(); 
  printf("%F\n", (end_time-start_time)*1000000);

  free(graph);

  return 0;
}
