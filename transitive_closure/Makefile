FLAGS=-O3 -fopenmp -march=native

all: transitive_closure

transitive_closure: transitive_closure.c
	$(CC) $(FLAGS) transitive_closure.c -o transitive_closure

clean:
	rm transitive_closure
