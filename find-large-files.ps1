# 查找 C 盘下最占空间的 5 个文件

try {
    # 检查扫描路径是否存在
    $scanPath = "C:\"
    if (-not (Test-Path -Path $scanPath)) {
        throw "扫描路径 '$scanPath' 不存在，请检查路径是否正确。"
    }

    # 输出青色提示信息，告知用户扫描已开始
    Write-Host "正在扫描 C 盘，请稍候..." -ForegroundColor Cyan

    # 记录扫描开始时间，用于计算耗时
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # 递归遍历 C 盘所有文件（-File 只取文件，不含目录；-ErrorAction SilentlyContinue 跳过无权限的目录）
    $results = Get-ChildItem -Path $scanPath -Recurse -File -ErrorAction SilentlyContinue |
        # 过滤掉 OneDrive 目录下的文件
        Where-Object { $_.FullName -notlike "*\OneDrive*" } |
        # 按文件大小（Length 属性，单位字节）降序排列
        Sort-Object Length -Descending |
        # 只取排序后的前 5 个（即最大的 5 个文件）
        Select-Object -First 5 |
        # 将每个文件转为自定义对象，包含路径和 MB 大小
        ForEach-Object {
            [PSCustomObject]@{
                # 文件完整路径
                文件路径 = $_.FullName
                # 将字节转为 MB（除以 1MB），保留两位小数
                大小_MB  = [math]::Round($_.Length / 1MB, 2)
            }
        }

    # 停止计时
    $stopwatch.Stop()

    # 检查是否找到文件
    if (-not $results -or $results.Count -eq 0) {
        Write-Warning "未找到任何文件，请检查路径或权限设置。"
    } else {
        # 以表格形式输出，固定大小列宽 12 字符，长路径允许换行（-Wrap）
        $results | Format-Table @{Label="大小(MB)"; Expression={$_.大小_MB}; Width=12},
                                @{Label="文件路径"; Expression={$_.文件路径}} -Wrap
    }

    # 输出扫描耗时
    Write-Host "扫描完成，耗时: $([math]::Round($stopwatch.Elapsed.TotalSeconds, 1)) 秒" -ForegroundColor Green

} catch {
    # 捕获所有异常，输出红色错误信息
    Write-Host "脚本执行出错: $_" -ForegroundColor Red
    # 输出详细错误堆栈，便于调试
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    # 以非零退出码退出，便于调用方判断执行结果
    exit 1
}
