# 1. Kill any existing instances first as requested
Get-Process WorldClock -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$dataFile = Join-Path $PSScriptRoot "clocks.json"

# Default 5 countries
$defaultClocks = @(
    @{ Flag = "🇮🇳"; Country = "India"; City = "New Delhi"; TimeZone = "+05:30"; Code = "IST" },
    @{ Flag = "🇺🇸"; Country = "USA"; City = "New York"; TimeZone = "-04:00"; Code = "EDT/EST" },
    @{ Flag = "🇬🇧"; Country = "UK"; City = "London"; TimeZone = "+01:00"; Code = "GMT/BST" },
    @{ Flag = "🇦🇪"; Country = "UAE"; City = "Dubai"; TimeZone = "+04:00"; Code = "GST" },
    @{ Flag = "🇯🇵"; Country = "Japan"; City = "Tokyo"; TimeZone = "+09:00"; Code = "JST" }
)

# Load saved clocks
if (Test-Path $dataFile) {
    try {
        $raw = Get-Content $dataFile -Raw | ConvertFrom-Json
        $clocksList = [System.Collections.ArrayList]@()
        foreach ($c in $raw) {
            $clocksList.Add([ordered]@{
                Flag     = [string]$c.Flag
                Country  = [string]$c.Country
                City     = [string]$c.City
                TimeZone = [string]$c.TimeZone
                Code     = [string]$c.Code
            }) | Out-Null
        }
        if ($clocksList.Count -eq 0) {
            $clocksList = [System.Collections.ArrayList]@($defaultClocks)
        }
    } catch {
        $clocksList = [System.Collections.ArrayList]@($defaultClocks)
    }
} else {
    $clocksList = [System.Collections.ArrayList]@($defaultClocks)
}

function Save-ClocksData {
    try {
        $json = $clocksList | ConvertTo-Json -Depth 5
        Set-Content -Path $dataFile -Value $json -Force
    } catch {}
}

