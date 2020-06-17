import java.io.PrintWriter
import java.io.File

@main
def main(path: os.Path) = {
  val rootDir = path.toIO
  if (rootDir.isDirectory()) parseDir(rootDir)
  else println(s"$rootDir is not a directory!")
}

def parseDir(dir: File): Unit = {
  println(s"Parsing $dir...")
  dir
    .listFiles()
    .filter(_.isDirectory())
    .filter(isScalaProject)
    .foreach {d =>
      println(s"found: $d")
      val configFile = new File(s"${sys.env("HOME")}/.itermocil/${d.getName()}.yml")
      val writer = new PrintWriter(configFile, "UTF-8")
      writer.write(template(d))
      writer.close()
    }
}

def isScalaProject(dir: File): Boolean =
  dir
    .listFiles()
    .exists(_.getName() == "build.sbt")

def template(dir: File): String =
  s"""windows:
    |  - name: ${dir.getName()}
    |    root: ${dir.getAbsolutePath()}
    |    layout: main-vertical
    |    panes:
    |      - sbt
    |      - name: git
    |      - name: other
  """.stripMargin
