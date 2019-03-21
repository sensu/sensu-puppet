# Contribution Guidelines

## Tests

  - Pull requests that add any additional functionality should have tests which cover the new feature to ensure it does what is expected
  - Pull requests with failing tests will not be merged

## Features

  - Keep feature based PRs as small as possible, with as few commits as necessary. These are easier to review and will be merged quicker

## Bug Fixes

  - Make sure you reference the issue you're closing with `Fixes #<issue number>`

## Commits

  - Squash/rebase any commits where possible to reduce the noise in the PR

## Git commits

Reference the issue number, in the format `(GH-###)`.

```
(GH-901) Add support for Sensu v2
```

## Versions

As of v3.0.0, this module supports Sensu V5 aka Sensu Go. Previous
versions supported Sensu Classic which can be found at
[https://github.com/sensu/puppet-module-sensuclassic](https://github.com/sensu/puppet-module-sensuclassic)

## Branches

### master

The `master` branch is for development against Sensu Go v5.

To generate the CHANGELOG.md run the following.


# Release process

1. Update version in `metadata.json`
1. Update CHANGELOG.md with the following command.
```
github_changelog_generator -u sensu -p sensu-puppet --since-tag v3.0.0
```
1. update `CHANGELOG.md` and change `unreleased` at the top to the
   version, such as `v2.0.0`, and change `HEAD` to the same version,
   such as `v2.0.0`.
1. Update `REFERENCE.md` with the command `bundle exec rake reference`
1. Commit changes and push to master
1. Tag the new version, such as `git tag -a 'v2.0.0' -m 'v2.0.0'`
1. Push tags `git push --tags`
1. Update the puppet strings documentation with `bundle exec rake strings:gh_pages:update`
1. Clean up tests with `bundle exec rake spec_clean`
1. Remove junit directory from beaker runs `rm -fr junit`
1. Build module with `puppet module build`
1. Upload module to Puppet Forge.
