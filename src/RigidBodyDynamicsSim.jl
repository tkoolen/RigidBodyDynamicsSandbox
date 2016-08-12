module RigidBodyDynamicsSim

using RigidBodyDynamics
using JuMP
using ODE
using Memoize

include("jump_utils.jl")
include("simulate.jl")
# include("fixed_point.jl")

export
    simulate,
    VectorNLconstraint,
    find_fixed_point
end
