output "vm_public_ip" {
  description = "The public IP address of the VM"
  value       = azurerm_public_ip.infra_publicip.ip_address
}

output "sql_server_user" {
  description = "SQL Server DB login user name"
  value       = azurerm_mssql_server.infra_sqlserver.administrator_login
}

output "admin_username" {
  description = "Admin username for the VM"
  value       = azurerm_linux_virtual_machine.infra_vm.admin_username
  # sensitive   = true
}