# Single Screen XAML: Contains List Container and In-Place Form Container (NO POPUP WINDOWS)
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="World Clock"
        Height="480" Width="340"
        MinWidth="260" MinHeight="220"
        WindowStyle="None"
        ResizeMode="CanResize"
        Background="#14151b"
        Topmost="True"
        ShowInTaskbar="True"
        WindowStartupLocation="CenterScreen">

    <Border Background="#14151b" BorderBrush="#2e313e" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="40"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- 1. Header Bar: ONLY THIS BAR IS DRAGGABLE -->
            <Border Name="HeaderBar" Grid.Row="0" Background="#1c1e26" CornerRadius="11,11,0,0" BorderBrush="#2a2c38" BorderThickness="0,0,0,1">
                <Grid Margin="12,0,8,0">
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Name="HeaderIcon" Text="🌍" FontSize="14" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBlock Name="HeaderTitle" Text="World Clock" FontSize="13" FontWeight="SemiBold" Foreground="#f1f5f9" VerticalAlignment="Center"/>
                    </StackPanel>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                        <Button Name="PinBtn" Content="📌" Background="Transparent" Foreground="#38bdf8" BorderThickness="0" FontSize="12" Width="28" Height="28" ToolTip="Pin on Top"/>
                        <Button Name="MinBtn" Background="Transparent" Foreground="#94a3b8" BorderThickness="0" Width="28" Height="28" ToolTip="Minimize">
                            <Path Data="M 11,1 L 7,5 M 11,5 L 7,5 L 7,1 M 1,11 L 5,7 M 1,7 L 5,7 L 5,11" Stroke="#94a3b8" StrokeThickness="1.4" StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round" Width="12" Height="12"/>
                        </Button>
                        <Button Name="CloseBtn" Content="✕" Background="Transparent" Foreground="#94a3b8" BorderThickness="0" FontSize="13" FontWeight="Bold" Width="28" Height="28" ToolTip="Close"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- 2. Main Body: Switchable In-Place between Cards List and Edit/Add Form -->
            <Grid Grid.Row="1">
                <!-- VIEW A: Cards List -->
                <ScrollViewer Name="CardsScrollViewer" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Margin="0,4,0,4">
                    <StackPanel Name="CardsPanel" Margin="10,2,10,2"/>
                </ScrollViewer>

                <!-- VIEW B: In-Place Edit/Add Form (Rendered inside the exact same screen, NO NEW WINDOW) -->
                <Grid Name="FormViewContainer" Visibility="Collapsed" Margin="14,10,14,10">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- Form Header Banner -->
                    <Border Grid.Row="0" Background="#1c1f2b" CornerRadius="8" Padding="10,6" Margin="0,0,0,10" BorderBrush="#2d3345" BorderThickness="1">
                        <TextBlock Name="FormModeTitle" Text="Edit Country" FontSize="12" FontWeight="Bold" Foreground="#38bdf8" HorizontalAlignment="Center"/>
                    </Border>

                    <!-- Form Fields -->
                    <StackPanel Grid.Row="1" VerticalAlignment="Top">
                        <TextBlock Text="Country Name:" FontSize="11" Foreground="#94a3b8" Margin="0,0,0,2"/>
                        <TextBox Name="TxtCountry" Background="#20222b" Foreground="#f8fafc" BorderBrush="#2e313d" Padding="8,4" FontSize="12" Margin="0,0,0,8"/>

                        <TextBlock Text="City Name:" FontSize="11" Foreground="#94a3b8" Margin="0,0,0,2"/>
                        <TextBox Name="TxtCity" Background="#20222b" Foreground="#f8fafc" BorderBrush="#2e313d" Padding="8,4" FontSize="12" Margin="0,0,0,8"/>

                        <TextBlock Text="TimeZone or Offset (+5:30, -4, GMT):" FontSize="11" Foreground="#94a3b8" Margin="0,0,0,2"/>
                        <TextBox Name="TxtTz" Background="#20222b" Foreground="#f8fafc" BorderBrush="#2e313d" Padding="8,4" FontSize="12" Margin="0,0,0,8"/>

                        <TextBlock Text="Timezone Code (IST, EDT, etc.):" FontSize="11" Foreground="#94a3b8" Margin="0,0,0,2"/>
                        <TextBox Name="TxtCode" Background="#20222b" Foreground="#f8fafc" BorderBrush="#2e313d" Padding="8,4" FontSize="12" Margin="0,0,0,6"/>
                    </StackPanel>

                    <!-- Form Buttons -->
                    <Border Grid.Row="2" Padding="0,8,0,0">
                        <Grid>
                            <Button Name="BtnDelete" Content="🗑 Delete" Background="#3a1c22" Foreground="#f87171" BorderBrush="#6b212e" BorderThickness="1" Padding="10,6" FontSize="11" HorizontalAlignment="Left" Visibility="Collapsed"/>
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                <Button Name="BtnCancel" Content="Cancel" Background="#20222b" Foreground="#94a3b8" BorderBrush="#2f313e" BorderThickness="1" Padding="12,6" Margin="0,0,8,0" FontSize="11"/>
                                <Button Name="BtnSave" Content="✓ Save" Background="#0284c7" Foreground="#ffffff" BorderThickness="0" Padding="16,6" FontWeight="SemiBold" FontSize="11"/>
                            </StackPanel>
                        </Grid>
                    </Border>
                </Grid>
            </Grid>

            <!-- 3. Footer Bar with "+" Add Button -->
            <Border Name="FooterBar" Grid.Row="2" Background="#181921" CornerRadius="0,0,11,11" BorderBrush="#252733" BorderThickness="0,1,0,0" Padding="10,6">
                <Button Name="AddBtn" HorizontalAlignment="Center" Background="#222530" Foreground="#38bdf8" BorderBrush="#2e3344" BorderThickness="1" Padding="16,6" ToolTip="Add New Country Clock">
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="＋" FontWeight="Bold" FontSize="14" Foreground="#38bdf8" Margin="0,0,6,0" VerticalAlignment="Center"/>
                        <TextBlock Text="Add Country" FontSize="11" FontWeight="SemiBold" Foreground="#e2e8f0" VerticalAlignment="Center"/>
                    </StackPanel>
                </Button>
            </Border>
        </Grid>
    </Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Enable 3-Side Resizing (Left, Right, Bottom - Top excluded)
