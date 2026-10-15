#Azure RBAC Assignment Script
$resourceGroupName = "rg-identity-lab-prod"
$groupName = "SG-Azure-VM-Admins"
$roleName = "Virtual Machine Contributor"

 $resourceGroup = Get-AzResourceGroup `
 -Name $resourceGroupName `
 -ErrorAction SilentlyContinue
 
 if (-not $resourceGroup) {

    Write-Host "ERROR: Resource group $resourceGroupName was not found."
    Write-Host "RBAC assignment cannot continue."
    exit
}
 
 $entraGroup = Get-AzADGroup `
 -DisplayName $groupName `

 if (-not $entraGroup) {
    Write-Host "Error: Entra Group $groupName not found"
    Write-Host "RBAC can not continue"
    exit
 }

 $resourceGroup
 $entraGroup | Select-Object DisplayName, Id

 $scope = $resourceGroup.ResourceId
 Write-Host "Scope: $scope"

 $existingAssignment = Get-AzRoleAssignment `
 -ObjectId $entraGroup.Id `
 -RoleDefinitionName $roleName `
 -Scope $scope `
 -ErrorAction SilentlyContinue

 if ($existingAssignment) {
    Write-Host "Assignment already exists."
 } else {
    try {
        New-AzRoleAssignment `
            -ObjectId $entraGroup.Id `
            -RoleDefinitionName $roleName `
            -Scope $scope `
            -ErrorAction Stop

            Write-Host "Success: Assigned $roleName to $groupName"
    }
    catch {
        Write-Host "Error: Failed to assign $roleName to $groupName"
        Write-Host "Reason: $($_.Exception.Message)"
    }
 }
   
 
