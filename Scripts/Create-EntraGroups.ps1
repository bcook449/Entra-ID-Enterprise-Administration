$departments = @(
    "HR",
    "Finance",
    "Sales", 
    "Operations",
    "IT"
)

foreach ($department in $departments) {
    $groupName = "SG-$($department)-Users"
    Write-Host "Checking group: $groupName"

    $existingGroup = Get-MgGroup `
    -Filter "displayName eq '$groupName'" `
    -ErrorAction Stop

    if ($existingGroup) {
        Write-Host "$groupName already exists. Skipping creation."
    } else {
        try {
            New-MgGroup `
                -DisplayName $groupName `
                -MailEnabled $false `
                -MailNickname ($groupName -replace '-', '') `
                -SecurityEnabled $true `
                -ErrorAction Stop

                Write-Host "SUCCESS: Created $groupName"
        }
        catch {
            Write-Host "ERROR: Failed to create $groupName"
            Write-Host $_.Exception.Message
        }
    }
}

