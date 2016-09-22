module RigidBodyDynamicsSim

using RigidBodyDynamics
using JuMP
using ODE
using Memoize

include("jump_utils.jl")
# include("fixed_point.jl")

export
    VectorNLconstraint,
    find_fixed_point
end
