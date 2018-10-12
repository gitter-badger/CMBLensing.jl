using StaticArrays: StaticArrayStyle

struct FieldArrayStyle <: BroadcastStyle end
BroadcastStyle(::Type{<:FieldArray}) = FieldArrayStyle()
BroadcastStyle(::FieldArrayStyle, ::DefaultArrayStyle{0}) = FieldArrayStyle()
BroadcastStyle(::FieldArrayStyle, ::Style{<:Field}) = FieldArrayStyle()
⨳(a,b) = a*b

function materialize(bc::Broadcasted{FieldArrayStyle})
    sbc = simplify_bc(bc)
    if typeof(sbc) == typeof(bc)
        materialize(convert(Broadcasted{StaticArrayStyle{2}}, sbc))
    else
        materialize(sbc)
    end
end
function materialize!(dest, bc::Broadcasted{FieldArrayStyle})
    sbc = simplify_bc(bc)
    if typeof(sbc) == typeof(bc)
        materialize!(dest, convert(Broadcasted{StaticArrayStyle{2}}, sbc))
    elseif sbc isa Field
        dest .= sbc
    else
        materialize!(dest, sbc)
    end
end

# Smash{T,S} is the type of Broadcasted object that you get from doing `t::T .⨳ s::S`
const Smash{T,S} = Broadcasted{FieldArrayStyle, Nothing, typeof(⨳), <:Tuple{T,S}}

# simplification rule for `x' * y`
simplify_bc(bc::Smash{<:FieldRowVector, <:FieldVector}) = 
    Broadcasted(+,(Broadcasted(*, (bc.args[1][1]', bc.args[2][1])),Broadcasted(*, (bc.args[1][2]', bc.args[2][2]))))

# a broadcasted `⨳` behaves like a `*`
simplify_bc(bc::Broadcasted{FieldArrayStyle, Nothing, typeof(⨳)}) = materialize(bc.args[1]) * materialize(bc.args[2])

# recursively go through Broadcasted objects
simplify_bc(bc::Broadcasted{FieldArrayStyle}) = Broadcasted(bc.f, map(simplify_bc, bc.args))
simplify_bc(x) = x