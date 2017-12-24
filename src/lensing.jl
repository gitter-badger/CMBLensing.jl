export FΦTuple, δf̃ϕ_δfϕ, δfϕ_δf̃ϕ, Ł, LenseOp

# Abstract type for lensing operators
abstract type LenseOp <: LinOp{Pix,Spin,Basis} end

# For each Field type, lensing algorithms needs to know the basis in which
# lensing is a remapping. E.g. for FlatS0 it's Map but for FlatS2 it's QUMap.
# Fields implement their own LenseBasis(::Type{F}) to specify.
abstract type LenseBasis <: Basislike end
const Ł = LenseBasis


const FΦTuple = Field2Tuple{<:Field,<:Field{<:Any,<:S0}}

# 
# δfϕₛ_δfϕₜ is an operator which computes the lensing jacobian between time s
# and time t,
# 
# [δfₛ/δfₜ  δfₛ/δϕ;
#  δϕ/δfₜ  δϕ/δϕ]
# 
# The operator acts on a Field2Tuple containing (f,ϕ). 
# 
# Individual lensing algorithms need to implement how to apply this operator,
# inverse, and/or transpose. Different algorithms may need the field at time s,
# time t, or both, hence both are stored here
# 
# Note, the bottom row is trivially [0,1], but included to make the Jacobian
# square and easier to reason about
# 
struct δfϕₛ_δfϕₜ{s, t, L<:LenseOp, Fₛ<:Field, Fₜ<:Field} <: LinOp{Pix,Spin,Basis}
    L::L
    fₛ::Fₛ
    fₜ::Fₜ
    δfϕₛ_δfϕₜ{s,t}(l::L,fₛ::Fₛ,fₜ::Fₜ) where {s,t,L,Fₛ,Fₜ} = new{s,t,L,Fₛ,Fₜ}(l,fₛ,fₜ)
end
# convenience constructors which use f̃ to mean f_(t=1) and/or f to mean f_(t=0)
δf̃ϕ_δfϕₜ(L,f̃,fₜ,::Type{Val{t}}) where {t} = δfϕₛ_δfϕₜ{1.,t}(L,f̃,fₜ)
δf̃ϕ_δfϕₜ(L,f̃,fₜ,::Type{Val{1.}}) = IdentityOp
δfϕ_δfϕₜ(L,f,fₜ,::Type{Val{t}}) where {t} = δfϕₛ_δfϕₜ{0.,t}(L,f,fₜ)
δfϕ_δfϕₜ(L,f,fₜ,::Type{Val{0.}}) = IdentityOp
δfϕ_δf̃ϕ(L,f,f̃) = δfϕₛ_δfϕₜ{0.,1.}(L,f,f̃)
δf̃ϕ_δfϕ(L,f̃,f) = δfϕₛ_δfϕₜ{1.,0.}(L,f̃,f)
# inverse Jacobians are the same as switching time t and s
inv(J::δfϕₛ_δfϕₜ{s,t}) where {s,t} = δfϕₛ_δfϕₜ{t,s}(J.L,J.fₜ,J.fₛ)



# some syntactic sugar for making lensing operators that lense from time t1 to t2
struct →{t1,t2} end
→(t1::Real,t2::Real) = →{float(t1),float(t2)}()
getindex(L::LenseOp, ::→{t,t}) where {t} = 1
getindex(L::LenseOp, ::→{0.,1.}) = L
getindex(L::LenseOp, i::→)  = _getindex(L,i)
_getindex(L::LenseOp, ::→{t1,t2}) where {t1,t2} = error("Lensing from time $t1 to $t2 with $(typeof(L)) is not implemented.")


include("powerlens.jl")
include("lenseflow.jl")
