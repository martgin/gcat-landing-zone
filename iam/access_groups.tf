##############################################################################
# Local Variables
##############################################################################

locals { 
    # Convert access groups from list into object
    access_groups_object = {
        for group in var.access_groups:
        (group.name) => group
    }

    # Add all policies to a single list
    access_policy_list = flatten([
        # For each group
        for group in var.access_groups: [
            # Add policy object to array
            for policy in group.policies:
            # Add `group` field to object
            merge(policy, {group: group.name})
        # Unless no policies
        ] if group.policies != null
    ])

    # Convert access policy list into object
    access_policies = {
        for item in local.access_policy_list:
        (item.name) => item
    }

    # Add all policies to a single list
    dynamic_rule_list = flatten([
        # For each group
        for group in var.access_groups: [
            # Add policy object to array
            for policy in group.dynamic_policies:
            # Add `group` field to object
            merge(policy, {group: group.name})
        # Unless no policies
        ] if group.dynamic_policies != null
    ])

    # Convert access policy list into object
    dynamic_rules = {
        for item in local.dynamic_rule_list:
        (item.name) => item
    }


    # Account management list
    account_management_list = {
        for group in var.access_groups:
        group.name => {
            group = group.name
            roles = group.account_management_policies
        } if group.account_management_policies != null
    }


    # Get a list of all resource groups from access groups
    resource_groups = distinct(
        flatten([ 
            # For each group
            for group in var.access_groups: [
                [
                    # For each policy
                    for policy in group.policies:
                    # if the policy contains a resource group return it                
                    policy.resources.resource_group if policy.resources.resource_group != null
                ],
                [
                    # For each policy
                    for policy in group.policies:
                    # if the policy contains a resource group return it                
                    policy.resources.resource if policy.resources.resource_type == "resource_group"
                ]
            ]
        ])
    )
}

##############################################################################


##############################################################################
# Create IAM Access Groups
##############################################################################

resource ibm_iam_access_group groups {
    for_each    = local.access_groups_object
    name        = each.key
    description = each.value.description
}

##############################################################################


##############################################################################
# Resource Groups for IAM Policies
# > Using `toset` allows for the resource groups to be assigned as 
#   `data.ibm_resource_group.resource_group[<RESOURCE_GROUP_NAME>] for easy
#   reference
##############################################################################

data ibm_resource_group resource_group {
    for_each = toset(local.resource_groups)
    name     = each.value   
}

##############################################################################


##############################################################################
# Create Access Group Policies
##############################################################################

resource ibm_iam_access_group_policy policies {
    for_each        = local.access_policies
    access_group_id = ibm_iam_access_group.groups[each.value.group].id
    roles           = each.value.roles
    resources {
        # Resources are made variable so that each policy can be specific without needing to use multiple blocks
        resource_group_id    = each.value.resources.resource_group != null ? data.ibm_resource_group.resource_group[each.value.resources.resource_group].id : null
        resource_type        = each.value.resources.resource_type
        service              = each.value.resources.service
        resource_instance_id = each.value.resources.resource_instance_id
        resource             = each.value.resources.resource_type == "resource-group" ? data.ibm_resource_group.resource_group[each.value.resources.resource].id : each.value.resources.resource
    }
}

##############################################################################


##############################################################################
# Create Account Management Policies (Optional)
# - This is done separately so that the `resource` block in the `policies`
#   resources will continue to work
##############################################################################

resource ibm_iam_access_group_policy account_management_policies {
    for_each           = local.account_management_list
    access_group_id    = ibm_iam_access_group.groups[each.key].id
    account_management = true
    roles              = each.value.roles
}

##############################################################################