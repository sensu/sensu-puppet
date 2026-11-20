# Contribution Guidelines

## Tests

  - PRs that add functionality must include tests for the new feature
  - Pull requests with failing tests will not be merged

## Features

  - Keep feature PRs small with as few commits as necessary — they review and merge faster

## Bug Fixes

  - Make sure you reference the issue you're closing with `Fixes #<issue number>`

## Commits

  - Squash/rebase commits where possible

## Git commits

Reference the issue number, in the format `(GH-###)`.

```
(GH-901) Add support for Sensu v2
```

## Versions

As of v5.0.0, this module supports Sensu Go 6.x. Previous versions supported
Sensu Go 5.x (v3/v4) and Sensu Classic (v1/v2), see
[https://github.com/sensu/puppet-module-sensuclassic](https://github.com/sensu/puppet-module-sensuclassic)

## Branches

### master

The `master` branch is for development against the latest Sensu Go release.

# Release process

1. Update version in `metadata.json`
1. Tag the release: `git tag -a 'v5.13.0' -m 'v5.13.0'` (replace with actual version)
1. Push tags upstream: `git push upstream --tags`
1. GitHub Actions will automatically publish the module to Puppet Forge when a version tag is pushed (see `.github/workflows/release.yaml`)
1. Update GitHub pages: `bundle exec rake strings:gh_pages:update`
