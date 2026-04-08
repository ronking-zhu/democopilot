# 查找 C 盘下最占空间的 5 个文件
Write-Host "正在扫描 C 盘，请稍候..." -ForegroundColor Cyan

Get-ChildItem -Path "C:\" -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notlike "*\OneDrive*" } |
    Sort-Object Length -Descending |
    Select-Object -First 5 |
    ForEach-Object {
        [PSCustomObject]@{
            文件路径 = $_.FullName
            大小_MB  = [math]::Round($_.Length / 1MB, 2)
        }
    } |
    Format-Table @{Label="大小(MB)"; Expression={$_.大小_MB}; Width=12},
                 @{Label="文件路径"; Expression={$_.文件路径}} -Wrap
