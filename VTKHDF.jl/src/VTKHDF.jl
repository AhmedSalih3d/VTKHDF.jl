using HDF5
using StaticArrays

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

function SaveVTKHDF(filepath, points, variable_names = String[], args...)
  @assert length(variable_names) == length(args) "Same number of variable_names as args is necessary"
  io = h5open(filepath, "w")
  gtop = HDF5.create_group(io, "VTKHDF")

  HDF5.attrs(gtop)["Version"] = [2, 3]
  _write_ascii_attribute(gtop, "Type", "PolyData")

  # Points
  np = length(points)
  gtop["NumberOfPoints"] = [np]
  gtop["Points"] = reinterpret(reshape, eltype(eltype(points)), points)

  # Point data
  let g = HDF5.create_group(gtop, "PointData")
    for i ∈ eachindex(variable_names)
      g[variable_names[i]] = reinterpret(reshape, eltype(eltype(args[i])), args[i])
    end
  end

  # Vertices: 1 point per cell
  let g = HDF5.create_group(gtop, "Vertices")
    g["NumberOfCells"] = [np]
    g["NumberOfConnectivityIds"] = [np]
    g["Connectivity"] = collect(0:(np-1))
    g["Offsets"] = collect(0:np)
    close(g)
  end

  # Empty groups for unused cell types
  for type ∈ ("Lines", "Polygons", "Strips")
    gempty = HDF5.create_group(gtop, type)
    gempty["NumberOfCells"] = [0]
    gempty["NumberOfConnectivityIds"] = [0]
    gempty["Connectivity"] = Int[]
    gempty["Offsets"] = [0]
    close(gempty)
  end

  close(io)
end

N = 500
points = rand(SVector{3,Float64}, N)
SaveVTKHDF("W:/Test.vtkhdf", points)
