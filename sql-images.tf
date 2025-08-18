locals {
  az_images = {
    # Windows Server base (no plan needed)
    win2019_base = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
      plan      = null
    }

    win2019_core = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter-Core"
      version   = "latest"
      plan      = null
    }

    # SQL Server 2019 on Windows Server 2019 (plan REQUIRED)
    win2019_base_sql2019_enterprise = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "enterprise"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2019-ws2019"
        name      = "enterprise"
      }
    }

    win2019_base_sql2019_standard = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "standard"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2019-ws2019"
        name      = "standard"
      }
    }

    win2019_base_sql2019_web = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "web"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2019-ws2019"
        name      = "web"
      }
    }

    win2019_base_sql2019_express = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "express"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2019-ws2019"
        name      = "express"
      }
    }

    # SQL Server 2022 on Windows Server 2019 (plan REQUIRED)
    win2019_base_sql2022_enterprise = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2022-ws2019"
      sku       = "enterprise"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2022-ws2019"
        name      = "enterprise"
      }
    }

    win2019_base_sql2022_standard = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2022-ws2019"
      sku       = "standard"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2022-ws2019"
        name      = "standard"
      }
    }

    win2019_base_sql2022_web = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2022-ws2019"
      sku       = "web"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2022-ws2019"
        name      = "web"
      }
    }

    win2019_base_sql2022_express = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2022-ws2019"
      sku       = "express"
      version   = "latest"
      plan = {
        publisher = "MicrosoftSQLServer"
        product   = "sql2022-ws2019"
        name      = "express"
      }
    }
  }
}


output "publisher" {
  value = local.selected_image.publisher
}
output "offer" {
  value = local.selected_image.offer
}
output "sku" {
  value = local.selected_image.sku
}
output "version" {
  value = local.selected_image.version
}
output "plan" {
  value = local.selected_image.plan
}

dynamic "plan" {
  for_each = module.image.plan != null ? [module.image.plan] : []
  content {
    publisher = plan.value.publisher
    product   = plan.value.product
    name      = plan.value.name
  }
}
