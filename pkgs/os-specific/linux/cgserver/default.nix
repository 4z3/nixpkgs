{ cabal
, fetchgit
, aeson
, attoparsec
, filepath
, httpTypes
, ioStreams
, safe
, text
, wai
, waiExtra
, warp
}:

cabal.mkDerivation (self: {
  pname = "cgserver";
  version = "0.1.0.0";
  src = fetchgit {
    url = http://viljetic.de/~tv/git/cgserver;
    rev = "9b2bea53c6bc87be639964aaca87c09ab16df486";
    sha256 = "ccee043f3775814dcf2a3bd076818a947a9b1c21655f74622771a93ccee9ff80";
  };
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    aeson
    attoparsec
    filepath
    httpTypes
    ioStreams
    safe
    text
    wai
    waiExtra
    warp
  ];
  meta = {
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
