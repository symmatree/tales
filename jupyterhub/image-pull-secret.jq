.fields | map({ key: .label, value: .value }) | from_entries | {
    auths: {
        "ghcr.io": {
            auth: "\(.username):\(.password)" | @base64
        }
    }
}
