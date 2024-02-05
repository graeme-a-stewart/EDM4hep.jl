export EDStore, getEDStore, initEDStore, assignEDStore, emptyEDStore, assignEDStore_relations, assignEDStore_vmembers

mutable struct EDStore{ED <: POD}
    objects::AbstractVector{ED}
    relations::Tuple    # a Tuple of ObjectID{ED} [Abstrcat] Vectors
    vmembers::Tuple   # a Tuple of T [Abstrcat] Vectors
    EDStore{ED}() where ED = new()
end

function initialize!(store::EDStore{ED}) where ED <: POD
    store.objects = ED[]
    store.relations = Tuple(ObjectID{eltype(R)}[] for R in relations(ED))
    store.vmembers = Tuple(ObjectID{eltype(R)}[] for R in vmembers(ED))
end

function Base.empty!(store::EDStore{ED}) where ED <: POD
    store.objects isa Vector && empty!(store.objects)
    for (i,R) in enumerate(relations(ED))
        store.relations[i] isa Vector &&  empty!(store.relations[i])
    end
    for (i,R) in enumerate(vmembers(ED))
        store.vmembers[i] isa Vector &&  empty!(store.vmembers[i])
    end
    store
end

#--- Global Event Data Store-----------------------------------------------------------------------
const _eventDataStore = Dict{UInt32, EDStore}()

function getEDStore(::Type{ED}, collid::UInt32=0x00000000) where ED
    global _eventDataStore
    if collid == 0
        collid = collectionID(ED)
    end
    haskey(_eventDataStore, collid) && return _eventDataStore[collid]
    _eventDataStore[collid] = EDStore{ED}()
end

function hasEDStore(collid::UInt32)
    global _eventDataStore
    collid == 0 || haskey(_eventDataStore, collid)
end

function initEDStore(::Type{ED}) where ED
    getEDStore(ED) |> initialize!
end

function emptyEDStore()
    global _eventDataStore
    for container in Base.values(_eventDataStore)
        container |> empty!
    end
end

function assignEDStore(container::AbstractArray{ED}, collid::UInt32) where ED
    getEDStore(ED, collid).objects = container
end
function assignEDStore_relations(relations::Tuple, ::Type{ED}, collid::UInt32) where ED
    getEDStore(ED, collid).relations = relations
end
function assignEDStore_vmembers(vmembers::Tuple, ::Type{ED}, collid::UInt32) where ED
    getEDStore(ED, collid).vmembers = vmembers
end

function EDStore_objects(::Type{ED}, collid::UInt32=0x00000000) where ED
    store = getEDStore(ED, collid)
    if !isdefined(store, :objects)
        store.objects = ED[]
    end
    store.objects
end

function EDStore_relations(::Type{ED}, N::Int, collid::UInt32=0x00000000) where ED
    store = getEDStore(ED, collid)
    if !isdefined(store, :relations)
        store.relations = Tuple(ObjectID{eltype(R)}[] for R in relations(ED))
    end
    store.relations[N]
end

function EDStore_pvectors(::Type{ED}, N::Int, collid::UInt32=0x00000000) where ED
    store = getEDStore(ED, collid)
    if !isdefined(store, :vmembers)
        store.vmembers = Tuple(eltype(V)[] for V in vmembers(ED))
    end
    store.vmembers[N]
end
