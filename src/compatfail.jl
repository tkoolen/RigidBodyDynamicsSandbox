using Compat

immutable Functor
    a::Int64
end

bla(f::Functor) = f.a
#@compat (f::Functor)() = f.a # fine
@compat (f::Functor)() = bla(f.a) # error
