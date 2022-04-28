using DataFrames
using CSV
using Statistics

data = DataFrame(CSV.File("clustering.csv"))

X = hcat(data.ApplicantIncome, data.LoanAmount)

function calculate_cost(X, centroids, cluster)
    sum = 0
    for (i, val) in enumerate(X)
        sum += sqrt((centroids[Int(cluster[i]), 1]-val[1])^2 + (centroids[Int(cluster[i]), 2]-val[2])^2)
    end
    return sum
end

function find_centroids(X, cluster)
    gd = groupby(DataFrame(hcat(X,cluster), :auto), :x3)
    centroids_df = combine(gd, :x1 => mean, :x2 => mean)
    centroids = []
    for row in eachrow(centroids_df)
        push!(centroids, [row.x1_mean, row.x2_mean])
    end
    return centroids
end

function kmeans(X, k)
    diff = true
    cluster = zeros(size(X,1))
    random_indices = rand(1:size(X,1), k)
    centroids = X[random_indices,:]
    while diff
        for (i, row) in enumerate(X)
            mn_dist = Inf
            for (idx, centroid) in enumerate(centroids)
                d = sqrt((centroid[1]-row[1])^2 + (centroid[2]-row[2])^2)
                if mn_dist > d
                    mn_dist = d
                    cluster[i] = idx
                end
            end
            new_centroids = find_centroids(X, cluster)
            if centroids .- new_centroids .== 0
                diff = false
            else
                centroids = copy(new_centroids)
            end
        end
    end
    return centroids, cluster
end