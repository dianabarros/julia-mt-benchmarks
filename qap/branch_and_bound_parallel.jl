import Random
import Base.Threads

include("hungarian.jl")

const RAND_MAX = 2147483647

best_costs = zeros(Int64, Threads.nthreads())
best_solutions = [Int64[] for _ in 1:Threads.nthreads()]
tasks = [Task[] for _ in 1:Threads.nthreads()]

mutable struct QAPBranch
    n::Int64
    d_mat::Matrix{Int64}
    f_mat::Matrix{Int64}
    number_of_nodes::Int64
    nonvisited_solutions::Vector{Int64}
    current_best_cost::Int64
    current_best_solution::Vector{Int64}
    number_total_of_nodes::BigInt
end 

function QAPBranch(n::Int64, d_mat::Matrix{Int64}, f_mat::Matrix{Int64}) 
    qap_branch = QAPBranch(n, d_mat, f_mat, 0, zeros(Int64, n), 0, [1:n;], BigInt(0))
    # generate_initial_solution(qap_branch)
    # calculate_total_nodes(qap_branch)
    return qap_branch
end

function solve(qap_branch::QAPBranch)
    current_solution = Vector{Int64}(undef,qap_branch.n)
    already_in_solution = fill(false, qap_branch.n)
    best_cost, best_solution = generate_initial_solution(qap_branch, current_solution, already_in_solution)
    return best_cost, best_solution
end

function calculate_total_nodes(qap_branch::QAPBranch)
    # Original code explodes on n > 20
    fator_n = BigInt(qap_branch.n)
    for i in qap_branch.n-1:-1:1
        fator_n *= i
    end
    total_nodes = BigInt(0)
    fator_i = BigInt(0)
    for i in 0:qap_branch.n
        if i == 0
            fator_i = BigInt(1)
        else
            fator_i = BigInt(i)
            for j in i-1:-1:1
                fator_i *= j
            end
        end
        total_nodes += fator_n/fator_i
    end
    qap_branch.number_total_of_nodes = total_nodes
end

function lower_bound_for_partial_solution(
    qap_branch::QAPBranch, partial_solution_size::Int64, 
    already_in_solution::Vector{Bool}, current_partial_cost::Int64
)
    remaining_facilities = qap_branch.n - partial_solution_size
    new_f = Matrix{Int64}(undef, remaining_facilities, remaining_facilities)
    new_d = Matrix{Int64}(undef, remaining_facilities, remaining_facilities)
    f_diagonal = zeros(Int64,remaining_facilities)
    d_diagonal = zeros(Int64,remaining_facilities)
    
    pointer_row = 0
    for i in partial_solution_size:qap_branch.n-1
        pointer_col = 0
        for j in partial_solution_size:qap_branch.n-1
            if i != j
                new_d[pointer_row+1,pointer_col+1] = qap_branch.d_mat[i+1,j+1]
                pointer_col += 1
            else
                d_diagonal[pointer_row+1] = qap_branch.d_mat[i+1,j+1]
            end
        end
        partial_sort = sort(new_d[i-partial_solution_size+1,1:remaining_facilities-1])
        new_d[i-partial_solution_size+1,:] = vcat(partial_sort, new_d[i-partial_solution_size+1,remaining_facilities:end])
        pointer_row += 1
    end
    
    pointer_row = 0
    for i in 0:qap_branch.n-1
        if already_in_solution[i+1]
            continue
        end
        pointer_col = 0
        for j in 0:qap_branch.n-1
            if !already_in_solution[j+1]
                if i != j
                    new_f[pointer_row+1,pointer_col+1] = qap_branch.f_mat[i+1,j+1]
                    pointer_col += 1
                else
                    f_diagonal[pointer_row+1] = qap_branch.f_mat[i+1,j+1]
                end
            end
        end
        partial_sort = sort(new_f[pointer_row+1,1:remaining_facilities-1], rev=true)
        new_f[pointer_row+1,:] = vcat(partial_sort, new_f[pointer_row+1,remaining_facilities:end])
        pointer_row += 1
    end
    
    min_prod = zeros(Int64, (remaining_facilities, remaining_facilities))
    for i in 0:remaining_facilities-1
        for j in 0:remaining_facilities-1
            for k in 0:remaining_facilities-2
                min_prod[i+1,j+1] += new_d[j+1,k+1]*new_f[i+1,k+1]
            end
        end
    end

    g = Matrix{Int64}(undef, remaining_facilities, remaining_facilities)
    for i in 0:remaining_facilities-1
        for j in 0:remaining_facilities-1
            g[i+1,j+1] = f_diagonal[i+1] * d_diagonal[j+1] + min_prod[i+1,j+1]
        end
    end
    
    lap = hungarian_least_cost(remaining_facilities,g)

    return current_partial_cost+lap
