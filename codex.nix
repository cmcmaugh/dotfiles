{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  bubblewrap,
  ripgrep,
}:

let
  codeModeHostSrc = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v0.152.0/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-RJzv41ufNH4/2/Eh6BYzmzeCXrC/7n3oKYoKYbZofLo=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.152.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${finalAttrs.version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-BflC09PFtazZ7a1WzieXtv5y27FGKyTlyb99zsmiihE=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    tar -xzf "$src"
    tar -xzf "${codeModeHostSrc}"
    install -Dm755 codex-x86_64-unknown-linux-musl "$out/bin/codex"
    install -Dm755 codex-code-mode-host-x86_64-unknown-linux-musl \
      "$out/bin/codex-code-mode-host"
    wrapProgram "$out/bin/codex" --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
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
