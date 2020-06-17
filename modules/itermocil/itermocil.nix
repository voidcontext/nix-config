{pkgs, buildPythonApplication, ...}:

buildPythonApplication rec {
  name = "itermocil";

  src = pkgs.fetchFromGitHub {
    owner = "TomAnthony";
    repo = "itermocil";
    rev = "7409cdb610370c8d23ef405ece75ef6fbe3a35da";
    sha256 = "15i7z14ch24b0sxx9y7jpbz29mg0mq1v6y7lvcwl7v6c3k4b6s6k";
  };

  propagatedBuildInputs = [
    pkgs.libyaml
    pkgs.python27Packages.pyyaml
  ];
}

