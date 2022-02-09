using Pkg: Pkg

# unset LD_LIBRARY_PATH:
# https://discourse.julialang.org/t/juliacall-cant-use-a-package-that-builds-fine-outside-juliacall-random-file-path-ending-in-artifacts-libgobject-2-0-so-undefined-symbol-g-uri-ref/68289?u=devmotion
withenv("LD_LIBRARY_PATH" => nothing) do
    Pkg.add(
        Pkg.PackageSpec(;
            name="CalibrationAnalysis",
            uuid="f96f8458-5c05-4a28-b3fd-d398aeb95222",
            version="0.1",
        ),
    )
end
