module VTKHDF

using Bumper
using HDF5
using StaticArrays

export SaveVTKHDF

const idType = Int64
const fType = Float64

"""Write an ASCII attribute `name => value` to `grp`."""
function _write_ascii_attribute(grp, name, value)
  dtype = HDF5.datatype(value)
  HDF5.API.h5t_set_cset(dtype.id, HDF5.API.H5T_CSET_ASCII)
  dspace = HDF5.dataspace(value)
  attr = HDF5.create_attribute(grp, name, dtype, dspace)
  HDF5.write_attribute(attr, dtype, value)
end

function _write_points(group, points)
  group["Points"] = reinterpret(reshape, eltype(eltype(points)), points)
  nothing
end

function _write_points(group, points::AbstractVector{<:StaticVector{2,T}}) where {T}
  @no_escape begin
    points_3d = @alloc(T, 3, length(points))
    for (column, point) in enumerate(points)
      points_3d[1, column] = point[1]
      points_3d[2, column] = point[2]
      points_3d[3, column] = zero(T)
    end
    group["Points"] = points_3d
    nothing
  end
end

"""
    SaveVTKHDF(filepath, points, [variable_names], point_data...)

Write `points` and optional named point-data arrays to a VTKHDF PolyData file.
Two-dimensional points are embedded in three dimensions with a zero z-coordinate.
Each entry in `variable_names` must have a matching array in `point_data`.
"""
function SaveVTKHDF(filepath, points, variable_names = String[], point_data...)
  @assert length(variable_names) == length(point_data) "Same number of variable_names as point_data arrays is necessary"
  
  h5open(filepath, "w") do io
    gtop = HDF5.create_group(io, "VTKHDF")

    HDF5.attrs(gtop)["Version"] = [2, 8]
    _write_ascii_attribute(gtop, "Type", "PolyData")

    # Points
    np = length(points)
    gtop["NumberOfPoints"] = [np]
    _write_points(gtop, points)

    # Point data
    let g = HDF5.create_group(gtop, "PointData")
      for i ∈ eachindex(variable_names)
        g[variable_names[i]] = reinterpret(reshape, eltype(eltype(point_data[i])), point_data[i])
      end
    end

    # Vertices: 1 point per cell
    let g = HDF5.create_group(gtop, "Vertices")
      g["NumberOfCells"] = [np]
      g["NumberOfConnectivityIds"] = [np]
      g["Connectivity"] = collect(0:(np-1))
      g["Offsets"] = collect(0:np)
    end

    # Empty groups for unused cell types
    for type ∈ ("Lines", "Polygons", "Strips")
      gempty = HDF5.create_group(gtop, type)
      gempty["NumberOfCells"] = [0]
      gempty["NumberOfConnectivityIds"] = [0]
      gempty["Connectivity"] = Int[]
      gempty["Offsets"] = [0]
    end
  end
end

end
