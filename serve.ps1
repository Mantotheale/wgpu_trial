Set-Location 'c:\Users\a-mantonico\Desktop\Personal\wgpu_trial'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8791/")
$listener.Start()
$mimeMap = @{ ".html"="text/html"; ".js"="text/javascript"; ".wasm"="application/wasm"; ".ts"="text/plain" }
Write-Host "Listening on http://localhost:8791/"
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    $file = Join-Path (Get-Location) ($path.TrimStart("/"))
    if (Test-Path $file -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ext = [System.IO.Path]::GetExtension($file)
        $ctx.Response.ContentType = $mimeMap[$ext]
        if (-not $ctx.Response.ContentType) { $ctx.Response.ContentType = "application/octet-stream" }
        $ctx.Response.ContentLength64 = $bytes.Length
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        Write-Host "200 $path"
    } else {
        $ctx.Response.StatusCode = 404
        Write-Host "404 $path"
    }
    $ctx.Response.OutputStream.Close()
}
