function Read-ARKIniFile {
	<#
	.SYNOPSIS
	Reads a CyberArk parameter file.

	.DESCRIPTION
	Reads a parameter file, such as DBParm.ini or Vault.ini, returning its lines, its encoding, and the parameters
	found in it.

	Files with a UTF-8 or Unicode byte order mark are read with that encoding; other files are read byte for byte,
	so that unchanged lines are written back unaltered.

	Lines starting with ; or # are comments.

	.PARAMETER Path
	The parameter file.

	.EXAMPLE
	Read-ARKIniFile -Path 'C:\Program Files (x86)\PrivateArk\Server\Conf\DBParm.ini'

	Returns the lines, encoding and parameters of DBParm.ini.
	#>
	[CmdletBinding()]
	param(

		[Parameter(
			Mandatory = $true
		)]
		[ValidateNotNullOrEmpty()]
		[string]$Path

	)

	$Bytes = [System.IO.File]::ReadAllBytes($Path)

	$Encoding = switch ($true) {
		{ $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF } { [System.Text.UTF8Encoding]::new($true); break }
		{ $Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE } { [System.Text.UnicodeEncoding]::new($false, $true); break }
		default { [System.Text.Encoding]::GetEncoding(28591) }
	}

	$Preamble = $Encoding.GetPreamble().Length

	$Lines = $Encoding.GetString($Bytes, $Preamble, $Bytes.Length - $Preamble) -split '\r?\n'

	$Section = $null

	$Parameters = for ($Index = 0; $Index -lt $Lines.Count; $Index++) {

		if ($Lines[$Index] -match '^\s*\[(?<Section>[^\]]+)\]\s*$') {

			$Section = $Matches['Section'].Trim()

		} elseif ($Lines[$Index] -match '^(?<Prefix>\s*(?<Name>[^\s=;#\[][^=]*?)\s*=\s*)(?<Value>.*?)\s*$') {

			[PSCustomObject]@{
				Index   = $Index
				Section = $Section
				Name    = $Matches['Name']
				Value   = $Matches['Value']
				Prefix  = $Matches['Prefix']
			}

		}

	}

	[PSCustomObject]@{
		Encoding   = $Encoding
		Lines      = [System.Collections.Generic.List[string]]$Lines
		Parameters = @($Parameters)
		Sections   = @($Lines | Where-Object { $_ -match '^\s*\[[^\]]+\]\s*$' }).Count
	}

}
