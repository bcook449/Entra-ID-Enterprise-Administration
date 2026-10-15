
$whatIfMode = $true
$adminUPN = "dnguyen-admin@bcook449gmail.onmicrosoft.com"
$groupName = "SG-Azure-VM-Admins"

$adminUser = Get-Mguser -UserId $adminUPN -ErrorAction Stop
# Validate privileged account naming convention
if ($adminUser.UserPrincipalName -notmatch '^[^@]+-admin@') {
    Write-Host "SECURITY ERROR: Account is not a designated admin account."
    return
}

Write-Host "Privileged account naming convention verified."
$group = Get-MgGroup -Filter "displayName eq '$groupName'" -ErrorAction Stop
# Validate the privileged group
$expectedGroupId = "7774acaa-2912-4a14-bc04-882f102f7e84"

if (-not $group -or $group.Count -ne 1 -or $group.Id -ne $expectedGroupId) {
    Write-Host "ERROR: Privileged group validation failed."
    exit
}

Write-Host "Privileged group identity verified."

$adminUser | Select-Object DisplayName, UserPrincipalName, Id
$group | Select-Object DisplayName, Id
 
try {
    $members = Get-MgGroupMember `
        -GroupId $group.Id `
        -All `
        -ErrorAction Stop
         Write-Host "SUCCESS: Retrieved existing group membership."
}
catch {
    Write-Host "ERROR: Unable to retrieve group membership."
    Write-Host "Reason: $($_.Exception.Message)"
    return
}

$existingMembers = $members | Where-Object {
    $_.Id -eq $adminUser.Id
}

if ($existingMembers) {
    Write-Host "Administrator is already a member of $groupName."
} elseif ($whatIfMode) {
    Write-Host "WhatIf: Administrator would be added to $groupName."
} 
else {
    try {
        $confirmation = Read-Host "Type APPROVE to add $adminUPN to $groupName"
        if ($confirmation -cne "APPROVE") {
            Write-Host "Operation cancelled by user."
            return
        }
        New-MgGroupMember `
            -GroupId $group.Id `
            -DirectoryObjectId $adminUser.Id `
            -ErrorAction Stop
             Write-Host "Administrator added to $groupName successfully."
    }
    catch {
        Write-Host "Failed to add administrator to $groupName."
        Write-Host "Exception: $($_.Exception.Message)"
    }
}

$verifiedMembers = Get-MgGroupMember `
    -GroupId $group.Id `
    -All `
    -ErrorAction Stop

    $verifiedAdmin = $verifiedMembers | Where-Object { $_.Id -eq $adminUser.Id }

   if ($verifiedAdmin) {
    Write-Host "VERIFIED: $adminUPN is a member of $groupName."
}
elseif ($whatIfMode) {
    Write-Host "DRY RUN: No membership changes were made."
    Write-Host "CONFIRMED: $adminUPN is not a member of $groupName."
}
else {
    Write-Host "ERROR: $adminUPN is not a member of $groupName."
    throw "Privileged group membership verification failed."
}

