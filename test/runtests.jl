using HDF5
using StaticArrays
using Test
using VTKHDF

@testset "VTKHDF.jl" begin
  @testset "SaveVTKHDF point cloud" begin
    mktempdir() do directory
      filepath = joinpath(directory, "points.vtkhdf")
      points = rand(SVector{3,Float64}, 500)

      @test isnothing(SaveVTKHDF(filepath, points))
      @test isfile(filepath)

      h5open(filepath, "r") do file
        @test collect(keys(file)) == ["VTKHDF"]

        vtkhdf = file["VTKHDF"]
        @test read_attribute(vtkhdf, "Type") == "PolyData"
        @test read_attribute(vtkhdf, "Version") == [2, 3]
        @test Set(keys(vtkhdf)) == Set([
          "Lines",
          "NumberOfPoints",
          "PointData",
          "Points",
          "Polygons",
          "Strips",
          "Vertices",
        ])
        @test read(vtkhdf["NumberOfPoints"]) == [length(points)]
        @test read(vtkhdf["Points"]) == reduce(hcat, points)
        @test isempty(collect(keys(vtkhdf["PointData"])))

        vertices = vtkhdf["Vertices"]
        @test read(vertices["NumberOfCells"]) == [length(points)]
        @test read(vertices["NumberOfConnectivityIds"]) == [length(points)]
        @test read(vertices["Connectivity"]) == collect(0:(length(points)-1))
        @test read(vertices["Offsets"]) == collect(0:length(points))

        for cell_type in ("Lines", "Polygons", "Strips")
          cells = vtkhdf[cell_type]
          @test read(cells["NumberOfCells"]) == [0]
          @test read(cells["NumberOfConnectivityIds"]) == [0]
          @test isempty(read(cells["Connectivity"]))
          @test read(cells["Offsets"]) == [0]
        end
      end
    end
  end

  @testset "point data" begin
    mktempdir() do directory
      filepath = joinpath(directory, "point-data.vtkhdf")
      points = [SVector(1.0, 2.0, 3.0), SVector(4.0, 5.0, 6.0)]
      pressure = Float32[10, 20]
      velocity = [SVector(1.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0)]

      SaveVTKHDF(filepath, points, ["pressure", "velocity"], pressure, velocity)

      h5open(filepath, "r") do file
        point_data = file["VTKHDF/PointData"]
        @test Set(keys(point_data)) == Set(["pressure", "velocity"])
        @test read(point_data["pressure"]) == pressure
        @test read(point_data["velocity"]) == reduce(hcat, velocity)
      end
    end
  end

  @testset "input validation" begin
    mktempdir() do directory
      filepath = joinpath(directory, "invalid.vtkhdf")
      points = [SVector(1.0, 2.0, 3.0)]

      @test_throws AssertionError SaveVTKHDF(filepath, points, ["pressure"])
      @test !isfile(filepath)
    end
  end
end
