ENV["GKSwstype"] = "nul"
using QuadGK
using Plots

function Integral( f, a, b )
    return quadgk( f, a, b )[1]
end

function Trapezoid( f, a, b, n )
    h = (b-a)/n
    X = collect(a : h : b)
    Y = f.(X)
    Y .*= h
    Y[1] *= 0.5
    Y[n+1] *= 0.5

    return sum(Y)
end

function Simpson( f, a, b, n )
    h = (b-a)/n
    X = collect(a : h : b)
    Y = f.(X)

    for i in 1:(n/2)-1
        Y[Int(2*i+1)] *= 2
    end

    for i in 1:(n/2)
        Y[Int(2*i)] *= 4
    end

    Y .*= (h/3)

    return sum(Y)
end

function RelativeError( x, approx )
    return abs((x-approx)/x)
end

function AbsoluteError( x, approx )
    return abs(x-approx)
end

function IntegralError( f, a, b, n, method, ErrorType )
    ret = zeros(Float64, (Int(n/2),))
    for i in 2:2:n
        res = Integral( f, a, b )
        approx = method( f, a, b, i )
        ret[Int(i/2)] = ErrorType( res, approx )
    end
    return ret
end

function DrawPlot( f, a, b, n, ErrorType )
    if( ErrorType )
        error = RelativeError
    else
        error = AbsoluteError
    end
    retTrap = IntegralError( f, a, b, n, Trapezoid, error )
    retSimp = IntegralError( f, a, b, n, Simpson, error )
    plot(2:2:n, [retTrap retSimp], label=["Trapezoid" "Simpson"], lw=2)
end

W1(x) = 328*x^10 + 49*x^9 - 2*x^7 + 54*x^4 - 23*x^2 + 8*x - 100
savefig(DrawPlot(W1,-1,1,100,true), "plot_W1.png")

W2(x) = (x+0.5)*(x+0.25)*(x+0.2)*(x+0.1)*(x-0.1)*(x-0.7)*(x-1) + 8*x^1000 + 5.8*x^97
savefig(DrawPlot(W2,-1,1,100,true), "plot_W2.png");

function W3(x)
    res = 0
    for i in 1:1023
        res += (-1)^(i+1)*(1/i)*(x-1)^i
    end
    return res
end
savefig(DrawPlot(W3,-1,1,100,true), "plot_W3.png")

P1(x) = 1/(1+25*x^2)
savefig(DrawPlot(P1,-1,1,100,true), "plot_P1.png")

P2(x) = (x-34)*(x-398)*(x-23)/((x-230)*(x+1.5)*(x+7)*(x+2))
savefig(DrawPlot(P2,-1,1,100,true), "plot_P2.png")

P3(x) = 1/(x^5 + x^4 + 3*x^3 - 2*x^2+7)
savefig(DrawPlot(P3,-1,1,100,true), "plot_P3.png")

T1(x) = sin(x)/(cos(x)^3 + 7)
savefig(DrawPlot(T1,-1,1,100,true), "plot_T1.png")

T2(x) = (sin(x)^2 + cos(x)^5 + sin(x)*cos(x) + 100)/(sin(x)^2*cos(x) + 8)
savefig(DrawPlot(T2,-1,1,100,true), "plot_T2.png")

T3(x) = sin(x)/(cos(x)^5+100)
savefig(DrawPlot(T3,-1,1,100,true), "plot_T3.png")

function CalculateWithTime( method, f, a, b )
    exact_res = Integral(f, a, b)
    res = 1e18
    
    for i in 2:2:100
        ret = @elapsed method(f,a,b,i)
        cur = method(f,a,b,i)
        if(ret < 1e-3)
            res = min(res, RelativeError(exact_res,cur))
        end
    end
    
    return res
end

function BestResWithTime( f, a, b )
    return [CalculateWithTime(Trapezoid,f,a,b), CalculateWithTime(Simpson,f,a,b)]
end

BestResWithTime( W1,-1,1 )

BestResWithTime( W2,-1,1 )

BestResWithTime( W3,-1,1 )

BestResWithTime( P1,-1,1 )

BestResWithTime( P2,-1,1 )

BestResWithTime( P3,-1,1 )

BestResWithTime( T1,-1,1 )

BestResWithTime( T2,-1,1 )

BestResWithTime( T3,-1,1 )

savefig(DrawPlot(T1,-1,1,100,false), "plot_T1_abs.png")
savefig(DrawPlot(T3,-1,1,100,false), "plot_T3_abs.png")
