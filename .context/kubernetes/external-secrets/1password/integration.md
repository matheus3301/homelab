1Password SDK
1Password Secrets with SDK
1Password released developer SDKs to ease the usage of the secret provider without the need for any external devices. This provides a much better user experience for automated processes without the need of the connect server.

Note: In order to use ESO with 1Password SDK, documents must have unique label names. Meaning, if there is a label that has the same title as another label we won't know which one to update and an error is thrown: found multiple labels with the same key.

Store Configuration
A store is per vault. This is to prevent a single ExternalSecret potentially accessing ALL vaults.

A sample store configuration looks like this:

---
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: 1password-sdk
spec:
  provider:
    onepasswordSDK:
      vault: staging
      auth:
        serviceAccountSecretRef:
          name: onepassword-connect-token-staging
          key: token
      integrationInfo: # this is optional and defaulted
        name: integration-info
        version: v1
GetSecret
Valid secret references should use the following key format: <item>/[section/]<field>.

This is described here: Secret Reference Syntax.

For a one-time password use the following key format: <item>/[section/]one-time password?attribute=otp.

---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: fetch-from-onepassword
spec:
  secretStoreRef:
    kind: SecretStore
    name: onepassword
  target:
    creationPolicy: Owner
  data:
    - secretKey: test-login-1
      remoteRef:
        key: test-login-1/username
PushSecret
Pushing a secret is also supported. For example a push operation with the following secret:

apiVersion: v1
kind: Secret
metadata:
  name: source-secret
stringData:
  source-key: "my-secret"
Looks like this:

---
apiVersion: external-secrets.io/v1alpha1
kind: PushSecret
metadata:
  name: pushsecret-example # Customisable
spec:
  deletionPolicy: Delete
  refreshInterval: 1h0m0s
  secretStoreRefs:
    - name: onepassword
      kind: SecretStore
  selector:
    secret:
      name: source-secret # Source Kubernetes secret
  data:
    - match:
        secretKey: source-key # Source Kubernetes secret key to be pushed
        remoteRef:
          remoteKey: 1pw-secret-name # 1Password item/secret name
          property: password         # (Optional) 1Password field type, default password
      metadata:
        apiVersion: kubernetes.external-secrets.io/v1alpha1
        kind: PushSecretMetadata
        spec:
          tags: ["tag1", "tag2"]    # Optional metadata to be pushed with the secret
Once all fields of a secret are deleted, the entire secret is deleted if the PushSecret object is removed and policy is set to delete.