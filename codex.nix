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
    url = "https://github.com/openai/codex/releases/download/rust-v0.156.1/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-qSnaqfagvdwAwMnmQC3xF7ElrNlvnVVPbJnDLH5mxgg=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.156.1";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${finalAttrs.version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-r/RlOag6/4bjxixZK84sUNlTkfnfKJr68DpQwB0UUz0=";
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
