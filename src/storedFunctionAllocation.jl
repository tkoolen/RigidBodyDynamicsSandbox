immutable FunctionContainer # immutable or type doesn't matter
    f::Function
end

# even if you help out the compiler with a type assertion, there's still allocation:
function get{T}(container::FunctionContainer, arg::T)
    ret::T = container.f(arg)::T
    # container.f(arg)
end

fun(arg) = mod(arg, 3) #arg^2
# const fun = (arg) -> mod(arg, 3)

# just call the function directly to make sure there's no inherent allocation
function testDirectCall(n)
    ret = 0
    for i = 1 : n
        ret += fun(i)
    end
end

# create a FunctionContainer and call the function it contains
function testContainer(n::Int64)
    container = FunctionContainer(fun)
    ret = 0
    for i = 1 : n
        ret += get(container, i)
    end
end

# a possible solution: use a functor instead
type FunctorContainer{F}
    f::F
end
get(container::FunctorContainer, arg) = container.f(arg)

type MyFunctor
end
call(::MyFunctor, arg) = mod(arg, 3)

function testDirectCallFunctor(n)
    f = MyFunctor()
    ret = 0
    for i = 1 : n
        ret += f(i)
    end
end

function testFunctorContainer(n)
    container = FunctorContainer(MyFunctor())
    ret = 0
    for i = 1 : n
        ret += get(container, i)
    end
    println(ret)
end

function main()
    n = 100000
    for i = 1 : 2 # once to JIT compile, second for actual results
        println("direct call:")
        @time testDirectCall(n) # no allocation

        println("via container:")
        @time testContainer(n) # allocation at every function call

        println("direct call, functor:")
        @time testDirectCallFunctor(n) # no allocation

        println("via container, functor:")
        @time testFunctorContainer(n) # no allocation on function calls

        println()
    end
    container = FunctionContainer(fun)
    @code_warntype get(container, 2)
end

main()