$chrome = New-Object System.Windows.Shell.WindowChrome
$chrome.CaptionHeight = 0
$chrome.ResizeBorderThickness = New-Object System.Windows.Thickness(6, 0, 6, 6)
$chrome.GlassFrameThickness = New-Object System.Windows.Thickness(0)
$chrome.CornerRadius = New-Object System.Windows.CornerRadius(0)
$chrome.UseAeroCaptionButtons = $false
[System.Windows.Shell.WindowChrome]::SetWindowChrome($window, $chrome)

# Find controls
$headerBar = $window.FindName("HeaderBar")
$headerIcon = $window.FindName("HeaderIcon")
$headerTitle = $window.FindName("HeaderTitle")
$pinBtn = $window.FindName("PinBtn")
$minBtn = $window.FindName("MinBtn")
$closeBtn = $window.FindName("CloseBtn")

$cardsScrollViewer = $window.FindName("CardsScrollViewer")
$cardsPanel = $window.FindName("CardsPanel")
$footerBar = $window.FindName("FooterBar")
$addBtn = $window.FindName("AddBtn")

$formViewContainer = $window.FindName("FormViewContainer")
$formModeTitle = $window.FindName("FormModeTitle")
$tCountry = $window.FindName("TxtCountry")
$tCity = $window.FindName("TxtCity")
$tTz = $window.FindName("TxtTz")
$tCode = $window.FindName("TxtCode")
$btnDelete = $window.FindName("BtnDelete")
$btnCancel = $window.FindName("BtnCancel")
$btnSave = $window.FindName("BtnSave")

# Drag ONLY from HeaderBar
$headerBar.Add_MouseLeftButtonDown({
    if ($_.LeftButton -eq [System.Windows.Input.MouseButtonState]::Pressed) {
        $window.DragMove()
    }
})

# Minimize handler
$minBtn.Add_Click({
    $window.WindowState = [System.Windows.WindowState]::Minimized
})

# Close handler
$closeBtn.Add_Click({
    $window.Close()
})

# Pin handler
$script:isPinned = $true
$pinBtn.Add_Click({
    $script:isPinned = -not $script:isPinned
    $window.Topmost = $script:isPinned
    if ($script:isPinned) {
        $pinBtn.Content = "📌"
        $pinBtn.Foreground = [System.Windows.Media.Brushes]::DeepSkyBlue
    } else {
        $pinBtn.Content = "📍"
        $pinBtn.Foreground = [System.Windows.Media.Brushes]::SlateGray
    }
})

