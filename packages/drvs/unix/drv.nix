{ stdenv
, fetchgit
,
}:

stdenv.mkDerivation {
  pname = "unix";
  version = "0.0.1";
  src = fetchgit {
    url = "https://gitlab.com/artnoi/unix";
    sha256 = "065gzl30965idk8kvlspvyiryj85xblhjs8cpna5pnbcylqrnllm";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out;
    cp -a ./*  $out/;
    runHook postInstall
  '';
}
