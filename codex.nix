{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "codex";
  version = "0.163.0";

  dontUnpack = true;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v0.163.0/codex-package-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-WCZGxr8FYesN5UD3/IW5EhsAkagmvG6Wgwt/FyISIYI=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar -xzf "$src" -C "$out"
    runHook postInstall
  '';

  doInstallCheck = false;

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = lib.platforms.unix;
  };
}
