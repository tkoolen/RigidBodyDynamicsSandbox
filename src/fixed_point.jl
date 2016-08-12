function find_fixed_point(mechanism::Mechanism; seed = randn(num_positions(mechanism)))
    state_cache = Dict{DataType, MechanismState}()
    js = joints(mechanism)
    function joint_accelerations(q)
        T = eltype(q)
        state = get!(state_cache, T, MechanismState(T, mechanism))
        zero_velocity!(state)
        set_configuration!(state, q)
        q̇, v̇ = dynamics(state)
        return velocity_dict_to_vector(v̇, js)
    end

    nq = num_positions(mechanism)
    m = Model()
    @variable(m, q[1 : nq])
    for i in 1: nq
        setvalue(q[i], seed[i])
    end
    @VectorNLconstraint(m, joint_accelerations(q) == zeros(nq))
    print(m)
    status = solve(m)
    status != :Optimal && error("Could not find a fixed point.")
#     println(joint_accelerations(getvalue(q)))
    getvalue(q)
end
