const INF = Int64(1e8)

mutable struct GlobalVariables
    N::Int64
    max_match::Int64
    label_x::Vector{Int64}
    label_y::Vector{Int64}
    match_xy::Vector{Int64}
    match_yx::Vector{Int64}
    S::Vector{Bool}
    T::Vector{Bool}
    slack::Vector{Int64}
    slack_causer::Vector{Int64}
    prev_on_tree::Vector{Int64}
end

function GlobalVariables(n::Int64)
    N = n
    max_match = 0
    label_x = Vector{Int64}(undef,n)
    label_y = Vector{Int64}(undef,n)
    match_xy = fill(-1, n)
    match_yx = fill(-1, n)
    S = Vector{Bool}(undef,n)
    T = Vector{Bool}(undef,n)
    slack = Vector{Int64}(undef,n)
    slack_causer = Vector{Int64}(undef,n)
    prev_on_tree = Vector{Int64}(undef,n)
    return GlobalVariables(
                N, max_match, label_x, label_y, match_xy, match_yx,
                S, T, slack, slack_causer, prev_on_tree
            )
end

function add_to_tree(gv::GlobalVariables, current::Int64, prev::Int64, cost::Matrix{Int64})
    slack_for_new_node = 0
    gv.S[current+1] = true
    gv.prev_on_tree[current+1] = prev
    for i in 0:gv.N-1
        slack_for_new_node = gv.label_x[current+1] + gv.label_y[i+1] - cost[current+1,i+1]
        if slack_for_new_node < gv.slack[i+1]
            gv.slack[i+1] = slack_for_new_node
            gv.slack_causer[i+1] = current
        end
    end
end

function init_labels(gv::GlobalVariables, cost::Matrix{Int64})
    gv.label_y = zeros(Int64, gv.N)
    gv.label_x = fill(-INF, gv.N)
    for i in 0:gv.N-1
        for j in 0:gv.N-1
            gv.label_x[i+1] = max(gv.label_x[i+1],cost[i+1,j+1])
        end
    end
    gv.match_xy = fill(-1, gv.N)
    gv.match_yx = fill(-1, gv.N)
end

function update_labels(gv::GlobalVariables)
    delta = INF
    for i in 0:gv.N-1
        if !gv.T[i+1]
            delta = min(delta, gv.slack[i+1])
        end
    end
    for i in 0:gv.N-1
        if gv.S[i+1]
            gv.label_x[i+1] -= delta
        end
        if gv.T[i+1]
            gv.label_y[i+1] += delta
        end
    end
    for i in 0:gv.N-1
        if !gv.T[i+1]
            gv.slack[i+1] -= delta
        end
    end
end

function augment(gv::GlobalVariables, cost::Matrix{Int64})
    if gv.max_match == gv.N
        return
    end
    bfs_queue = Vector{Int64}(undef,gv.N)
    queue_write = 0
    queue_reading = 0
    gv.S = fill(false, gv.N)
    gv.T = fill(false, gv.N)
    root = 0
    gv.prev_on_tree = fill(-1, gv.N)
    for i in 0:gv.N-1
        if gv.match_xy[i+1] == -1
            bfs_queue[queue_write+1] = i
            queue_write += 1
            root = i
            gv.prev_on_tree[root+1] = -2
            gv.S[root+1] = true
            break
        end
    end
    for i in 0:gv.N-1
        gv.slack[i+1] = gv.label_x[root+1] + gv.label_y[i+1] - cost[root+1,i+1]
        gv.slack_causer[i+1] = root
    end

    current = 0
    i = 0

    while true
        while queue_reading < queue_write
            current = bfs_queue[queue_reading+1]
            queue_reading += 1
            # for outer i in 0:N-1
            i = 0
            while i < gv.N
                if cost[current+1,i+1] == gv.label_x[current+1] + gv.label_y[i+1] && !gv.T[i+1]
                    if gv.match_yx[i+1] == -1
                        break
                    end
                    gv.T[i+1] = true
                    bfs_queue[queue_write+1] = gv.match_yx[i+1]
                    queue_write += 1
                    add_to_tree(gv, gv.match_yx[i+1], current, cost)
                end
                i +=1
            end
            if i < gv.N
                break
            end
        end
        if i < gv.N
            break
        end
        update_labels(gv)
        queue_reading = 0
        queue_write = 0
        # for outer i in 0:N-1
        i = 0
        while i < gv.N
            if !gv.T[i+1] && gv.slack[i+1] == 0
                if gv.match_yx[i+1] == -1
                    current = gv.slack_causer[i+1]
                    break
                else    
                    gv.T[i+1] = true
                    if !gv.S[gv.match_yx[i+1]+1]
                        bfs_queue[queue_write+1] = gv.match_yx[i+1]
                        queue_write += 1
                        add_to_tree(gv, gv.match_yx[i+1], gv.slack_causer[i+1], cost)
                    end
                end
            end
            i += 1
        end
        if i < gv.N
            break
        end
    end
    if i < gv.N
        gv.max_match += 1
        cx = current
        cy = i
        while cx != -2
            ty = gv.match_xy[cx+1]
            gv.match_yx[cy+1] = cx
            gv.match_xy[cx+1] = cy
            cx = gv.prev_on_tree[cx+1]
            cy = ty
        end
        augment(gv, cost)
    end
end

function hungarian_least_cost(n::Int64, matrix::Matrix{Int64})
    gv = GlobalVariables(n)
    maximum_ = -INF
    for i in 0:n-1
        maximum_ = max(maximum(matrix[i+1,1:n]),maximum_)
    end
    for i in 0:n-1
        for j in 0:n-1
            matrix[i+1,j+1] = maximum_ - matrix[i+1,j+1]
        end
    end
    init_labels(gv, matrix)
    augment(gv, matrix)
    cost = 0
    for i in 0:gv.N-1
        cost += -(matrix[i+1,gv.match_xy[i+1]+1]-maximum_)
    end
    return cost
end