# Smart Global Presets Database
$globalPresets = @{
    "india" = @{ Country = "India"; City = "New Delhi"; Flag = "🇮🇳"; Tz = "India Standard Time"; Code = "IST" }
    "delhi" = @{ Country = "India"; City = "New Delhi"; Flag = "🇮🇳"; Tz = "India Standard Time"; Code = "IST" }
    "mumbai" = @{ Country = "India"; City = "Mumbai"; Flag = "🇮🇳"; Tz = "India Standard Time"; Code = "IST" }
    "usa" = @{ Country = "USA"; City = "New York"; Flag = "🇺🇸"; Tz = "Eastern Standard Time"; Code = "EDT/EST" }
    "new york" = @{ Country = "USA"; City = "New York"; Flag = "🇺🇸"; Tz = "Eastern Standard Time"; Code = "EDT/EST" }
    "america" = @{ Country = "USA"; City = "New York"; Flag = "🇺🇸"; Tz = "Eastern Standard Time"; Code = "EDT/EST" }
    "california" = @{ Country = "USA"; City = "Los Angeles"; Flag = "🇺🇸"; Tz = "Pacific Standard Time"; Code = "PDT/PST" }
    "los angeles" = @{ Country = "USA"; City = "Los Angeles"; Flag = "🇺🇸"; Tz = "Pacific Standard Time"; Code = "PDT/PST" }
    "chicago" = @{ Country = "USA"; City = "Chicago"; Flag = "🇺🇸"; Tz = "Central Standard Time"; Code = "CDT/CST" }
    "uk" = @{ Country = "UK"; City = "London"; Flag = "🇬🇧"; Tz = "GMT Standard Time"; Code = "GMT/BST" }
    "london" = @{ Country = "UK"; City = "London"; Flag = "🇬🇧"; Tz = "GMT Standard Time"; Code = "GMT/BST" }
    "uae" = @{ Country = "UAE"; City = "Dubai"; Flag = "🇦🇪"; Tz = "Arabian Standard Time"; Code = "GST" }
    "dubai" = @{ Country = "UAE"; City = "Dubai"; Flag = "🇦🇪"; Tz = "Arabian Standard Time"; Code = "GST" }
    "japan" = @{ Country = "Japan"; City = "Tokyo"; Flag = "🇯🇵"; Tz = "Tokyo Standard Time"; Code = "JST" }
    "tokyo" = @{ Country = "Japan"; City = "Tokyo"; Flag = "🇯🇵"; Tz = "Tokyo Standard Time"; Code = "JST" }
    "australia" = @{ Country = "Australia"; City = "Sydney"; Flag = "🇦🇺"; Tz = "AUS Eastern Standard Time"; Code = "AEST" }
    "sydney" = @{ Country = "Australia"; City = "Sydney"; Flag = "🇦🇺"; Tz = "AUS Eastern Standard Time"; Code = "AEST" }
    "canada" = @{ Country = "Canada"; City = "Toronto"; Flag = "🇨🇦"; Tz = "Eastern Standard Time"; Code = "EDT/EST" }
    "toronto" = @{ Country = "Canada"; City = "Toronto"; Flag = "🇨🇦"; Tz = "Eastern Standard Time"; Code = "EDT/EST" }
    "vancouver" = @{ Country = "Canada"; City = "Vancouver"; Flag = "🇨🇦"; Tz = "Pacific Standard Time"; Code = "PDT/PST" }
    "germany" = @{ Country = "Germany"; City = "Berlin"; Flag = "🇩🇪"; Tz = "W. Europe Standard Time"; Code = "CET/CEST" }
    "berlin" = @{ Country = "Germany"; City = "Berlin"; Flag = "🇩🇪"; Tz = "W. Europe Standard Time"; Code = "CET/CEST" }
    "france" = @{ Country = "France"; City = "Paris"; Flag = "🇫🇷"; Tz = "Romance Standard Time"; Code = "CET/CEST" }
    "paris" = @{ Country = "France"; City = "Paris"; Flag = "🇫🇷"; Tz = "Romance Standard Time"; Code = "CET/CEST" }
    "singapore" = @{ Country = "Singapore"; City = "Singapore"; Flag = "🇸🇬"; Tz = "Singapore Standard Time"; Code = "SGT" }
    "china" = @{ Country = "China"; City = "Beijing"; Flag = "🇨🇳"; Tz = "China Standard Time"; Code = "CST" }
    "russia" = @{ Country = "Russia"; City = "Moscow"; Flag = "🇷🇺"; Tz = "Russian Standard Time"; Code = "MSK" }
    "saudi arabia" = @{ Country = "Saudi Arabia"; City = "Riyadh"; Flag = "🇸🇦"; Tz = "Arab Standard Time"; Code = "AST" }
    "qatar" = @{ Country = "Qatar"; City = "Doha"; Flag = "🇶🇦"; Tz = "Arab Standard Time"; Code = "AST" }
    "nepal" = @{ Country = "Nepal"; City = "Kathmandu"; Flag = "🇳🇵"; Tz = "Nepal Standard Time"; Code = "NPT" }
    "bangladesh" = @{ Country = "Bangladesh"; City = "Dhaka"; Flag = "🇧🇩"; Tz = "Bangladesh Standard Time"; Code = "BST" }
    "pakistan" = @{ Country = "Pakistan"; City = "Islamabad"; Flag = "🇵🇰"; Tz = "Pakistan Standard Time"; Code = "PKT" }
    "turkey" = @{ Country = "Turkey"; City = "Istanbul"; Flag = "🇹🇷"; Tz = "Turkey Standard Time"; Code = "TRT" }
    "new zealand" = @{ Country = "New Zealand"; City = "Auckland"; Flag = "🇳🇿"; Tz = "New Zealand Standard Time"; Code = "NZST" }
    "switzerland" = @{ Country = "Switzerland"; City = "Zurich"; Flag = "🇨🇭"; Tz = "W. Europe Standard Time"; Code = "CET" }
    "south africa" = @{ Country = "South Africa"; City = "Johannesburg"; Flag = "🇿🇦"; Tz = "South Africa Standard Time"; Code = "SAST" }
    "brazil" = @{ Country = "Brazil"; City = "Sao Paulo"; Flag = "🇧🇷"; Tz = "E. South America Standard Time"; Code = "BRT" }
}

