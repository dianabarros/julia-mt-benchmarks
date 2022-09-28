#include <iostream>
#include <algorithm>    // std::sort
#include <vector>       // std::vector
#include <fstream>
#include <climits> // std:;INT_MAX
#include <functional> // std::greater<int>

#define INF 1e8

using namespace std;

int n;
int** d_mat;
int** f_mat;

int N;
int max_match;
int* label_x;
int* label_y;
int* match_xy;
int* match_yx;
bool* S;
bool* T;
int* slack;
int* slack_causer;
int* prev_on_tree;

void read_instance( std::string instance_name )
{
	std::ifstream instance_stream (instance_name);
	if (instance_stream.is_open())
	{
		instance_stream >> n;
		d_mat = new int*[n];
		f_mat = new int*[n];
		for(int i = 0; i < n; ++i)
		{
			d_mat[i] = new int[n];
			f_mat[i] = new int[n];
		}
		for(int i = 0; i < n; ++i)
			for(int j = 0; j < n; ++j)
				instance_stream >> d_mat[i][j];

		for(int i = 0; i < n; ++i)
			for(int j = 0; j < n; ++j)
				instance_stream >> f_mat[i][j];
		
		instance_stream.close();
	}
	else 
	{
		std::cout << "Unable to open instance " << instance_name << std::endl;
		exit(0);
	}
}


void print_matrix(int** matrix, int size){
    for(int i=0; i<size;i++){
        for(int j=0;j<size;j++)
            cout<<matrix[i][j]<<" ";
        cout<<endl;
    }
}

void print_vec(int* vec, int size){
    for(int i=0; i<size;i++)
        cout<<vec[i]<<" ";
    cout<<endl;
}

void print_vec(bool* vec, int size){
    for(int i=0; i<size;i++)
        cout<<vec[i]<<" ";
    cout<<endl;
}



void deallocate_global_variables()
{
	delete[] label_x;
	delete[] label_y;
	delete[] match_xy;
	delete[] match_yx;
	delete[] S;
	delete[] T;
	delete[] slack;
	delete[] slack_causer;
	delete[] prev_on_tree;
}

void init_global_variables(int n)
{
	N = n;
	max_match = 0;
	label_x = new int[n];
	label_y = new int[n];
	match_xy = new int[n];
	match_yx = new int[n];
	S = new bool[n];
	T = new bool[n];
	slack = new int[n];
	slack_causer = new int[n];
	prev_on_tree = new int[n];

	std::fill(match_xy, match_xy+N, -1);
	std::fill(match_yx, match_yx+N, -1);	
}

void add_to_tree(int current, int prev, int** cost)
{
	int slack_for_new_node;

	// adds the current vertex to S
	S[current] = true;

	prev_on_tree[current] = prev;

	// update slacks since we added a vertex to S
	for(int i = 0; i < N; ++i)
	{
		slack_for_new_node = label_x[current] + label_y[i] - cost[current][i];

		if(slack_for_new_node < slack[i])
		{
			slack[i] = slack_for_new_node;
			slack_causer[i] = current;
		}
	}
}

void init_labels(int** cost)
{
	std::fill(label_y, label_y+N, 0);
	std::fill(label_x, label_x+N, -INF);

	for(int i = 0; i < N; ++i)
		for(int j = 0; j < N; ++j)
			label_x[i] = std::max(label_x[i], cost[i][j]);

	std::fill(match_xy, match_xy+N, -1);
	std::fill(match_yx, match_yx+N, -1);
}

void update_labels()
{
	int delta = INF;

	// find delta
	for(int i = 0; i < N; ++i)
	{
		// "i" is in X\T
		if(!T[i])
			delta = std::min(delta, slack[i]);
	}

	// update labels
	for(int i = 0; i < N; ++i)
	{
		if(S[i])
			label_x[i] -= delta; 

		if(T[i])
			label_y[i] += delta;
	}

	// update slacks
	for(int i = 0; i < N; ++i)
	{
		if(!T[i])
			slack[i] -= delta;
	}
}

