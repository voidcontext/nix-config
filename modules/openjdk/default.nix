# This derivation has been mostly copied from
# https://github.com/NixOS/nixpkgs/blob/373236ccfffe7053b1503a8992ddff7ebae3ed6f/pkgs/development/compilers/openjdk/darwin/11.nix
# The changes are:
#   - version
#   - lowPrio to avoid clashing share/man

{ pkgs, stdenv, fetchurl, unzip, setJavaClassPath, freetype, lowPrio }:
let
  jce-policies = fetchurl {
    # Ugh, unversioned URLs... I hope this doesn't change often enough to cause pain before we move to a Darwin source build of OpenJDK!
    url    = "http://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip";
    sha256 = "0nk7m0lgcbsvldq2wbfni2pzq8h818523z912i7v8hdcij5s48c0";
  };

  jdk = stdenv.mkDerivation rec {
    name = "zulu11.48.21-ca-jdk11.0.11";

    src = fetchurl {
      url = "https://cdn.azul.com/zulu/bin/${name}-macosx_x64.tar.gz";
      sha256 = "0v0n7h7i04pvna41wpdq2k9qiy70sbbqzqzvazfdvgm3gb22asw6";
      curlOpts = "-H Referer:https://www.azul.com/downloads/zulu/zulu-mac/";
    };

    buildInputs = [ unzip freetype ];

    installPhase = ''
      mkdir -p $out
      mv * $out
      unzip ${jce-policies}
      mv -f ZuluJCEPolicies/*.jar $out/lib/security/
      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/darwin/*_md.h $out/include/
      if [ -f $out/LICENSE ]; then
        install -D $out/LICENSE $out/share/zulu/LICENSE
        rm $out/LICENSE
      fi
    '';

    preFixup = ''
      # Propagate the setJavaClassPath setup hook from the JDK so that
      # any package that depends on the JDK has $CLASSPATH set up
      # properly.
      mkdir -p $out/nix-support
      printWords ${setJavaClassPath} > $out/nix-support/propagated-build-inputs
      install_name_tool -change /usr/X11/lib/libfreetype.6.dylib ${freetype}/lib/libfreetype.6.dylib $out/lib/libfontmanager.dylib
      # Set JAVA_HOME automatically.
      cat <<EOF >> $out/nix-support/setup-hook
      if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
      EOF
    '';

    passthru = {
      home = jdk;
    };

    meta = with pkgs.lib; {
      license = licenses.gpl2;
      platforms = platforms.darwin;
    };

  };
in (lowPrio jdk)
