using Pkg: Pkg

Pkg.add([
    Pkg.PackageSpec(;
        name="CalibrationErrorsDistributions",
        uuid="20087e1a-bb94-462b-b900-33d17a750383",
        version="0.2",
    ),
    Pkg.PackageSpec(;
        name="CalibrationTests", uuid="2818745e-0823-50c7-bc2d-405ac343d48b", version="0.5"
    ),
])
