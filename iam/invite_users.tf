##############################################################################
# Invite Users
##############################################################################

locals {
    access_groups_with_invites = {
        for group in local.access_groups_object:
        group.name => group if group.invite_users != null 
    }
}

resource ibm_iam_user_invite invite {
    for_each = local.access_groups_with_invites
    users    = each.value.invite_users
}

##############################################################################


##############################################################################
# Add users to access group after invite
##############################################################################

resource ibm_iam_access_group_members group_members {
    for_each        = local.access_groups_with_invites
    access_group_id = ibm_iam_access_group.groups[each.key].id
    ibm_ids         = each.value.invite_users
    depends_on = [
        ibm_iam_user_invite.invite
    ]
}

##############################################################################