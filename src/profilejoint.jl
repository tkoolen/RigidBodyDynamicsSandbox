push!(LOAD_PATH, ".")
using RigidBodyDynamics
# using RigidBodyDynamicsSim

using FixedSizeArrays
using Quaternions

function test{J, Q}(joint::Joint{J}, q::Vector{Q})
    T = promote_type(J, Q)
    ret::Transform3D{T}
    # ret = joint_transform(joint, joint.jointType, q)
    if isa(joint.jointType, QuaternionFloating{J})
        ret = joint_transform(joint, joint.jointType::QuaternionFloating{J}, q)
    elseif isa(joint.jointType, Revolute{J})
        ret = joint_transform(joint, joint.jointType::Revolute{J}, q)
    else
        ret = Transform3D{T}(joint.frameBefore, joint.frameAfter)
    end
    ret
end
# function test{T}(q::Vector{T})
#     @inbounds joint_transform(joint, joint.jointType, q)
# end

function fun(n, joint, q)
    for i = 1 : n
        test(joint, q)
    end
end

function main()
    joint = Joint("bla", QuaternionFloating{Float64}())
    # joint = Joint("bla", rand(Revolute{Float64}))
    q = rand_configuration(joint, Float64)
    for i = 1 : 2
        Profile.clear()
        Profile.clear_malloc_data()
        @time fun(10000, joint, q)
    end
end

main()
