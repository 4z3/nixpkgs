{ fetchurl, stdenv, makeDesktopItem, unzip, bash, jre8 }:

stdenv.mkDerivation rec {
  name = "josm-${version}";
  version = "9900";

  src = fetchurl {
    url = "https://josm.openstreetmap.de/download/josm-snapshot-${version}.jar";
    sha256 = "1dsfamh2bsiz3xkhmh7g4jz6bbh25x22k3zgj1k0v0gj8k6yl7dy";
  };

  phases = [ "installPhase" ];

  buildInputs = [ jre8 ];

  desktopItem = makeDesktopItem {
    name = "josm";
    exec = "josm";
    icon = "josm";
    desktopName = "JOSM";
    genericName = "OpenStreetMap Editor";
    comment = meta.description;
    categories = "Education;Geoscience;Maps;";
  };

  installPhase = ''
    mkdir -p $out/bin $out/share/java
    cp -v $src $out/share/java/josm.jar
    cat > $out/bin/josm <<EOF
    #!${bash}/bin/bash
    exec ${jre8}/bin/java -jar $out/share/java/josm.jar "\$@"
    EOF
    chmod 755 $out/bin/josm

    mkdir -p $out/share/applications
    cp $desktopItem/share/applications"/"* $out/share/applications
    mkdir -p $out/share/pixmaps
    ${unzip}/bin/unzip -p $src images/logo_48x48x32.png > $out/share/pixmaps/josm.png
  '';

  meta = with stdenv.lib; {
    description = "An extensible editor for ​OpenStreetMap";
    homepage = https://josm.openstreetmap.de/;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.rycee ];
    platforms = platforms.all;
  };
}
