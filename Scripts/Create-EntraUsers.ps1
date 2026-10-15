# ============================================
# Entra ID User Provisioning Script
# ============================================

# Import new hires from CSV
$users = Import-Csv ".\NewHires.csv"

# Entra tenant domain
$domain = "bcook449gmail.onmicrosoft.com"

# Prompt administrator for temporary password
# Password is not stored in the script or CSV
$tempPassword = Read-Host "Enter temporary password"


foreach ($user in $users) {

    # ========================================
    # Generate user account information
    # ========================================

    $username = "$($user.FirstName[0])$($user.LastName)".ToLower()

    $userPrincipalName = "$username@$domain"

    $displayName = "$($user.FirstName) $($user.LastName)"

    Write-Host ""
    Write-Host "Processing: $displayName"
    Write-Host "UPN: $userPrincipalName"


    # ========================================
    # Build temporary password profile
    # ========================================

    $passwordProfile = @{
        Password                      = $tempPassword
        ForceChangePasswordNextSignIn = $true
    }


    # ========================================
    # Check whether user already exists
    # ========================================

    $userExists = Get-MgUser `
        -UserId $userPrincipalName `
        -ErrorAction SilentlyContinue


    if ($userExists) {

        Write-Host "$userPrincipalName already exists. Skipping creation."

        # Store existing user object for later operations
        $entraUser = $userExists
    }

    else {

        # ====================================
        # Create new Entra user
        # ====================================

        try {

            $entraUser = New-MgUser `
                -DisplayName $displayName `
                -UserPrincipalName $userPrincipalName `
                -MailNickname $username `
                -PasswordProfile $passwordProfile `
                -AccountEnabled `
                -JobTitle $user.JobTitle `
                -Department $user.Department `
                -OfficeLocation $user.Location `
                -ErrorAction Stop

            Write-Host "SUCCESS: Created $userPrincipalName"
        }

        catch {

            Write-Host "FAILED: Could not create $userPrincipalName"
            Write-Host "Reason: $($_.Exception.Message)"

            # Skip remaining operations for this employee
            continue
        }
    }


    # ========================================
    # Determine department security group
    # ========================================

    $groupName = "SG-$($user.Department)-Users"

    $departmentGroup = Get-MgGroup `
        -Filter "displayName eq '$groupName'"

    Write-Host "Department group: $groupName"


    # ========================================
    # Verify department group exists
    # ========================================

    if ($departmentGroup) {

        Write-Host "Group ID: $($departmentGroup.Id)"
        Write-Host "User ID: $($entraUser.Id)"


        # ====================================
        # Check existing group membership
        # ====================================

        $existingMember = Get-MgGroupMember `
            -GroupId $departmentGroup.Id `
            -All |
            Where-Object { $_.Id -eq $entraUser.Id }


        if ($existingMember) {

            Write-Host "$displayName is already a member of $groupName. Skipping."
        }

        else {

            # ================================
            # Add user to department group
            # ================================

            try {

                New-MgGroupMember `
                    -GroupId $departmentGroup.Id `
                    -DirectoryObjectId $entraUser.Id `
                    -ErrorAction Stop

                Write-Host "SUCCESS: Added $displayName to $groupName"
            }

            catch {

                Write-Host "FAILED: Could not add $displayName to $groupName"
                Write-Host "Reason: $($_.Exception.Message)"
            }
        }
    }

    else {

        Write-Host "WARNING: $groupName does not exist."
        Write-Host "Skipping group assignment for $displayName."
    }
}