function Find-SinglePreset($text) {
    if ([string]::IsNullOrWhiteSpace($text) -or $text.Trim().Length -lt 2) { return $null }
    $k = $text.Trim().ToLowerInvariant()
    if ($globalPresets.ContainsKey($k)) { return $globalPresets[$k] }
    if ($k.Length -ge 3) {
        foreach ($entry in $globalPresets.GetEnumerator()) {
            if ($entry.Key.StartsWith($k) -or $k.StartsWith($entry.Key)) {
                return $entry.Value
            }
        }
    }
    return $null
}

function Find-Preset($text) {
    if ([string]::IsNullOrWhiteSpace($text) -or $text.Trim().Length -lt 2) { return $null }

    # Check for multi-country delimiters: '/', ',', '&', '+'
    $delimiters = @('/', ',', '&', '+')
    $hasDelim = $false
    foreach ($d in $delimiters) { if ($text.Contains($d)) { $hasDelim = $true; break } }

    if ($hasDelim) {
        $parts = $text.Split($delimiters, [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Trim() } | Where-Object { $_.Length -ge 2 }
        if ($parts.Count -gt 0) {
            $matched = @()
            foreach ($part in $parts) {
                $m = Find-SinglePreset $part
                if ($m -and -not ($matched | Where-Object { $_.Country -eq $m.Country })) {
                    $matched += $m
                }
            }
            if ($matched.Count -gt 0) {
                $primary = $matched[0]
                $flags = ($matched | ForEach-Object { $_.Flag } | Select-Object -Unique) -join " "
                $cities = ($matched | ForEach-Object { $_.City } | Select-Object -Unique) -join " / "
                $codes = ($matched | ForEach-Object { $_.Code } | Select-Object -Unique) -join "/"
                return @{
                    Country = $text.Trim()
                    City    = $cities
                    Flag    = $flags
                    Tz      = $primary.Tz
                    Code    = if ($codes.Length -gt 8) { $primary.Code } else { $codes }
                }
            }
        }
    }

    return Find-SinglePreset $text
}

# Auto-detect location when user types
$script:autoFilling = $false

$onCountryChanged = {
    if ($script:autoFilling) { return }
    $text = $tCountry.Text.Trim()
    
    # When country is cleared or empty -> IMMEDIATELY clean all fields!
    if ([string]::IsNullOrWhiteSpace($text)) {
        $script:autoFilling = $true
        $tCity.Text = ""
        $tTz.Text = ""
        $tCode.Text = ""
        $script:autoFilling = $false
        return
    }

    $p = Find-Preset $text
    if ($p) {
        $script:autoFilling = $true
        $tCity.Text = $p.City
        $tTz.Text = $p.Tz
        $tCode.Text = $p.Code
        $script:autoFilling = $false
    }
    # Note: If no preset matched (e.g. user adds '/Qatar' or notes), do NOT wipe existing values!
}

$onCityChanged = {
    if ($script:autoFilling) { return }
    $text = $tCity.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($text) -or $text.Length -lt 2) { return }

    $p = Find-Preset $text
    if ($p) {
        $script:autoFilling = $true
        if ([string]::IsNullOrWhiteSpace($tCountry.Text)) {
            $tCountry.Text = $p.Country
        }
        $tTz.Text = $p.Tz
        $tCode.Text = $p.Code
        $script:autoFilling = $false
    }
}

$tCountry.Add_TextChanged($onCountryChanged)
$tCity.Add_TextChanged($onCityChanged)

