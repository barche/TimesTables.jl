using Pkg.Artifacts
using Tar, GZip, SHA

artifact_toml = joinpath(dirname(@__DIR__), "Artifacts.toml")
version = "0.0.1"
uri = "https://github.com/barche/timestables-assets/archive/v$version.tar.gz"

tarball = download(uri)
hash = bytes2hex(open(sha256, tarball))

timeshash = create_artifact() do artifact_dir
    gzopen(tarball) do unzipped_tar
        Tar.extract(unzipped_tar, artifact_dir)
    end
    srcdir = joinpath(artifact_dir, "timestables-assets-$version")
    mv(joinpath(srcdir,"qml"), joinpath(artifact_dir,"qml"))
    mv(joinpath(srcdir,"sounds"), joinpath(artifact_dir,"sounds"))
    rm(srcdir; recursive=true)
end

bind_artifact!(artifact_toml, "timestables-assets", timeshash; download_info = [(uri, hash)], force=true)