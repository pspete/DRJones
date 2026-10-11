# .ExternalHelp DRJones-help.xml
function Set-ARKVaultParameter {
	[CmdletBinding(SupportsShouldProcess)]
	param(

		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName')]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
		[string]$Path,

		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[ValidatePattern('^[\w.-]+$')]
		[string]$Name,

		[Parameter(
			Mandatory = $true,
			Position = 1
		)]
		[AllowEmptyString()]
		[ValidatePattern('^[^\r\n]*$')]
		[string]$Value,

		[Parameter(
			Mandatory = $false
		)]
		[ValidatePattern('^[^\[\]\r\n]+$')]
		[string]$Section

	)

	process {

		$FullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

		$Ini = Read-ARKIniFile -Path $FullPath
		$Lines = $Ini.Lines

		$Existing = @($Ini.Parameters | Where-Object { $_.Name -eq $Name })

		$End = $Lines.Count
		if ($Lines[$End - 1] -eq '') { $End-- }

		if ($Existing.Count -gt 0) {

			foreach ($Parameter in $Existing) { $Lines[$Parameter.Index] = $Parameter.Prefix + $Value }

		} elseif ($Section) {

			$Header = -1
			for ($Index = 0; $Index -lt $End; $Index++) {
				if ($Lines[$Index] -match "^\s*\[\s*$([regex]::Escape($Section))\s*\]\s*$") { $Header = $Index; break }
			}

			if ($Header -lt 0) {

				$Lines.InsertRange($End, [string[]]@("[$Section]", "$Name=$Value"))

			} else {

				$Next = $End
				for ($Index = $Header + 1; $Index -lt $End; $Index++) {
					if ($Lines[$Index] -match '^\s*\[[^\]]+\]\s*$') { $Next = $Index; break }
				}

				$Insert = $Next
				while ($Insert -gt $Header + 1 -and [string]::IsNullOrWhiteSpace($Lines[$Insert - 1])) { $Insert-- }

				$Lines.Insert($Insert, "$Name=$Value")

			}

		} elseif ($Ini.Sections -gt 0) {

			throw "$Name not found in $FullPath. Specify -Section to add it."

		} else {

			$Lines.Insert($End, "$Name=$Value")

		}

		if ($PSCmdlet.ShouldProcess($FullPath, "Set $Name=$Value")) {

			$Bytes = [byte[]]($Ini.Encoding.GetPreamble() + $Ini.Encoding.GetBytes($Lines -join "`r`n"))

			[System.IO.File]::WriteAllBytes($FullPath, $Bytes)

		}

	}

}
