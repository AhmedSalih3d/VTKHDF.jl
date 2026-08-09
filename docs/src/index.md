# VTKHDF.jl

VTKHDF.jl provides helpers for writing VTKHDF files that can be opened in ParaView.

## Installation

VTKHDF.jl is not registered yet, so install it directly from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/AhmedSalih3d/VTKHDF.jl")
```

## Quick start

```julia
using StaticArrays
using VTKHDF

points = rand(SVector{3,Float64}, 500)
SaveVTKHDF("points.vtkhdf", points)
```

One- and two-dimensional points are also accepted and are padded with zero coordinates:

```julia
points_1d = rand(SVector{1,Float64}, 500)
SaveVTKHDF("points-1d.vtkhdf", points_1d)

points_2d = rand(SVector{2,Float64}, 500)
SaveVTKHDF("points-2d.vtkhdf", points_2d)
```

Point-data arrays can be supplied together with their names:

```julia
temperature = rand(500)
SaveVTKHDF("points.vtkhdf", points, ["temperature"], temperature)
```

## API

```@docs
VTKHDF.SaveVTKHDF
```

## Building the documentation locally

From the repository root, run:

```sh
julia --project=docs -e 'using Pkg; Pkg.develop(path=pwd()); Pkg.instantiate()'
julia --project=docs docs/make.jl
```
