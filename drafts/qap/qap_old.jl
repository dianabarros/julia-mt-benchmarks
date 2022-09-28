mutable struct QAP
    A::Union{Nothing,Matrix{Float64}}
    B::Union{Nothing,Matrix{Float64}}
    C::Union{Nothing,Matrix{Float64}}
    Shift::Union{Nothing,Float64}
end

QAP() = QAP(nothing, nothing, nothing, nothing)

function size(qap::QAP)
    return isnothing(qap.A) ? 0 : length(qap.A)
end

function evaluate(qap::QAP, p::Vector{Int64})
    obj = qap.Shift
    for i in 1:size(qap.A,1)
        obj += qap.C[i,p[i]]
        for j in 1:size(qap.A,2) # TODO: Check if A is matrix or array of arrays
            obj += qap.A[i,j] * qap.B[p[i],p[j]] 
        end
    end
    return obj
end

function reduce(qap::QAP, i::Int64, k::Int64)
    r = QAP()

    r.A = Reduce(qap.A, i, i)
    r.B = Reduce(qap.B, j, j)
    r.C = Reduce(qap.C, i, j)

    for ii in 1:size(qap)
        for jj in 1:size(qap)
            r.C[ii,jj] += 2 * qap.A[i,i] * qap.B[j,j] + qap.C[i,j]
        end
    end

    return r
end

function reduce(M::Matrix{Float64}, i::Int64, j::Int64)
    R = similar(M)
    for ii in 1:size(R,1)
        for jj in 1:size(R,2)
            R[ii,jj] = M[ii < i ? ii : ii + 1 , jj < j ? jj : jj + 1]
        end
    end
end