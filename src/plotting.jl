# FlatS0
function plot(f::FlatS0{T,P}; kwargs...) where {T,Θ,N,P<:Flat{Θ,N}}
    ax = pyimport(:seaborn)[:heatmap](f[:Tx]; xticklabels=false, yticklabels=false, square=true, kwargs...)
    ax[:set_title]("T map ($(N)x$(N) @ $(Θ)')")
end 
function plot(fs::AbstractVecOrMat{<:FlatS0}; plotsize=4, kwargs...)
    fig,axs = subplots(size(fs,1), size(fs,2); figsize=plotsize.*(size(fs,2),size(fs,1)), squeeze=false)
    for i=eachindex(fs)
        plot(fs[i]; ax=axs[i], kwargs...)
    end
end
plot(f::FlatS0; kwargs...) = plot([f]; kwargs...)

# FlatS2
function plot(f::FlatS2{T,P}, axs; kwargs...) where {T,Θ,N,P<:Flat{Θ,N}}
    for (ax,k) in zip(axs,["E","B"])
        ax = pyimport(:seaborn)[:heatmap](f[Symbol("$(k)x")]; ax=ax, xticklabels=false, yticklabels=false, square=true, kwargs...)
        ax[:set_title]("$k map ($(N)x$(N) @ $(Θ)')")
    end
end
function plot(fs::AbstractVector{<:FlatS2}; plotsize=4, kwargs...)
    fig,axs = subplots(length(fs),2; figsize=(plotsize.*(2,length(fs))), squeeze=false)
    for i=1:length(fs)
        plot(fs[i], axs[i,:]; kwargs...)
    end
end
plot(f::FlatS2; kwargs...) = plot([f]; kwargs...)