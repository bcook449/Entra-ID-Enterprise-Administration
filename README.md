# Microsoft Entra ID Enterprise Administration

## Project Overview

This project simulates identity and access management for a fictional organization using Microsoft Entra ID, Microsoft Graph PowerShell, and Azure RBAC.

The goal was to automate common administrative tasks, organize users by department, and implement least-privilege access to Azure resources.

## Technologies Used

- Microsoft Entra ID
- Microsoft Graph PowerShell
- Azure PowerShell
- Azure Role-Based Access Control (RBAC)
- PowerShell 7

## Project Implementation

### 1. Security Group Management
Created departmental security groups for HR, Finance, Sales, Operations, and IT. Developed a PowerShell script to automate group creation and check whether groups already exist.

### 2. User Provisioning
Developed a PowerShell script to provision users from a CSV file, configure temporary passwords, require password changes at first sign-in, and assign users to their department's security group.

### 3. Azure RBAC
Created a dedicated security group, `SG-Azure-VM-Admins`, and assigned it the Virtual Machine Contributor role at the resource group level.

### 4. Privileged Access Management
Created a separate administrative account and assigned it to the privileged security group. Developed a PowerShell script to manage membership with validation, a dry-run option, and an approval prompt.

## PowerShell Scripts

| Script | Purpose |
|---|---|
| Create-EntraGroups.ps1 | Automates departmental security group creation |
| Create-EntraUsers.ps1 | Provisions users and assigns group memberships |
| Assign-AzureRBAC.ps1 | Assigns Azure RBAC permissions to a security group |
| Manage-PrivilegedGroupMembers.ps1 | Manages privileged group membership |

## Validation Screenshots

Screenshots in the `Screenshots` folder demonstrate:

- Departmental security groups
- Provisioned user accounts
- Department group membership
- Azure RBAC role assignment
- Privileged administrator group membership

## Skills Demonstrated

- Identity and access management
- PowerShell automation
- Microsoft Graph administration
- Azure RBAC
- Security group management
- Least-privilege access
- Privileged account separation
