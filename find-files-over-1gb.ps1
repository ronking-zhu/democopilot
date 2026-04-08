# 查找 C 盘下大于 1GB 的文件

try {
    # 检查扫描路径是否存在
    $scanPath = "C:\"
    if (-not (Test-Path -Path $scanPath)) {
        throw "扫描路径 '$scanPath' 不存在，请检查路径是否正确。"
    }

    # 定义文件大小阈值：1GB
    $threshold = 1GB

    # 输出青色提示信息，告知用户扫描已开始
    Write-Host "正在扫描 C 盘，查找大于 1GB 的文件..." -ForegroundColor Cyan

    # 记录扫描开始时间，用于计算耗时
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # 递归遍历 C 盘所有文件，筛选大于 1GB 的文件
    $results = Get-ChildItem -Path $scanPath -Recurse -File -ErrorAction SilentlyContinue |
        # 只保留文件大小超过阈值的文件
        Where-Object { $_.Length -gt $threshold } |
        # 按文件大小降序排列
        Sort-Object Length -Descending |
        # 将每个文件转为自定义对象，包含路径和 GB 大小
        ForEach-Object {
            [PSCustomObject]@{
                # 文件完整路径
                文件路径 = $_.FullName
                # 将字节转为 GB，保留两位小数
                大小_GB  = [math]::Round($_.Length / 1GB, 2)
            }
        }

    # 停止计时
    $stopwatch.Stop()

    # 检查是否找到文件
    if (-not $results -or $results.Count -eq 0) {
        Write-Host "未找到大于 1GB 的文件。" -ForegroundColor Yellow
    } else {
        # 输出找到的文件数量
        Write-Host "共找到 $($results.Count) 个大于 1GB 的文件：" -ForegroundColor Green
        # 以表格形式输出，固定大小列宽 12 字符，长路径允许换行
        $results | Format-Table @{Label="大小(GB)"; Expression={$_.大小_GB}; Width=12},
                                @{Label="文件路径"; Expression={$_.文件路径}} -Wrap
    }

    # 输出扫描耗时
    Write-Host "扫描完成，耗时: $([math]::Round($stopwatch.Elapsed.TotalSeconds, 1)) 秒" -ForegroundColor Green

} catch {
    # 捕获所有异常，输出红色错误信息
    Write-Host "脚本执行出错: $_" -ForegroundColor Red
    # 输出详细错误堆栈，便于调试
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    # 以非零退出码退出
    exit 1
}
