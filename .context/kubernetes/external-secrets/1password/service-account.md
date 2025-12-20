To create a service account with 1Password CLI:

Make sure you have the latest version of 1Password CLI on your machine.

Create a new service account using the op service-account create command:

op service-account create <serviceAccountName> --expires-in <duration> --vault <vault-name:<permission>,<permission>

Available permissions: read_items, write_items (requires read_items), share_items (requires read_items)

Include the --can-create-vaults flag to allow the service account to create new vaults.

If the service account or vault name contains one or more spaces, enclose the name in quotation marks (for example, “My Service Account”). You don't need to enclose strings in quotation marks if they don't contain spaces (for example, myServerName).

Service accounts can't be modified after they're created. If you need to make changes, revoke the service account and create a new one.

Save the service account token in your 1Password account.

If you want to start using the service account with 1Password CLI, export the token to the OP_SERVICE_ACCOUNT_TOKEN environment variable.

For example, to create a service account named My Service Account that has read and write permissions in a vault named Production, can create new vaults, and expires in 24 hours:

op service-account create "My Service Account" --can-create-vaults --expires-in 24h --vault Production:read_items,write_items

danger
1Password CLI only returns the service account token once. Save the token in 1Password immediately to avoid losing it. Treat this token like a password, and don't store it in plaintext.