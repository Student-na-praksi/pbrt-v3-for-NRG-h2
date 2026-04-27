core: shared engine infrastructure (scene, BSDF, parser, integrator framework, textures/material interfaces).
integrators: rendering algorithms (path, volpath, bdpt, mlt, etc.).
lights: light source models.
materials: material models and BSDF assembly.
shapes: geometric primitives and sampling.
samplers: pixel/path sample generation.
cameras: camera models.
accelerators: BVH/KD-tree for intersection acceleration.
textures: procedural and image textures.
media: participating media.
main: CLI entry point.
tools: helper executables.
tests: unit/integration tests.
ext: third-party code and submodules.

1. Build
& "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" --build build-vs2019 --config Release --target pbrt_exe

2. Run
& ".\build-vs2019\Release\pbrt.exe" ".\scenes\killeroo-simple.pbrt"