void augment(int** cost)
{
	if(max_match == N)
		return;

	// queue for BFS
	int* bfs_queue = new int[N];

	// index for writing in the BFS queue
	int queue_write = 0;

	// index for reading in the BFS queue
	int queue_reading = 0;

	// clear S and T
	std::fill(S, S+N, false);
	std::fill(T, T+N, false);

	int root;

	// clear alternating tree
	std::fill(prev_on_tree, prev_on_tree+N, -1);

	// looks for an exposed vertex
	for(int i = 0; i < N; ++i)
	{
		//exposed vertex in X: add it to S, make it the root of the tree, add it to the BFS queue
		if(match_xy[i] == -1)
		{
			bfs_queue[queue_write++] = i;
			root = i;
			prev_on_tree[root] = -2;
			S[root] = true;
			break;
		}
	}

	// update slacks (X = {x}, so it's the slack causer for everyone in Y)
	for(int i = 0; i < N; ++i)
	{
		slack[i] = label_x[root] + label_y[i] - cost[root][i];
		slack_causer[i] = root;
	}

	int current;
	int i;

	while(true)
	{
		// build tree with bfs
		while(queue_reading < queue_write)
		{
			current = bfs_queue[queue_reading++];

			// iterates over the (current,i) edges of the equality subgraph that aren't in T
			for(i = 0; i < N; ++i)

				if(cost[current][i] == label_x[current] + label_y[i] && !T[i])
				{
					// "i" vertex is exposed on Y: an augmenting path was found
					if(match_yx[i] == -1)
						break;

					// adds "i" to T
					T[i] = true;

					// adds the match of "i" to the queue
					bfs_queue[queue_write++] = match_yx[i];

					// adds the edges (current,i) and (i,match_yx[i]) to the alternating tree
					add_to_tree(match_yx[i], current, cost);
				}
	
			// augmenting path found				
			if(i < N) 
				break;
		}

		// augmenting path found
		if(i < N)
			break;

		// improve the labels
		update_labels();

		queue_reading = 0;
		queue_write = 0;

		for(i = 0; i < N; ++i)
			// edges added to the equality subgraph after the label improving
			if(!T[i] && slack[i] == 0)
			{
				// "i" is exposed in Y: augmenting path found
				if(match_yx[i] == -1)
				{
					current = slack_causer[i];
					break;
				}

				// "i" is not exposed
				else
				{
					// adds "i" to T
					T[i] = true;

					if(!S[ match_yx[i] ])
					{
						// adds the match of "i" to the queue
						bfs_queue[queue_write++] = match_yx[i];

						add_to_tree(match_yx[i], slack_causer[i], cost);
					}
				}	
			}

		// augmenting path found
		if(i < N)
			break;
	}

	// augmenting path found
	if(i < N)
	{
		// increment the matching in one edge
		++max_match;

		// invert the edges along the path
		for (int cx = current, cy = i, ty; cx != -2; cx = prev_on_tree[cx], cy = ty)
		{
			ty = match_xy[cx];
			match_yx[cy] = cx;
			match_xy[cx] = cy;
		}

		// try to augment again
		augment(cost);
	}

	delete[] bfs_queue;
}

int hungarian_least_cost(int n, int** matrix)
{
	init_global_variables(n);

	int maximum = -INF;
	for(int i = 0; i < n; ++i)
		maximum = std::max(*std::max_element(matrix[i], matrix[i]+n), maximum);

	for(int i = 0; i < n; ++i)
		for(int j = 0; j < n; ++j)
				matrix[i][j] = maximum - matrix[i][j];

	// cout << "LAP MATRIX" << endl;
	// for(int i = 0; i < n; ++i) {
	// 	for(int j = 0; j < n; ++j) cout << matrix[i][j] << " ";
	// 	cout << endl;
	// }

	init_labels(matrix);
	augment(matrix);

	int cost = 0;

	// print matching
	for(int i = 0; i < N; ++i)
	{
		cost += -(matrix[i][match_xy[i]]-maximum);
		//cost += matrix[i][match_xy[i]];
		//std::cout << "(" << i << ", " << match_xy[i] << ")\n";
		
	}

	deallocate_global_variables();	

	return cost;

}




class QAPBranch
{

private:

	long long number_total_of_nodes;

	int number_of_nodes;

	/* Number of facilities/locations */
	int n;

	/* Matrix of flows between facilities */
	int** f_mat;

	/* Matrix of distances between locations */
	int** d_mat;

	int* nonvisited_solutions;

	/* Best assignment that the algorithm have found so far. It consists of a
	 * n-dimensional permutation vector in which the i-th element corresponds
	 * to the facility assigned to the i-th location */
	int* current_best_solution;

	/* Cost associated to the best assignment encountered so far  */
	int current_best_cost;

	int total_non_visited_nodes;

	/**
	 * @brief      Generates a initial solution (i.e., a permutation vector),
	 *             that will define the first upper bound used in the main
	 *             algorithm
	 */
	void generate_initial_solution();


