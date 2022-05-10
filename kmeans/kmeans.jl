# https://www.analyticsvidhya.com/blog/2019/08/comprehensive-guide-k-means-clustering/#h2_1

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
    gd = groupby(DataFrame(hcat(X,cluster)), :x1)
    columns = propertynames(X)
    centroids_df = combine(gd, columns[1] => mean, columns[2] => mean)
    centroids_columns = [Symbol(string(columns[1],"_mean")), Symbol(string(columns[2],"_mean"))]
    centroids = []
    for row in eachrow(centroids_df)
        push!(centroids, [row[centroids_columns[1]], row[centroids_columns[2]]])
    end
    return centroids
end

function kmeans(X, k)
    diff = true
    cluster = zeros(size(X,1))
    random_indices = rand(1:size(X,1), k)
    centroids = X[random_indices,:]
    while diff
        for (i, row) in enumerate(eachrow(X))
            mn_dist = Inf
            for (idx, centroid) in enumerate(eachrow(centroids))
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