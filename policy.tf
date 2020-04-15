resource "azurerm_policy_definition" "deploy-nsg-diags" {
  name         = "Apply diagnostic settings for Network Security Groups"
  display_name = "[test]: Apply NSG Diagnostics"
  description  = "Applies diagnostic settings to enable NSG logs and send to Log Analytics Workspace"
  policy_type  = "Custom"
  mode         = "All"
  metadata     = local.metadata
  policy_rule  = data.template_file.policyrule.rendered
  parameters   = data.template_file.policyparameter.rendered
}
resource "azurerm_policy_assignment" "nsg-diags-assignment" {
  name                 = "test-apply-nsg-logs"
  scope                = "/subscriptions/${var.subscription_id}"
  policy_definition_id = azurerm_policy_definition.deploy-nsg-diags.id
  description          = "Applies diagnostic settings to enable NSG logs and send to Log Analytics Workspace"
  display_name         = "Apply NSG Diagnostics"
  location             = "uksouth"
  identity { type = "SystemAssigned" }
  parameters = <<PARAMETERS
        {
            "logAnalytics": {
                "value" : "workspace-id"
            }
        }
        PARAMETERS
}

/*
resource "azurerm_policy_remediation" "nsg-diags-remediation" {
  name                 = "remediation-nsg-diagnostics"
  scope                = azurerm_policy_assignment.nsg-diags-assignment.scope
  policy_assignment_id = azurerm_policy_assignment.nsg-diags-assignment.id
  location_filters     = ["UK South"]
}
*/


locals {
  metadata = templatefile("${path.module}/json/metadata.json", {})
}

data "template_file" "policyrule" {
  template = file("${path.module}/json/policyrule.json")
}

data "template_file" "policyparameter" {
  template = file("${path.module}/json/policyparameter.json")
}

output "spn_id" {
  value = azurerm_policy_assignment.nsg-diags-assignment.identity
}
