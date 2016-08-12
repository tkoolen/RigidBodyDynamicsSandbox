function add_vector_nlconstraint(m::JuMP.Model, vec_fun::Function, x::Vector{JuMP.Variable}, comparator::Function, rhs::Vector)
    # memoize function mapping vector x to vector y
    @memoize Dict function memoized(x)
        vec_fun(x)
    end

    nx = length(x)
    ny = length(rhs)
    for i = 1 : ny
        # split up memoized function into scalar-valued functions
        fun = (xs...) -> memoized([xs...])[i]

        # register scalar-valued function
        fun_symbol = gensym()
        JuMP.register(fun_symbol, nx, fun, autodiff = true)

        # create expression for scalar-valued function
        expr = Expr(:call, fun_symbol, x...)
        expr_sym = gensym()
        nlexpr = @eval @NLexpression($m, expr_sym, $expr)

        # create constraint
        constr_sym = gensym()
        constr_expr = Expr(:comparison, nlexpr, Symbol(comparator), rhs[i])
        @eval @NLconstraint($m, constr_sym, $constr_expr)
    end
end

macro VectorNLconstraint(model, constraint)
    fun_call = constraint.args[1]
    comparator = constraint.args[2]
    rhs = constraint.args[3]
    fun = fun_call.args[1]
    arg = fun_call.args[2]
    return :(add_vector_nlconstraint($model, $fun, $arg, $comparator, $rhs))
end