	/**
	 * @brief      Defines a lower bound from a partially built solution. The
	 *             lower bound consists of a value such that when the solution
	 *             is fully built, if its cost exceeds that value, it should be
	 *             discarded since it won't yield an optimal solution.
	 *
	 * @param[in]  partial_solution_size  The number of facilities already allocated in the current solution
	 * @param      already_in_solution    Bool array to check if a given facility is in the solution
	 * @param[in]  current_partial_cost   The cost of the solution so far
	 *
	 * @return     the lower bound of the current partial solution
	 */
	int lower_bound_for_partial_solution(int partial_solution_size, bool* already_in_solution, int current_partial_cost);

	/**
	 * @brief      Explores a given node of the search tree, corresponding to a
	 *             partial solution for the prpblem.
	 *
	 * @param[in]  current_cost           Cost of the solution
	 * @param[in]  current_solution_size  Number of facilities already assigned
	 * @param      current_solution       n-dimensional permutation vector
	 *                                    corresponding to the partial solution
	 * @param      already_in_solution    n-dimensional vector in which the i-th
	 *                                    position is true iff the i-th
	 *                                    facilitiy was assigned to a location
	 *                                    already
	 */


	void las_vegas_recursive_search_tree_exploring(int current_cost, int current_solution_size, 
										 int* current_solution, bool* already_in_solution);

public:

	/**
	 * @brief      Constructs the object.
	 *
	 * @param[in]  n      Number of facilities/locations
	 * @param      d_mat  Distance matrix
	 * @param      f_mat  Flux matrix
	 */
	QAPBranch(int n, int** d_mat, int** f_mat);

	/**
	 * @brief      Destroys the object.
	 */
	~QAPBranch();

	/**
	 * @brief      Finds the optimal permutation vector for the problem.
	 */
	void solve();

	/**
	 * @brief      Gets the best solution found so far.
	 *
	 * @return    The best solution so far.
	 */
	int* get_current_best_solution();

	/**
	 * @brief      Gets the cost corresponding to the best solution so far.
	 *
	 * @return     The cost of the best solution so far.
	 */
	int get_current_best_cost();

	int get_number_of_nodes();

	int* get_non_visited_nodes();

	int get_total_non_visited_nodes();

	void calculate_non_visited_nodes();

	void calculate_total_nodes();

	double percential_non_visited_node ();

};


QAPBranch::QAPBranch(int n, int** d_mat, int** f_mat)
{
	this->n = n;
	this->d_mat = d_mat;
	this->f_mat = f_mat;
	this->number_of_nodes = 0;

	this->generate_initial_solution();	
	this->calculate_total_nodes();

	this->nonvisited_solutions = new int[n];
	std::fill(nonvisited_solutions, nonvisited_solutions+n, 0);
}

QAPBranch::~QAPBranch()
{
	delete[] this->current_best_solution;
	delete[] this->nonvisited_solutions;
}

void QAPBranch::solve()
{
	int* current_solution = new int[n];

	bool* already_in_solution = new bool[n];
	std::fill(already_in_solution, already_in_solution+n, false);

	this->las_vegas_recursive_search_tree_exploring(0, 0, current_solution, already_in_solution);

	delete[] current_solution;
	delete[] already_in_solution;
}


// TO-DO
void QAPBranch::generate_initial_solution()
{
	this->current_best_cost = 0;
	this->current_best_solution = new int[this->n];

	for(int i = 0; i < this->n; ++i)
		this->current_best_solution[i] = i;

	std::random_shuffle(this->current_best_solution, this->current_best_solution + this->n);
	for(int i = 0; i < this->n; ++i)
		cout << this->current_best_solution[i] << " ";
	cout << endl;

	for(int i = 0; i < this->n; ++i)
	{
		for(int j = 0; j < this->n; ++j)
		{
			this->current_best_cost += this->f_mat[this->current_best_solution[i]][this->current_best_solution[j]] 
			*this->d_mat[i][j];
		}
	}
}	

