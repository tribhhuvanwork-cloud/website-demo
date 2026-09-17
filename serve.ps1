param(
  [int]$Port = 8234
)

$root = $PSScriptRoot
$listener = [System.Net.HttpListener]::New()
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $root at http://localhost:$Port (press Ctrl+C to stop)"

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.AbsolutePath
    if ($path -eq "/" -or $path -eq "") { $path = "/index.html" }
    $file = [System.IO.Path]::GetFullPath((Join-Path $root ($path -replace "/", "\")))
    $rootFull = [System.IO.Path]::GetFullPath($root)
    if (-not $file.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
      $res.StatusCode = 403
      $res.Close()
      continue
    }
    if (Test-Path -LiteralPath $file -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $mime = switch ($ext) {
        ".html" { "text/html; charset=utf-8" }
        ".js"   { "application/javascript" }
        ".css"  { "text/css" }
        ".png"  { "image/png" }
        ".jpg"  { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".svg"  { "image/svg+xml" }
        ".json" { "application/json" }
        ".txt"  { "text/plain; charset=utf-8" }
        default { "application/octet-stream" }
      }
      $res.ContentType = $mime
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
    }
    $res.Close()
  }
} finally {
  $listener.Stop()
}