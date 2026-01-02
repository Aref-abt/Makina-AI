$token = 'AIzaSyBOreisoB4EHZc2Z9HWsiYYCNC_SE1asY8'
Get-ChildItem -Recurse -File | ForEach-Object {
    try {
        $path = $_.FullName
        $text = Get-Content -Raw -ErrorAction Stop $path
        if ($text -like "*${token}*") {
            $new = $text -replace [regex]::Escape($token), ''
            Set-Content -NoNewline -Encoding UTF8 $path $new
        }
    } catch {
        # ignore binary or unreadable files
    }
}
