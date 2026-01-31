### This page describes one of the ways of comparing group membership of Azure EntraID user accounts.

Install Microsoft.Graph module
```
Install-Module Microsoft.Graph -Scope CurrentUser
```
Connect to EntraID
```
Connect-MgGraph -Scopes "User.Read.All","Group.Read.All"
```
Load two user lists with group IDs
```
$stacey =  Get-MgUserMemberOf -UserId stacey.lastname@email.com -All | select Id
$donna =  Get-MgUserMemberOf -UserId donna.lastname@email.com -All | select Id
```
Compare two lists
```
Compare-Object $stacey $donna -Property Id
```
The output will show discrepancies in group IDs
```
Id                                   SideIndicator
--                                   -------------
196f509d-....-....-....-............ =>
e8e766ab-....-....-....-............ =>
d7b0ebeb-....-....-....-............ =>
6b35b13d-....-....-....-............ =>
55e6e99c-....-....-....-............ =>
6dd00efa-....-....-....-............ =>
306e97a8-....-....-....-............ =>
c891e987-....-....-....-............ =>
a6ba68db-....-....-....-............ <=
c00332b4-....-....-....-............ <=
```

**SideIndicator** shows the direction of the discrepancy.
