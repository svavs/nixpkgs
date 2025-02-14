{ lib
, stdenv
, fetchFromGitHub
, cmake
, mimalloc
, ninja
, openssl
, zlib
, testers
, mold
}:

stdenv.mkDerivation rec {
  pname = "mold";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "rui314";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mCuKNVWjll9+xYPR6DnwkzPxbn4gR+x+DaCCTI9BXiE=";
  };

  nativeBuildInputs = [ cmake ninja ];

  buildInputs = [ openssl zlib ]
    ++ lib.optionals (!stdenv.isDarwin) [ mimalloc ];

  postPatch = ''
    sed -i CMakeLists.txt -e '/.*set(DEST\ .*/d'
  '';

  cmakeFlags = [ "-DMOLD_USE_SYSTEM_MIMALLOC:BOOL=ON" ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isDarwin [ "-faligned-allocation" ];

  passthru.tests.version = testers.testVersion { package = mold; };

  meta = with lib; {
    description = "A faster drop-in replacement for existing Unix linkers";
    longDescription = ''
      mold is a faster drop-in replacement for existing Unix linkers. It is
      several times faster than the LLVM lld linker. mold is designed to
      increase developer productivity by reducing build time, especially in
      rapid debug-edit-rebuild cycles.
    '';
    homepage = "https://github.com/rui314/mold";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ azahi nitsky ];
    platforms = platforms.unix;
    # https://github.com/NixOS/nixpkgs/pull/189712#issuecomment-1237791234
    broken = (stdenv.isLinux && stdenv.isAarch64);
  };
}