end

function generate_initial_solution(
        qap_branch::QAPBranch, current_solution::Vector{Int64}, already_in_solution::Vector{Bool}
    ) 
    global best_costs, best_solutions, task
    current_best_cost = 0
    current_best_solution = [0:qap_branch.n-1;]
    current_best_solution = Random.shuffle(current_best_solution)
    for i in 0:qap_branch.n-1
        for j in 0:qap_branch.n-1
            current_best_cost += qap_branch.f_mat[current_best_solution[i+1]+1, current_best_solution[j+1]+1] * qap_branch.d_mat[i+1,j+1]
        end
    end
    best_costs = fill(current_best_cost, Threads.nthreads())
    best_solutions = fill(current_best_solution, Threads.nthreads())

    function las_vegas_recursive_search_tree_exploring(
            qap_branch::QAPBranch, current_cost::Int64, current_solution_size::Int64,
            current_solution::Vector{Int64}, already_in_solution::Vector{Bool}
        )
        global best_costs, best_solutions
        # qap_branch.number_of_nodes += 1 #TODO
        # full solution (leaf): check if it is better than the best already found
        if current_solution_size == qap_branch.n
            if current_cost < best_costs[Threads.threadid()]
                # println("here")
                best_costs[Threads.threadid()] = current_cost
                best_solutions[Threads.threadid()] = copy(current_solution)
            end
        # empty partial solution: no need for analyzing solution feasibility
        elseif current_solution_size == 0
            for i in 0:qap_branch.n-1
                new_solution = deepcopy(current_solution)
                new_solution[1] = i
                new_already_in_solution = copy(already_in_solution)
                new_already_in_solution[i+1] = true
                spawned_task = Threads.@spawn las_vegas_recursive_search_tree_exploring(qap_branch, 0, 1, new_solution, new_already_in_solution)
                push!(tasks[Threads.threadid()], spawned_task)
            end
        # non-empty partial solution
        else
            lower_bound = 0
            lower_bound_evaluated = false
            if current_solution_size < qap_branch.n -1
                lower_bound = lower_bound_for_partial_solution(qap_branch, current_solution_size, already_in_solution, current_cost)
                lower_bound_evaluated = true
            end
            if lower_bound_evaluated && lower_bound > best_costs[Threads.threadid()]
                # qap_branch.nonvisited_solutions[current_solution_size+1] += 1 #TODO
                return
            else
                cost_increases = Pair[]
                for i in 0:qap_branch.n-1
                    if !already_in_solution[i+1]
                        cost_increase = 0
                        for j in 0:current_solution_size-1
                            cost_increase += qap_branch.d_mat[j+1, current_solution_size+1]*qap_branch.f_mat[current_solution[j+1]+1, i+1] + qap_branch.d_mat[current_solution_size+1, j+1]*qap_branch.f_mat[i+1, current_solution[j+1]+1]
                        end
                        push!(cost_increases, Pair(i, cost_increase))
                    end
                end
                sort!(cost_increases,by=x->x.second)
                remaining_facilities = qap_branch.n - current_solution_size
                first_child = 0
                if remaining_facilities > 3
                    first_child = rand(0:RAND_MAX) % div(remaining_facilities, 3)
                    tmp = cost_increases[first_child+1]
                    cost_increases[first_child+1] = cost_increases[1]
                    cost_increases[1] = tmp
                end
                for child in cost_increases
                    new_solution = deepcopy(current_solution)
                    new_solution[current_solution_size+1] = child.first
                    new_already_in_solution = copy(already_in_solution)
                    new_already_in_solution[child.first+1] = true
                    spawned_task = Threads.@spawn las_vegas_recursive_search_tree_exploring(qap_branch, current_cost + child.second,
                        current_solution_size+1, new_solution, new_already_in_solution
                        )
                    push!(tasks[Threads.threadid()], spawned_task)
                end
            end
        end
    end

    las_vegas_recursive_search_tree_exploring(qap_branch, 0, 0, current_solution, already_in_solution)
    for thread in tasks
        for task in thread
            wait(task)
        end
    end
    best_cost = minimum(best_costs)
    best_solution = best_solutions[findfirst(isequal(best_cost), best_costs)]
    return best_cost, best_solution
end