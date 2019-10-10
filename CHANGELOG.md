# Change Log

## [v3.9.0](https://github.com/sensu/sensu-puppet/tree/v3.9.0) (2019-10-10)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.8.0...v3.9.0)

**Merged pull requests:**

- Add sensu\_resources type that will handle resource purging [\#1158](https://github.com/sensu/sensu-puppet/pull/1158) ([treydock](https://github.com/treydock))
- Add sensu\_gem package provider [\#1156](https://github.com/sensu/sensu-puppet/pull/1156) ([treydock](https://github.com/treydock))
- Install Windows agent via chocolatey [\#1152](https://github.com/sensu/sensu-puppet/pull/1152) ([treydock](https://github.com/treydock))
- Fix Puppet strings warnings [\#1150](https://github.com/sensu/sensu-puppet/pull/1150) ([treydock](https://github.com/treydock))
- Add sensu\_bonsai\_asset type [\#1149](https://github.com/sensu/sensu-puppet/pull/1149) ([treydock](https://github.com/treydock))
- Fix sensu\_plugin version insync? check [\#1148](https://github.com/sensu/sensu-puppet/pull/1148) ([treydock](https://github.com/treydock))
- Replace unit test instance variables with let [\#1143](https://github.com/sensu/sensu-puppet/pull/1143) ([treydock](https://github.com/treydock))

## [v3.8.0](https://github.com/sensu/sensu-puppet/tree/v3.8.0) (2019-09-02)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.7.0...v3.8.0)

**Merged pull requests:**

- Testing improvements [\#1139](https://github.com/sensu/sensu-puppet/pull/1139) ([treydock](https://github.com/treydock))
- Fix unit tests [\#1138](https://github.com/sensu/sensu-puppet/pull/1138) ([treydock](https://github.com/treydock))
- Support Sensu go 5.12 [\#1137](https://github.com/sensu/sensu-puppet/pull/1137) ([treydock](https://github.com/treydock))
- Support role\_ref property being Hash [\#1133](https://github.com/sensu/sensu-puppet/pull/1133) ([treydock](https://github.com/treydock))

## [v3.7.0](https://github.com/sensu/sensu-puppet/tree/v3.7.0) (2019-08-26)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.6.0...v3.7.0)

**Merged pull requests:**

- Support PostgreSQL datastore [\#1136](https://github.com/sensu/sensu-puppet/pull/1136) ([treydock](https://github.com/treydock))
- Increase upper bound of module dependencies [\#1134](https://github.com/sensu/sensu-puppet/pull/1134) ([treydock](https://github.com/treydock))
- Improved Validations [\#1132](https://github.com/sensu/sensu-puppet/pull/1132) ([treydock](https://github.com/treydock))
- Do not resolve absent sensu\_events [\#1129](https://github.com/sensu/sensu-puppet/pull/1129) ([treydock](https://github.com/treydock))
- Support Debian 10 [\#1128](https://github.com/sensu/sensu-puppet/pull/1128) ([treydock](https://github.com/treydock))

## [v3.6.0](https://github.com/sensu/sensu-puppet/tree/v3.6.0) (2019-08-16)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.5.0...v3.6.0)

**Merged pull requests:**

- Better support for resources in different namespaces [\#1126](https://github.com/sensu/sensu-puppet/pull/1126) ([treydock](https://github.com/treydock))

## [v3.5.0](https://github.com/sensu/sensu-puppet/tree/v3.5.0) (2019-07-22)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.4.1...v3.5.0)

**Merged pull requests:**

- AD Auth updates [\#1124](https://github.com/sensu/sensu-puppet/pull/1124) ([treydock](https://github.com/treydock))

## [v3.4.1](https://github.com/sensu/sensu-puppet/tree/v3.4.1) (2019-07-19)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.4.0...v3.4.1)

**Merged pull requests:**

- Add acceptance tests that use puppetserver [\#1123](https://github.com/sensu/sensu-puppet/pull/1123) ([treydock](https://github.com/treydock))
- Fix to support Puppetserver 5 [\#1122](https://github.com/sensu/sensu-puppet/pull/1122) ([treydock](https://github.com/treydock))

## [v3.4.0](https://github.com/sensu/sensu-puppet/tree/v3.4.0) (2019-07-11)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.3.0...v3.4.0)

**Merged pull requests:**

- Add headers property to sensu\_assets [\#1119](https://github.com/sensu/sensu-puppet/pull/1119) ([treydock](https://github.com/treydock))
- Update several usage examples to match Sensu Go docs [\#1117](https://github.com/sensu/sensu-puppet/pull/1117) ([treydock](https://github.com/treydock))
- Add ability to run acceptance tests against Sensu-Go CI builds [\#1115](https://github.com/sensu/sensu-puppet/pull/1115) ([treydock](https://github.com/treydock))
- Support listing sensuctl resources using chunk-size [\#1114](https://github.com/sensu/sensu-puppet/pull/1114) ([treydock](https://github.com/treydock))
- Regenerate backend test cert to include additional SANs [\#1113](https://github.com/sensu/sensu-puppet/pull/1113) ([treydock](https://github.com/treydock))

## [v3.3.0](https://github.com/sensu/sensu-puppet/tree/v3.3.0) (2019-05-18)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.2.0...v3.3.0)

**Merged pull requests:**

- \(GH-1111\) Remove Ubuntu 14.04 LTS as it is end of life \(EOL\) [\#1112](https://github.com/sensu/sensu-puppet/pull/1112) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix repo path for EL vagrant [\#1110](https://github.com/sensu/sensu-puppet/pull/1110) ([treydock](https://github.com/treydock))
- Fix cluster tests to work with Sensu Go 5.7 [\#1109](https://github.com/sensu/sensu-puppet/pull/1109) ([treydock](https://github.com/treydock))
- Add Windows support for Sensu Go agent [\#1108](https://github.com/sensu/sensu-puppet/pull/1108) ([treydock](https://github.com/treydock))

## [v3.2.0](https://github.com/sensu/sensu-puppet/tree/v3.2.0) (2019-05-06)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.1.0...v3.2.0)

**Merged pull requests:**

- Support Sensu Go 5.6 [\#1105](https://github.com/sensu/sensu-puppet/pull/1105) ([treydock](https://github.com/treydock))

## [v3.1.0](https://github.com/sensu/sensu-puppet/tree/v3.1.0) (2019-04-19)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.0.0...v3.1.0)

**Merged pull requests:**

- Prep 3.1.0 release [\#1103](https://github.com/sensu/sensu-puppet/pull/1103) ([treydock](https://github.com/treydock))
- Support opting out of tessen phone home [\#1101](https://github.com/sensu/sensu-puppet/pull/1101) ([treydock](https://github.com/treydock))
- Do not raise errors if custom puppet facts are undefined [\#1100](https://github.com/sensu/sensu-puppet/pull/1100) ([treydock](https://github.com/treydock))
- Hiera resources [\#1097](https://github.com/sensu/sensu-puppet/pull/1097) ([treydock](https://github.com/treydock))
- Fix Puppet Strings documentation URL [\#1096](https://github.com/sensu/sensu-puppet/pull/1096) ([treydock](https://github.com/treydock))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*