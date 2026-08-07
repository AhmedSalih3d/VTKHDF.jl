using HDF5
using StaticArrays

const idType = Int64
const fType = Float64


function SaveVTKHDF(filepath, points, variable_names = String[], args...)
  @assert length(variable_names) == length(args) "Same number of variable_names as args is necessary"
  io   = h5open(filepath, "w")
  gtop = HDF5.create_group(io, "VTKHDF")

  HDF5.attrs(gtop)["Version"] = [2, 3]
  write_ascii_attribute(gtop, "Type", "PolyData")

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
