##############################################################################
# Access Group Rules
##############################################################################

variable access_groups {
    description = "A list of access groups to create"
    type        = list(
        object({
            name        = string # Name of the group
            description = string # Description of group
            policies    = list(
                object({
                    name      = string       # Name of the policy
                    roles     = list(string) # list of roles for the policy
                    resources = object({
                        resource_group       = optional(string) # Name of the resource group the policy will apply to
                        resource_type        = optional(string) # Name of the resource type for the policy ex. "resource-group"
                        resource             = optional(string) # The resource of the policy definition
                        service              = optional(string) # Name of the service type for the policy ex. "cloud-object-storage"
                        resource_instance_id = optional(string) # ID of a service instance to give permissions
                    })
                })
            )
            dynamic_policies = optional(
                list(
                    object({
                        name              = string # Dynamic group name
                        identity_provider = string # URI for identity provider
                        expiration        = number # How many hours authenticated users can work before refresh
                        conditions        = object({
                                claim    = string # key value to evaluate the condition against.
                                operator = string # The operation to perform on the claim. Supported values are EQUALS, EQUALS_IGNORE_CASE, IN, NOT_EQUALS_IGNORE_CASE, NOT_EQUALS, and CONTAINS.
                                value    = string # Value to be compared agains
                        })
                    })
                )
            )
            account_management_policies = optional(list(string))
            invite_users                = list(string) # Users to invite to the access group
        })
    )
    default     = [
        {
            name        = "admin"
            description = "An example admin group"
            policies    = [
                {
                    name = "admin_all"
                    resources = {
                        resource_group = "asset-development"
                    }
                    roles = ["Administrator","Manager"]
                },
                {
                    name = "admin_service"
                    resources = {
                        service = "cloud-object-storage"
                        resource_group = "asset-development"
                    }
                    roles = ["Content Reader"]
                },
                {
                    name = "admin_rg"
                    resources = {
                        resource_group = "asset-development"
                        resource_type  = "resource-group" 
                    }
                    roles = ["Editor","Manager"]
                },
            ]
            dynamic_policies = [
                {
                    name              = "newrule"
                    expiration        = 4
                    identity_provider = "test-idp.com"
                    conditions = {
                        claim    = "blueGroups"
                        operator = "CONTAINS"
                        value    = "\"test-bluegroup-saml\""
                    }
                }
            ]
            invite_users = [ "test@test.test" ]
        },
        {
            name        = "admin_default"
            description = "An example admin group"
            policies    = [
                {
                    name = "admin_default_all"
                    resources = {
                        resource_group = "default"
                    }
                    roles = ["Administrator","Manager"]
                },
                {
                    name = "admin_default_ervice"
                    resources = {
                        service = "cloud-object-storage"
                        resource_group = "default"
                    }
                    roles = ["Content Reader"]
                },
                {
                    name = "admin_default_rg"
                    resources = {
                        resource_group = "default"
                        resource_type  = "resource-group" 
                    }
                    roles = ["Editor","Manager"]
                },
            ]
            invite_users = [ "test@test.test" ]
        }
        
    ]
}

##############################################################################