# Helper function to get local time with GMT/UTC offset
function Get-LocalTimeWithOffset($inputStr) {
    $utc = [DateTime]::UtcNow
    if ([string]::IsNullOrWhiteSpace($inputStr)) { return @{ Time = $utc; Offset = "UTC+0" } }

    try {
        $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById($inputStr.Trim())
        $dt = [System.TimeZoneInfo]::ConvertTimeFromUtc($utc, $tz)
        $off = $tz.GetUtcOffset($utc)
        $sign = if ($off.TotalMinutes -ge 0) { "+" } else { "-" }
        $h = [Math]::Abs($off.Hours)
        $m = [Math]::Abs($off.Minutes)
        $offStr = if ($m -gt 0) { "UTC" + $sign + $h + ":" + $m.ToString("D2") } else { "UTC" + $sign + $h }
        return @{ Time = $dt; Offset = $offStr }
    } catch {}

    $clean = $inputStr.Trim().ToUpper().Replace("UTC", "").Replace("GMT", "").Trim()
    $ts = [TimeSpan]::Zero
    if ([TimeSpan]::TryParse($clean, [ref]$ts)) {
        $sign = if ($ts.TotalMinutes -ge 0) { "+" } else { "-" }
        $h = [Math]::Abs($ts.Hours)
        $m = [Math]::Abs($ts.Minutes)
        $offStr = if ($m -gt 0) { "UTC" + $sign + $h + ":" + $m.ToString("D2") } else { "UTC" + $sign + $h }
        return @{ Time = $utc.Add($ts); Offset = $offStr }
    }

    return @{ Time = $utc; Offset = "UTC+0" }
}

# State Tracking
$script:editingIndex = -1
$script:isFormActive = $false

# View Switchers (Single Screen In-Place!)
function Show-CardsListView {
    $script:isFormActive = $false
    $formViewContainer.Visibility = [System.Windows.Visibility]::Collapsed
    $cardsScrollViewer.Visibility = [System.Windows.Visibility]::Visible
    $footerBar.Visibility = [System.Windows.Visibility]::Visible
    $headerIcon.Text = "🌍"
    $headerTitle.Text = "World Clock"
    Render-AllCards
    Update-AllTimes
}

function Show-InPlaceEditForm($index) {
    $script:isFormActive = $true
    $script:editingIndex = $index
    $item = $clocksList[$index]

    $cardsScrollViewer.Visibility = [System.Windows.Visibility]::Collapsed
    $footerBar.Visibility = [System.Windows.Visibility]::Collapsed
    $formViewContainer.Visibility = [System.Windows.Visibility]::Visible

    $headerIcon.Text = "✏️"
    $headerTitle.Text = "Edit Clock"
    $formModeTitle.Text = "Edit Country: " + $item.Country

    # PRE-FILL WITH SELECTED ITEM'S DATA!
    $script:autoFilling = $true
    $tCountry.Text = [string]$item.Country
    $tCity.Text = [string]$item.City
    $tTz.Text = [string]$item.TimeZone
    $tCode.Text = [string]$item.Code
    $script:autoFilling = $false

    $btnDelete.Visibility = [System.Windows.Visibility]::Visible
    $btnSave.Content = "✓ Save"
}

function Show-InPlaceAddForm {
    $script:isFormActive = $true
    $script:editingIndex = -1

    $cardsScrollViewer.Visibility = [System.Windows.Visibility]::Collapsed
    $footerBar.Visibility = [System.Windows.Visibility]::Collapsed
    $formViewContainer.Visibility = [System.Windows.Visibility]::Visible

    $headerIcon.Text = "➕"
    $headerTitle.Text = "Add Clock"
    $formModeTitle.Text = "Add New Country"

    # Clean inputs for manual typing - NO stuck values!
    $script:autoFilling = $true
    $tCountry.Text = ""
    $tCity.Text = ""
    $tTz.Text = ""
    $tCode.Text = ""
    $script:autoFilling = $false

    $btnDelete.Visibility = [System.Windows.Visibility]::Collapsed
    $btnSave.Content = "✓ Add"
}

# Form Action Button Handlers
$btnCancel.Add_Click({
    Show-CardsListView
})

$btnDelete.Add_Click({
    if ($script:editingIndex -ge 0 -and $script:editingIndex -lt $clocksList.Count) {
        $clocksList.RemoveAt($script:editingIndex)
        Save-ClocksData
    }
    Show-CardsListView
})

