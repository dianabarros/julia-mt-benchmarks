const INF = Int64(1e8)

function init_global_variables(n::Int64)
    global N = n
    global max_match = 0
    global label_x = Vector{Int64}(undef,n)
    global label_y = Vector{Int64}(undef,n)
    global match_xy = fill(-1, n)
    global match_yx = fill(-1, n)
    global S = Vector{Bool}(undef,n)
    global T = Vector{Bool}(undef,n)
    global slack = Vector{Int64}(undef,n)
    global slack_causer = Vector{Int64}(undef,n)
    global prev_on_tree = Vector{Int64}(undef,n)
end

function add_to_tree(current::Int64, prev::Int64, cost::Matrix{Int64})
    global S, prev_on_tree, label_x, label_y, slack, slack_causer
    slack_for_new_node = 0
    S[current+1] = true
    prev_on_tree[current+1] = prev
    for i in 0:N-1
        slack_for_new_node = label_x[current+1] + label_y[i+1] - cost[current+1,i+1]
        if slack_for_new_node < slack[i+1]
            slack[i+1] = slack_for_new_node
            slack_causer[i+1] = current
        end
    end
end

function init_labels(cost::Matrix{Int64})
    global label_x, label_y, N, match_xy, match_yx
    label_y = zeros(Int64, N)
    label_x = fill(-INF, N)
    for i in 0:N-1
        for j in 0:N-1
            label_x[i+1] = max(label_x[i+1],cost[i+1,j+1])
        end
    end
    match_xy = fill(-1, N)
    match_yx = fill(-1, N)
end

function update_labels()
    global N, T, slack, S, label_x, label_y
    delta = INF
    for i in 0:N-1
        if !T[i+1]
            delta = min(delta, slack[i+1])
        end
    end
    for i in 0:N-1
        if S[i+1]
            label_x[i+1] -= delta
        end
        if T[i+1]
            label_y[i+1] += delta
        end
    end
end

function augment(cost::Matrix{Int64})
    global N, max_match, label_x, label_y, match_xy, match_yx, S, T, slack, slack_causer, prev_on_tree
    if max_match == N
        return
    end
    bfs_queue = Vector{Int64}(undef,N)
    queue_write = 0
    queue_reading = 0
    S = fill(false, N)
    T = fill(false, N)
    root = 0
    prev_on_tree = fill(-1, N)
    for i in 0:N-1
        if match_xy[i+1] == -1
            bfs_queue[queue_write+1] = i
            queue_write += 1
            root = i
            prev_on_tree[root+1] = -2
            S[root+1] = true
            break
        end
    end
    for i in 0:N-1
        slack[i+1] = label_x[root+1] + label_y[i+1] - cost[root+1,i+1]
        slack_causer[i+1] = root
    end

    # CPP
    # int current;
	# int i;
    current = 0
    i = 0

    while true
        while queue_reading < queue_write
            current = bfs_queue[queue_reading+1]
            queue_reading += 1
            for i in 0:N-1
                if cost[current+1,i+1] == label_x[current+1] + label_y[i+1] && !T[i+1]
                    if match_yx[i+1] == -1
                        break
                    end
                    T[i+1] = true
                    bfs_queue[queue_write+1] = match_yx[i+1]
                    queue_write += 1
                    add_to_tree(match_yx[i+1], current, cost)
                end
            end
            if i < N
                break
            end
        end
        if i < N
            break
        end
    end
    update_labels()
    queue_reading = 0
    queue_write = 0
    for i in 0:N-1
        if !T[i+1] && slack[i+1] == 0
            if match_yx[i+1] == -1
                current = slack_causer[i+1]
                break
            else    
                T[i+1] = true
                if !S[match_yx[i+1]+1]
                    bfs_queue[queue_write+1] = match_yx[i+1]
                    queue_write += 1
                    add_to_tree(match_yx[i+1], slack_causer[i+1], cost)
                end
            end
        end
        if i < N
            break
        end
    end
    if i < N
        max_match += 1
        # TODO: check wtf
        cx = current
        cy = i
        while cx != 2
            ty = match_xy[cx+1]
            match_yx[cy+1] = cx
            match_xy[cx+1] = cy
            cx = prev_on_tree[cx+1]
        end
        augment(cost)
    end
end

function hungarian_least_cost(n::Int64, matrix::Matrix{Int64})
    init_global_variables(n)
    maximum_ = -INF
    for i in 0:n
        maximum_ = max(maximum(matrix[i+1:n,:]),maximum_)
    end
    for i in 0:n-1
        for j in 0:n-1
            matrix[i+1,j+1] = maximum_ - matrix[i+1,j+1]
        end
    end
    init_labels(matrix)
    augment(matrix)
    cost = 0
    for i in 0:N-1
        cost += -(matrix[i+1,match_xy[i+1]+1]-maximum_)
    end
    return cost
end