// TO-DO
int QAPBranch::lower_bound_for_partial_solution(int partial_solution_size, bool* already_in_solution, int current_partial_cost)
{	
	int remaining_facilities = this->n - partial_solution_size;
	int** new_f = new int*[remaining_facilities];
	int** new_d = new int*[remaining_facilities];
	int* f_diagonal = new int[remaining_facilities];
	int* d_diagonal = new int[remaining_facilities];

	for(int i = 0; i < remaining_facilities; ++i)
	{
		new_f[i] = new int[remaining_facilities-1];
		new_d[i] = new int[remaining_facilities-1];
	}

	int pointer_row = 0, pointer_col;
	for(int i = partial_solution_size; i < this->n; ++i)
	{
		pointer_col = 0;

		for(int j = partial_solution_size; j < this->n; ++j)
			if(i != j)
				new_d[pointer_row][pointer_col++] = this->d_mat[i][j];
			else
				d_diagonal[pointer_row] = this->d_mat[i][j];

		std::sort(new_d[i-partial_solution_size], new_d[i-partial_solution_size] + remaining_facilities -1);

		++pointer_row;
	}

	pointer_row = 0;
	for(int i = 0; i < this->n; ++i)
	{
		if(already_in_solution[i])
			continue;

		pointer_col = 0;

		for(int j = 0; j < this->n; ++j)
			if(!already_in_solution[j])
			{
				if(i != j)
					new_f[pointer_row][pointer_col++] = this->f_mat[i][j];
				else
					f_diagonal[pointer_row] = this->f_mat[i][j];
			}

		std::sort(new_f[pointer_row], new_f[pointer_row] + remaining_facilities-1, std::greater<int>());

		++pointer_row;
	}

	int** min_prod = new int*[remaining_facilities];
	for(int i = 0; i < remaining_facilities; ++i)
	{
		min_prod[i] = new int[remaining_facilities];
		std::fill(min_prod[i], min_prod[i] + remaining_facilities, 0);
	}

	for(int i = 0; i < remaining_facilities; ++i)
		for(int j = 0; j < remaining_facilities; ++j)
			for(int k = 0; k < remaining_facilities-1; ++k)
				min_prod[i][j] += new_d[j][k]*new_f[i][k];

	int** g = new int*[remaining_facilities];

	for(int i = 0; i < remaining_facilities; ++i)
	{
		g[i] = new int[remaining_facilities];

		for(int j = 0; j < remaining_facilities; ++j)
		 	g[i][j] = f_diagonal[i] * d_diagonal[j] + min_prod[i][j];
	}

	int lap = hungarian_least_cost(remaining_facilities, g);
	// std::cout << "lap: " << lap << std::endl;

	for(int i = 0; i < remaining_facilities; ++i)
	{
		delete[] new_f[i];
		delete[] new_d[i];
		delete[] g[i];
		delete[] min_prod[i];
	}

	delete[] new_f;
	delete[] new_d;
	delete[] g;
	delete[] min_prod;
	delete[] f_diagonal;
	delete[] d_diagonal;

	return current_partial_cost+lap;
}

int* QAPBranch::get_current_best_solution()
{
	return this->current_best_solution;
}

int QAPBranch::get_current_best_cost()
{
	return this->current_best_cost;
}

int QAPBranch::get_number_of_nodes()
{
	return this->number_of_nodes;
}

int* QAPBranch::get_non_visited_nodes()
{
	return this->nonvisited_solutions;
}

void QAPBranch::calculate_non_visited_nodes()
{
	this->total_non_visited_nodes = 0;

	for(int p = n-2; p >= 0; --p)
	{
		int total_per_node = 0;
		int parcel = p+1;
		int factor = p;

		for(int i = 1; i <= p+1; ++i)
		{
			total_per_node += parcel;
			parcel *= (factor--);
		}

		this->total_non_visited_nodes += total_per_node * this->nonvisited_solutions[p];
	}
}

int QAPBranch::get_total_non_visited_nodes()
{
	return this->total_non_visited_nodes;
}


