push!(LOAD_PATH, ".")

RIGID_BODY_DYNAMICS_RELEASE = true

using RigidBodyDynamics
using ODE

function main()
    filename = dirname(Base.source_path()) * "/../urdf/Strandbeest.urdf"
    mechanism = RigidBodyDynamics.parse_urdf(Float64, filename)
    state = MechanismState(Float64, mechanism)
    rand_configuration!(state)
    zero_velocity!(state)
    tspan = [0.; 1.]
    for i = 1 : 2
        # Profile.clear_malloc_data()
        @time times, states = simulate(state, tspan, minstep = 1e-2, maxstep = 1e-2)
    end
end

main()