$btnSave.Add_Click({
    if ([string]::IsNullOrWhiteSpace($tCountry.Text)) {
        [System.Windows.MessageBox]::Show("Please enter a Country Name.", "Missing Information", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
        return
    }

    $p = Find-Preset $tCountry.Text
    if (-not $p -and -not [string]::IsNullOrWhiteSpace($tCity.Text)) {
        $p = Find-Preset $tCity.Text
    }

    $entry = [ordered]@{
        Flag     = ""
        Country  = $tCountry.Text.Trim()
        City     = if ([string]::IsNullOrWhiteSpace($tCity.Text)) { if ($p) { $p.City } else { "" } } else { $tCity.Text.Trim() }
        TimeZone = if ([string]::IsNullOrWhiteSpace($tTz.Text) -or $tTz.Text -eq "+00:00") { if ($p) { $p.Tz } else { "+00:00" } } else { $tTz.Text.Trim() }
        Code     = if ([string]::IsNullOrWhiteSpace($tCode.Text) -or $tCode.Text -eq "UTC") { if ($p) { $p.Code } else { "" } } else { $tCode.Text.Trim() }
    }

    if ($script:editingIndex -ge 0 -and $script:editingIndex -lt $clocksList.Count) {
        # Update existing
        $clocksList[$script:editingIndex] = $entry
    } else {
        # Add new
        $clocksList.Add($entry) | Out-Null
    }

    Save-ClocksData
    Show-CardsListView
})

# Reorder helper (Swaps two indices)
function Swap-Cards($fromIdx, $toIdx) {
    if ($fromIdx -lt 0 -or $fromIdx -ge $clocksList.Count) { return }
    if ($toIdx -lt 0 -or $toIdx -ge $clocksList.Count) { return }
    if ($fromIdx -eq $toIdx) { return }

    $temp = $clocksList[$fromIdx]
    $clocksList[$fromIdx] = $clocksList[$toIdx]
    $clocksList[$toIdx] = $temp
    Save-ClocksData
    Render-AllCards
    Update-AllTimes
}

$script:clockUiElements = @()

# Drag/Swipe state
$script:dragActive = $false
$script:dragStartIndex = -1
$script:dragStartY = 0

# Render All Cards
function Render-AllCards {
    $cardsPanel.Children.Clear()
    $script:clockUiElements = @()

    for ($i = 0; $i -lt $clocksList.Count; $i++) {
        $idx = $i
        $item = $clocksList[$idx]

        $cardBorder = New-Object System.Windows.Controls.Border
        $cardBorder.Background = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#20222b")
        $cardBorder.BorderBrush = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#2e313d")
        $cardBorder.BorderThickness = (New-Object System.Windows.Thickness(1))
        $cardBorder.CornerRadius = (New-Object System.Windows.CornerRadius(8))
        $cardBorder.Margin = (New-Object System.Windows.Thickness(0, 3, 0, 3))
        $cardBorder.Padding = (New-Object System.Windows.Thickness(10, 8, 10, 8))

        $grid = New-Object System.Windows.Controls.Grid

        # 1. Country & City (Left - Flag removed)
        $leftStack = New-Object System.Windows.Controls.StackPanel
        $leftStack.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $leftStack.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left

        $cName = New-Object System.Windows.Controls.TextBlock
        $cName.Text = [string]$item.Country
        $cName.FontWeight = [System.Windows.FontWeights]::SemiBold
        $cName.FontSize = 12
        $cName.Foreground = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#f8fafc")
        $leftStack.Children.Add($cName) | Out-Null

        $cCity = New-Object System.Windows.Controls.TextBlock
        $cCity.Text = [string]$item.City
        $cCity.FontSize = 10
        $cCity.Margin = (New-Object System.Windows.Thickness(0, 1, 0, 0))
        $cCity.Foreground = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#94a3b8")
        $leftStack.Children.Add($cCity) | Out-Null
        $grid.Children.Add($leftStack) | Out-Null

        # 2. Time & Date (Right)
        $rightStack = New-Object System.Windows.Controls.StackPanel
        $rightStack.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
        $rightStack.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

        $timeTxt = New-Object System.Windows.Controls.TextBlock
        $timeTxt.Text = "--:--:-- --"
        $timeTxt.FontFamily = (New-Object System.Windows.Media.FontFamily("Consolas"))
        $timeTxt.FontWeight = [System.Windows.FontWeights]::Bold
        $timeTxt.FontSize = 13
        $timeTxt.Foreground = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#38bdf8")
        $timeTxt.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
        $rightStack.Children.Add($timeTxt) | Out-Null

        $dateTxt = New-Object System.Windows.Controls.TextBlock
        $dateTxt.Text = "---"
        $dateTxt.FontSize = 10
        $dateTxt.Foreground = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#64748b")
        $dateTxt.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
        $rightStack.Children.Add($dateTxt) | Out-Null
        $grid.Children.Add($rightStack) | Out-Null

        # ==========================================
        # CARD INTERACTIONS: DOUBLE-CLICK & SWIPE/DRAG
        # ==========================================
        $cardIdx = $idx

        # 1. DOUBLE CLICK: Open In-Place Edit Mode for this specific card
        $cardBorder.Add_MouseLeftButtonDown({
            if ($_.ClickCount -eq 2) {
                $script:dragActive = $false
                $cardBorder.ReleaseMouseCapture()
                Show-InPlaceEditForm $cardIdx
                return
            }

            # Start tracking for Move by Press
            $script:dragActive = $true
            $script:dragStartIndex = $cardIdx
            $script:dragStartY = [System.Windows.Input.Mouse]::GetPosition($window).Y
            $cardBorder.BorderBrush = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#38bdf8")
            $cardBorder.Background = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#272a38")
            $cardBorder.CaptureMouse()
        })

        # 2. MOVE BY PRESS (UP / DOWN)
        $cardBorder.Add_MouseMove({
            if ($script:dragActive -and ($_.LeftButton -eq [System.Windows.Input.MouseButtonState]::Pressed)) {
                $currY = [System.Windows.Input.Mouse]::GetPosition($window).Y
                $deltaY = $currY - $script:dragStartY

                if ($deltaY -lt -26) {
                    # Moved UP
                    $script:dragActive = $false
                    $cardBorder.ReleaseMouseCapture()
                    Swap-Cards $cardIdx ($cardIdx - 1)
                } elseif ($deltaY -gt 26) {
                    # Moved DOWN
                    $script:dragActive = $false
                    $cardBorder.ReleaseMouseCapture()
                    Swap-Cards $cardIdx ($cardIdx + 1)
                }
            }
        })

        $cardBorder.Add_MouseLeftButtonUp({
            $script:dragActive = $false
            $cardBorder.ReleaseMouseCapture()
            $cardBorder.BorderBrush = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#2e313d")
            $cardBorder.Background = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#20222b")
        })

        $cardBorder.Add_MouseLeave({
            if ($_.LeftButton -ne [System.Windows.Input.MouseButtonState]::Pressed) {
                $script:dragActive = $false
                $cardBorder.ReleaseMouseCapture()
                $cardBorder.BorderBrush = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#2e313d")
                $cardBorder.Background = (New-Object System.Windows.Media.BrushConverter).ConvertFromString("#20222b")
            }
        })

        $cardBorder.Child = $grid
        $cardsPanel.Children.Add($cardBorder) | Out-Null

        $script:clockUiElements += @{
            Item    = $item
            TimeTxt = $timeTxt
            DateTxt = $dateTxt
        }
    }
}

# Real-Time Clocks Update (Shows UTC / GMT offset on each card!)
function Update-AllTimes {
    if ($script:isFormActive) { return }
    foreach ($entry in $script:clockUiElements) {
        $res = Get-LocalTimeWithOffset $entry.Item.TimeZone
        $entry.TimeTxt.Text = $res.Time.ToString("hh:mm:ss tt")
        $code = if ($entry.Item.Code) { " • " + $entry.Item.Code } else { "" }
        $entry.DateTxt.Text = $res.Time.ToString("ddd, dd MMM") + " • " + $res.Offset + $code
    }
}

# Add Button Click: Open In-Place Add Mode inside the same screen!
$addBtn.Add_Click({
    Show-InPlaceAddForm
})

# Initial render
Show-CardsListView

# 1-Second Dispatcher Timer
$clockTimer = New-Object System.Windows.Threading.DispatcherTimer
$clockTimer.Interval = [TimeSpan]::FromSeconds(1)
$clockTimer.Add_Tick({ Update-AllTimes })
$clockTimer.Start()

# Run Window
$window.ShowDialog() | Out-Null