void QAPBranch::las_vegas_recursive_search_tree_exploring(int current_cost, int current_solution_size, 
										 int* current_solution, bool* already_in_solution)
{
	++this->number_of_nodes;
	// std::cout << "\nnode: #" << this->number_of_nodes << "\n";
	// std::cout << "current_cost: " << current_cost << std::endl;
	// std::cout << "best_cost: " << this->current_best_cost << std::endl;
	// std::cout << "solution:";
	// for(int i = 0; i < current_solution_size; ++i) std::cout << " " <<current_solution[i];
	// std::cout << "\n";

	// full solution (leaf): check if it is better than the best already found
	if(current_solution_size == n)
	{
		// current solution is better: update best solution
		if(current_cost < this->current_best_cost)
		{
			this->current_best_cost = current_cost;

			std::copy(current_solution, current_solution+n, this->current_best_solution);
		}
	}

	// empty partial solution: no need for analyzing solution feasibility
	else if(current_solution_size == 0)
	{
		for(int i = 0; i < this->n; ++i)
		{
			current_solution[0] = i;
			already_in_solution[i] = true;

			this->las_vegas_recursive_search_tree_exploring(0, 1, current_solution, already_in_solution);

			already_in_solution[i] = false;
		}
		
	}

	// non-empty partial solution
	else
	{
		int lower_bound;
		bool lower_bound_evaluated = false;

		if(current_solution_size < this->n-1)
		{
			// analyze solution feasibility
			lower_bound = this->lower_bound_for_partial_solution(current_solution_size, already_in_solution, current_cost);
			// std::cout << "lower_bound:" << lower_bound << std::endl;
			lower_bound_evaluated = true;
		}

		// current solution can't get better than the best known so far: its
		// branch must be pruned off
		if(lower_bound_evaluated && lower_bound > this->current_best_cost)
		{
			++this->nonvisited_solutions[current_solution_size];
			// std::cout << "---------------------------------\n";
			// std::cout << "NÃO ABRIU UM NÓ!!!\n";
			// std::cout << "---------------------------------\n";
			return;
		}

		// explore the current node's children
		else
		{	
			std::vector<std::pair<int, int> > cost_increases;

			for(int i = 0; i < this->n; ++i)
			{
				if(!already_in_solution[i])
				{
					// compute the cost increase, i.e., the product d_{a,b}*f_{pi(a), pi(b)}
					// for all 0 <= a,b < n such that a,b<=current_solution_size
					int cost_increase = 0;
					for(int j = 0; j < current_solution_size; ++j)
						cost_increase += d_mat[j][current_solution_size]*f_mat[current_solution[j]][i]
									   + d_mat[current_solution_size][j]*f_mat[i][current_solution[j]];

					cost_increases.push_back(std::make_pair(i, cost_increase));
				}
			}

			// order children by cost_increase
			std::sort(cost_increases.begin(), cost_increases.end(), [](auto& p1, auto& p2){
				return p1.second < p2.second;
			});

			int remaining_facilities = this->n - current_solution_size;
			int first_child;

			if(remaining_facilities > 3)
			{
				first_child = rand() % (remaining_facilities / 3);
				std::iter_swap(cost_increases.begin(), cost_increases.begin() + first_child);
			}

			for(std::pair<int, int> child : cost_increases)
			{
				// the i-th facility is assigned to the (current_solution_size)-th location
				current_solution[current_solution_size] = child.first;
				already_in_solution[child.first] = true;

				// explore the subsolution branch
				this->las_vegas_recursive_search_tree_exploring(current_cost + child.second, current_solution_size+1, current_solution, already_in_solution);

				// removes the element of the solution to analyze its siblings
				already_in_solution[child.first] = false;
			}
		}	
	}
}

void QAPBranch::calculate_total_nodes()
{
	long long fator_n = n;
	for (int i=n-1; i >= 1; i--)
		fator_n *= i;

	long long total_nodes = 0;
	long long fator_i;
	for (int i=0; i <= n; i++)
	{
		if ( i == 0 ) fator_i = 1;
		else
		{
			fator_i = i;
			for (int j=i-1; j >= 1; j--)
				fator_i *= j;
		}
		
		total_nodes += fator_n/fator_i;
	}

	this->number_total_of_nodes = total_nodes;
}

double QAPBranch::percential_non_visited_node ()
{
	double percential;

	percential = 100.00 - (100.00 * number_of_nodes)/number_total_of_nodes;
	return percential;
}

int main() {
	// INIT TESTS //
	// N = 4;
	// bool S_init[] = {false, true, false, true};
	// S = S_init;
	// bool T_init[] = {true, false, true, false};
	// T = T_init;
	// int slack_init[] = {132, 429, 234, 212};
	// slack = slack_init;
	// int label_x_init[] = {185, 74, 194, 143};
	// label_x = label_x_init;
	// int label_y_init[] = {370, 324, 75, 207};
	// label_y = label_y_init;
	//  ------------------------------------------------  //

    read_instance("/Users/diana.barros/Documents/QAP-algorithms/instances/beth.dat");
	// read_instance("/Users/diana.barros/Documents/julia-mt-benchmarks/qap/test.dat");
	QAPBranch qap_branch = QAPBranch( n,  d_mat,  f_mat);

	qap_branch.solve();

	// int* current_solution = new int[n];
	// bool* already_in_solution = new bool[n];
	// std::fill(already_in_solution, already_in_solution+n, false);


	// qap_branch.las_vegas_recursive_search_tree_exploring(0, 0, current_solution, already_in_solution);
	// delete[] current_solution;
	// delete[] already_in_solution;

	cout << "Number of visited nodes: " << qap_branch.number_of_nodes << endl << "Solution found: ";
	print_vec(qap_branch.current_best_solution, 4);

	
   return 0;
}