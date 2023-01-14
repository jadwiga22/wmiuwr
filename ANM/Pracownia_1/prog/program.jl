ENV["GKSwstype"] = "nul"
using Plots

function FormulaA(X, i, type)
    X[i] = type(2) * (X[i-1] + X[i-2])
end

function FormulaB(X, i, type)
    X[i] = B*x2^i
end

function FormulaC(X, i, type)
    X[i] = eps(type)*(type(1)+type(sqrt(3)))^i + B*(type(1) - type(sqrt(3)))^i
end

function CalculateSequence(type, formula)
    X = zeros(type, (100,))
    X[1] = x1
    X[2] = x2

    for i in 3:100
        X[i] = formula(X, i, type)
    end
    return X
end    

function RecursiveA(type)
    CalculateSequence(type, FormulaA)
end

function ExplicitB(type)
    CalculateSequence(type, FormulaB)
end

function ExplicitC(type)
    CalculateSequence(type, FormulaC)
end

function SolveWithPrecision(type)
    global x1 = type(1)
    global x2 = type(1 - sqrt(3))
    global A = type(0)
    global B = type(1.0 / (1 - sqrt(3)))
    global C = type(1 + sqrt(3))


    return [RecursiveA(type), ExplicitB(type), ExplicitC(type)]
end

# tworzenie wykresow

results_32 = SolveWithPrecision(Float32)

for i in 1:3
    savefig(plot(1:100, results_32[i], label = "", lw = 2), "plot32_"*string(i)*".png")
end

results_64 =  SolveWithPrecision(Float64)

for i in 1:3
    savefig(plot(1:100, results_64[i], label = "", lw = 2), "plot64_"*string(i)*".png")
end

# tworzenie wykresow w skali logarytmicznej

for i in 1:3
    savefig(plot(1:100, map(x->abs(x), results_32[i]), label = "", lw = 2, yaxis=:log), "plot32_log_"*string(i)*".png")
end

for i in 1:3
    savefig(plot(1:100, map(x->abs(x), results_64[i]), label = "", lw = 2, yaxis=:log), "plot64_log_"*string(i)*".png")
end

