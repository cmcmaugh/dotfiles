{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  bubblewrap,
  ripgrep,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.128.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${finalAttrs.version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-iGuF5hGMC0MjRDfKAH++kjYRpTsQPQDg0650rvsg4jo=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    tar -xzf "$src"
    install -Dm755 codex-x86_64-unknown-linux-musl "$out/bin/codex"
    wrapProgram "$out/bin/codex" --prefix PATH : ${
      lib.makeBinPath [ ripgrep ]
    }
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
})
