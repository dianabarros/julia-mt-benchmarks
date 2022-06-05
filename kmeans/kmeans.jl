# https://www.analyticsvidhya.com/blog/2019/08/comprehensive-guide-k-means-clustering/#h2_1

using FoldsThreads
using FLoops
using Base.Threads

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
    df = DataFrame(hcat(X,cluster), :auto)
    gd = groupby(df, propertynames(df)[end])
    centroids_df = combine(gd, propertynames(df)[1:end-1] .=> mean)
    centroids = zeros(size(centroids_df,1),size(X,2))
    for (i,row) in enumerate(eachrow(centroids_df))
        centroids[i,:] = Vector(row)[2:end]
    end
    return centroids
end

function kmeans(X, k)
    diff = true
    cluster = zeros(size(X,1))
    random_indices = rand(1:size(X,1), k)
    centroids = X[random_indices,:]
    while diff
        for i in 1:size(X,1)
            mn_dist = Inf
            for idx in 1:size(centroids,1)
                sum = 0
                for dim in 1:size(X,2)
                    sum += (centroids[idx,dim]-X[i,dim])^2
                end
                d = sqrt(sum)
                if mn_dist > d
                    mn_dist = d
                    cluster[i] = idx
                end
            end
        end
        new_centroids = find_centroids(X, cluster)
        if iszero(centroids .- new_centroids)
            diff = false
        else
            centroids = copy(new_centroids)
        end
    end
    return centroids, cluster
end

# Probably doesnt work or makes no sense
function kmeans_floop(X, k, ex)
    cluster = zeros(size(X,1))
    random_indices = rand(1:size(X,1), k)
    centroids = X[random_indices,:]
    max_iter = 100000
    for iter in 1:max_iter
        @floop ex for i in 1:size(X,1)
            mn_dist = Threads.Atomic{Int}(1000000)
            for idx in 1:size(centroids,1)
                sum = 0
                for dim in 1:size(X,2)
                    sum += (centroids[idx,dim]-X[i,dim])^2
                end
                d = sqrt(sum)
                if mn_dist > d
                    mn_dist = d
                    cluster[i] = idx
                end
            end
        end
        new_centroids = find_centroids(X, cluster)
        if iszero(centroids .- new_centroids)
            break
        else
            centroids = copy(new_centroids)
        end
    end
    return centroids, cluster
end