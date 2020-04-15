# Concourse LastPass Resource

Tracks [LastPass](https://www.lastpass.com/) items.

### Use Cases
* Get notified whenever someone adds or updates an item (e.g. in a shared folder).
* Incremental backups.

## Source Configuration

* `username`: *Required.* LastPass account user name.

* `password`: *Required.* LastPass account master password.

### Example

This pipeline prints each added or updated LastPass item:

``` yaml
---
resource_types:
- name: lpass-type
  type: docker-image
  source:
    repository: ansd/lastpass
    tag: 0.1.0

resources:
- name: lpass-res
  type: lpass-type
  source:
    username: ((username))
    password: ((masterpassword))

jobs:
- name: lpass-job
  plan:
  - get: lpass-res
    trigger: true
    version: every
  - task: print-item
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: alpine}
      inputs:
        - name: lpass-res
      run:
        path: cat
        args: ["lpass-res/item"]
```

## Behavior

### `check`: Check for new and updated items.

All LastPass items are listed, and any items modified after the given version's `last_modified_gmt` timestamp are returned.

The version consists of `<last_modified_gmt>_<id>`.

If no version is given, the latest modified item is returned.

### `in`: Show the item with the given ID.

Writes the JSON representation of the item with the given `id` and `last_modified_gmt` to the file called `item`.

### `out`: No-op.

## Notes

* 2 factor authentication should be disabled (unless you want to manually approve push notifications for every new Concourse LastPass resource container).
* There is a paid plan called "LastPass Identity". With this plan, you can create a separate CI user and assign this user an [IP policy](https://www.lastpass.com/policies/ip-address) that whitelists the public IP addresses of the Concourse workers blocking all other IP addresses by default. This adds security given that 2 factor authentication is disabled.
* If you don't want to pay for "LastPass Identity", make sure to at least restrict logins to the country where the Concourse workers run in `Account Settings` -> `General` -> `Show Advanced Settings` -> `Country Restriction`.
* If the first Concourse containers are failing you should check your inbox for e-mails with the subject `LastPass Verification Email` to verify the new location or device. You can disable e-mail verification in `Account Settings` -> `General` -> `Show Advanced Settings` -> `Disable Email Verification`.

## Development

### Running the tests

```sh
make tests
```
