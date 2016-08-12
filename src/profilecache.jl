# # push!(LOAD_PATH, ".")
# # using RigidBodyDynamics
# # import RigidBodyDynamics: CacheElement
# import Base: get
# type CacheElement{T, F}
#     data::T
#     updateFunction::F
#     dirty::Bool
# end
# # CacheElement{T}(t::T) = CacheElement{T}(t, false)
# CacheElement{T, F}(::Type{T}, updateFunction::F) = CacheElement{T, F}(updateFunction(), updateFunction, true)
#
# function get{T, F}(element::CacheElement{T, F})
#     if element.dirty
#         element.data = element.updateFunction()
#         element.dirty = false
#     end
#     return element.data::T
# end
# function setdirty!(element::CacheElement)
#     element.dirty = true
# end
#
# const blaCache = Dict{Int64, CacheElement{Vec{3, Float64}}}()
# # @inline function update_fun()
# #     Vec(1., 2., 3.)
# # end

#
# for i = 1 : N
# #     blaCache[i] = CacheElement(rand(Vec{3, Float64}))
#     blaCache[i] = CacheElement(Vec{3, Float64}, MyFunctor(Vec(1., 2., 3.)))
# end
#
# const update_funs = [i::Int64 => MyFunctor(Vec(1., 2., 3.))::MyFunctor for i = 1 : N]


using FixedSizeArrays

# immutable Identity{T}
#     value::T
# end
# call(id::Identity) = id.value

type CacheElement{T, F}
    updateFunction::F
    data::T
    dirty::Bool
end
CacheElement{T, F}(::Type{T}, updateFunction::F) = CacheElement(updateFunction, updateFunction(), true)
CacheElement{T}(value::T) = CacheElement(Identity(value), value, false)

function get{T, F}(element::CacheElement{T, F})
    if element.dirty
        element.data = element.updateFunction()
        element.dirty = false
    end
    element.data
end
setdirty!(element::CacheElement) = element.dirty = true

type MyFunctor
    a::Vec{3, Float64}
    parentCache::CacheElement{Vec{3, Float64}, MyFunctor}
    MyFunctor(a::Vec{3, Float64}, parentCache::CacheElement{Vec{3, Float64}, MyFunctor}) = new(a, parentCache)
    MyFunctor(a::Vec{3, Float64}) = new(a)
end

call(f::MyFunctor) = isdefined(f, :parentCache) ? tan(cos(sin(exp(log(f.a))))) + get(f.parentCache) : f.a

# const cache = [i::Int64 => CacheElement(MyFunctor(Vec(1., 2., 3.)), Vec(2., 3., 4.), true) for i = 1 : N]
# const cache2 = [i::Int64 => CacheElement(() ->Vec(1., 2., 3.), Vec(2., 3., 4.), true) for i = 1 : N]

# const cache = [i::Int64 => CacheElement(Vec{3, Float64}, MyFunctor(Vec(1., 2., 3.))) for i = 1 : N]
# const cache2 = [i::Int64 => CacheElement(Vec{3, Float64}, () -> Vec(1., 2., 3.)) for i = 1 : N]
# const cache3 = [i::Int64 => CacheElement(Vec(1., 2., 3.)) for i = 1 : N]

const N = 1000000

const cache = Dict{Int64, CacheElement{Vec{3, Float64}, MyFunctor}}()
cache[1] = CacheElement(Vec{3, Float64}, MyFunctor(rand(Vec{3, Float64})))
for i = 2 : N
    cache[i] = CacheElement(Vec{3, Float64}, MyFunctor(rand(Vec{3, Float64}), cache[i - 1]))
end

for i = 1 : N
    setdirty!(element::CacheElement) = element.dirty = true
end

function test()
    bla = zero(Vec{3, Float64})
    a = zero(Vec{3, Float64})
    for i = 1 : N
        element = cache[i]
        # element = cache2[i]
        a = get(element)
    end
    # println(a)
end

function main()
    for i = 1 : 2
        Profile.clear()
        Profile.clear_malloc_data()
        @profile test()
    end
end

main()
