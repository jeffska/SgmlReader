# This script performs the full signing of all the assemblies used in the .nuspec after the build does delay signing
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# make sure the key is installed in a VS container
$MyKeyFile = [System.Environment]::GetEnvironmentVariable("MYKEYFILE")
$kset = "VS_KEY_0A1562821A6BC5D"
if (!$?) {
	Write-Host "Need to install your key into $kset ..."
	sn -q -i "$MyKeyFile" $kset
}

$doc = [System.Xml.Linq.XDocument]::Load("$ScriptDir\..\SgmlReader.nuspec")
$ns = $doc.Root.Name.Namespace.NamespaceName
foreach ($e in $doc.Root.Descendants()) {
	if ($e.Name.LocalName -eq "file") {
		$src = $e.Attribute("src").Value
		if ($src.EndsWith(".dll") -or $src.EndsWith(".exe")) {
			Write-Host "signing $src"
			$path = $ScriptDir + "\\..\\" + $src
			sn -q -Rca $path $kset
		}
	}
}
