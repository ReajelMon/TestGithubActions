# Deze script zorgt ervoor dat elke pagina weergeeft door wie/wanneer het voor het laatst is geüpdatet.

param (
    [string]$gitDirectory,    
    [string]$mdDirectory     # Path waar md files zijn
)

# Verander de huidige locatie naar het git-directory
Set-Location -Path $gitDirectory

# Krijg md en sub md
$mdFiles = Get-ChildItem -Path $mdDirectory -File -Recurse -Filter "*.md"

# Itereer md files
foreach ($file in $mdFiles) {
    # Als bestaat
    if (Test-Path $file.FullName) {
        # Nieuwste commit
        $lastCommitInfo = "Last modified by: $(git log -1 --pretty=format:'%an, Date: %ad' --date=format:'%Y-%m-%d' -- $file.FullName)"

        # Krijg content
        $fileContent = Get-Content -Path $file.FullName

        # Voor veiligheid als er al een comment is, wordt die vervangen
        if ($fileContent -match "Last modified by") {
            $newContent = $fileContent -replace "Last modified by.*$", "`n`n`n$lastCommitInfo"
            Set-Content -Path $file.FullName -Value $newContent
        }
        else {
            # Als die nog niet bestaat wordt die hiermee toegevoegd
            $newContent = $fileContent + "`n`n`n$lastCommitInfo"
            Set-Content -Path $file.FullName -Value $newContent
        }

        Write-Host "Modification notice added/updated in $($file.Name)"
    }
    else {
        Write-Host "File $($file.Name) does not exist in the working directory."
    }
}
