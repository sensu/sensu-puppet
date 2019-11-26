# Changelog

## [v3.13.0](https://github.com/sensu/sensu-puppet/tree/v3.13.0) (2019-11-26)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.12.0...v3.13.0)

### Added

- Updates to travis-ci [\#1186](https://github.com/sensu/sensu-puppet/pull/1186) ([treydock](https://github.com/treydock))
- Support PDK [\#1184](https://github.com/sensu/sensu-puppet/pull/1184) ([treydock](https://github.com/treydock))
- Update default resources to match Sensu Go defaults [\#1181](https://github.com/sensu/sensu-puppet/pull/1181) ([treydock](https://github.com/treydock))
- Move PostgresConfig to a type [\#1176](https://github.com/sensu/sensu-puppet/pull/1176) ([treydock](https://github.com/treydock))
- Add support for Sensu etcd replicator [\#1175](https://github.com/sensu/sensu-puppet/pull/1175) ([treydock](https://github.com/treydock))

### Fixed

- Only execute future release Rake function when generating changelog or release [\#1179](https://github.com/sensu/sensu-puppet/pull/1179) ([treydock](https://github.com/treydock))

## [v3.12.0](https://github.com/sensu/sensu-puppet/tree/v3.12.0) (2019-11-25)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.11.0...v3.12.0)

### Added

- Improve name validations to match Sensu Go [\#1173](https://github.com/sensu/sensu-puppet/pull/1173) ([treydock](https://github.com/treydock))
- Add bolt task to manage API keys [\#1171](https://github.com/sensu/sensu-puppet/pull/1171) ([treydock](https://github.com/treydock))

### Fixed

- Add lint plugin [\#1177](https://github.com/sensu/sensu-puppet/pull/1177) ([ghoneycutt](https://github.com/ghoneycutt))
- Update steps to release software [\#1172](https://github.com/sensu/sensu-puppet/pull/1172) ([ghoneycutt](https://github.com/ghoneycutt))

## [v3.11.0](https://github.com/sensu/sensu-puppet/tree/v3.11.0) (2019-11-12)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.10.0...v3.11.0)

### Added

- Support Windows 2019 [\#1168](https://github.com/sensu/sensu-puppet/pull/1168) ([treydock](https://github.com/treydock))
- Improve release process [\#1166](https://github.com/sensu/sensu-puppet/pull/1166) ([treydock](https://github.com/treydock))
- \(ci\) Use correct Ruby version 2.5.7 for latest Puppet 6 tests [\#1165](https://github.com/sensu/sensu-puppet/pull/1165) ([ghoneycutt](https://github.com/ghoneycutt))
- Additional bolt tasks [\#1162](https://github.com/sensu/sensu-puppet/pull/1162) ([treydock](https://github.com/treydock))

### Fixed

- Document sensu\_asset deprecations [\#1170](https://github.com/sensu/sensu-puppet/pull/1170) ([treydock](https://github.com/treydock))

## [v3.10.0](https://github.com/sensu/sensu-puppet/tree/v3.10.0) (2019-10-31)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.9.0...v3.10.0)

### Added

- Initial work at design document [\#1161](https://github.com/sensu/sensu-puppet/pull/1161) ([treydock](https://github.com/treydock))
- Add bolt tasks [\#1153](https://github.com/sensu/sensu-puppet/pull/1153) ([treydock](https://github.com/treydock))
- Deprecate defining single asset builds [\#1140](https://github.com/sensu/sensu-puppet/pull/1140) ([treydock](https://github.com/treydock))

## [v3.9.0](https://github.com/sensu/sensu-puppet/tree/v3.9.0) (2019-10-10)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.8.0...v3.9.0)

### Added

- Add sensu\_resources type that will handle resource purging [\#1158](https://github.com/sensu/sensu-puppet/pull/1158) ([treydock](https://github.com/treydock))
- Add sensu\_gem package provider [\#1156](https://github.com/sensu/sensu-puppet/pull/1156) ([treydock](https://github.com/treydock))
- Install Windows agent via chocolatey [\#1152](https://github.com/sensu/sensu-puppet/pull/1152) ([treydock](https://github.com/treydock))
- Add sensu\_bonsai\_asset type [\#1149](https://github.com/sensu/sensu-puppet/pull/1149) ([treydock](https://github.com/treydock))
- Replace unit test instance variables with let [\#1143](https://github.com/sensu/sensu-puppet/pull/1143) ([treydock](https://github.com/treydock))

### Fixed

- Fix Puppet strings warnings [\#1150](https://github.com/sensu/sensu-puppet/pull/1150) ([treydock](https://github.com/treydock))
- Fix sensu\_plugin version insync? check [\#1148](https://github.com/sensu/sensu-puppet/pull/1148) ([treydock](https://github.com/treydock))

## [v3.8.0](https://github.com/sensu/sensu-puppet/tree/v3.8.0) (2019-09-02)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.7.0...v3.8.0)

### Added

- Testing improvements [\#1139](https://github.com/sensu/sensu-puppet/pull/1139) ([treydock](https://github.com/treydock))
- Support Sensu go 5.12 [\#1137](https://github.com/sensu/sensu-puppet/pull/1137) ([treydock](https://github.com/treydock))
- Support role\_ref property being Hash [\#1133](https://github.com/sensu/sensu-puppet/pull/1133) ([treydock](https://github.com/treydock))

### Fixed

- Fix unit tests [\#1138](https://github.com/sensu/sensu-puppet/pull/1138) ([treydock](https://github.com/treydock))

## [v3.7.0](https://github.com/sensu/sensu-puppet/tree/v3.7.0) (2019-08-26)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.6.0...v3.7.0)

### Added

- Support PostgreSQL datastore [\#1136](https://github.com/sensu/sensu-puppet/pull/1136) ([treydock](https://github.com/treydock))
- Increase upper bound of module dependencies [\#1134](https://github.com/sensu/sensu-puppet/pull/1134) ([treydock](https://github.com/treydock))
- Improved Validations [\#1132](https://github.com/sensu/sensu-puppet/pull/1132) ([treydock](https://github.com/treydock))
- Support Debian 10 [\#1128](https://github.com/sensu/sensu-puppet/pull/1128) ([treydock](https://github.com/treydock))

### Fixed

- Do not resolve absent sensu\_events [\#1129](https://github.com/sensu/sensu-puppet/pull/1129) ([treydock](https://github.com/treydock))

## [v3.6.0](https://github.com/sensu/sensu-puppet/tree/v3.6.0) (2019-08-16)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.5.0...v3.6.0)

### Added

- Better support for resources in different namespaces [\#1126](https://github.com/sensu/sensu-puppet/pull/1126) ([treydock](https://github.com/treydock))

## [v3.5.0](https://github.com/sensu/sensu-puppet/tree/v3.5.0) (2019-07-22)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.4.1...v3.5.0)

### Added

- AD Auth updates [\#1124](https://github.com/sensu/sensu-puppet/pull/1124) ([treydock](https://github.com/treydock))

## [v3.4.1](https://github.com/sensu/sensu-puppet/tree/v3.4.1) (2019-07-19)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.4.0...v3.4.1)

### Added

- Add acceptance tests that use puppetserver [\#1123](https://github.com/sensu/sensu-puppet/pull/1123) ([treydock](https://github.com/treydock))

### Fixed

- Fix to support Puppetserver 5 [\#1122](https://github.com/sensu/sensu-puppet/pull/1122) ([treydock](https://github.com/treydock))

## [v3.4.0](https://github.com/sensu/sensu-puppet/tree/v3.4.0) (2019-07-11)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.3.0...v3.4.0)

### Added

- Add headers property to sensu\_assets [\#1119](https://github.com/sensu/sensu-puppet/pull/1119) ([treydock](https://github.com/treydock))
- Add ability to run acceptance tests against Sensu-Go CI builds [\#1115](https://github.com/sensu/sensu-puppet/pull/1115) ([treydock](https://github.com/treydock))
- Support listing sensuctl resources using chunk-size [\#1114](https://github.com/sensu/sensu-puppet/pull/1114) ([treydock](https://github.com/treydock))

### Fixed

- Update several usage examples to match Sensu Go docs [\#1117](https://github.com/sensu/sensu-puppet/pull/1117) ([treydock](https://github.com/treydock))
- Regenerate backend test cert to include additional SANs [\#1113](https://github.com/sensu/sensu-puppet/pull/1113) ([treydock](https://github.com/treydock))

## [v3.3.0](https://github.com/sensu/sensu-puppet/tree/v3.3.0) (2019-05-18)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.2.0...v3.3.0)

### Added

- \(GH-1111\) Remove Ubuntu 14.04 LTS as it is end of life \(EOL\) [\#1112](https://github.com/sensu/sensu-puppet/pull/1112) ([ghoneycutt](https://github.com/ghoneycutt))
- Add Windows support for Sensu Go agent [\#1108](https://github.com/sensu/sensu-puppet/pull/1108) ([treydock](https://github.com/treydock))

### Fixed

- Fix repo path for EL vagrant [\#1110](https://github.com/sensu/sensu-puppet/pull/1110) ([treydock](https://github.com/treydock))
- Fix cluster tests to work with Sensu Go 5.7 [\#1109](https://github.com/sensu/sensu-puppet/pull/1109) ([treydock](https://github.com/treydock))

## [v3.2.0](https://github.com/sensu/sensu-puppet/tree/v3.2.0) (2019-05-06)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.1.0...v3.2.0)

### Added

- Support Sensu Go 5.6 [\#1105](https://github.com/sensu/sensu-puppet/pull/1105) ([treydock](https://github.com/treydock))

## [v3.1.0](https://github.com/sensu/sensu-puppet/tree/v3.1.0) (2019-04-19)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.0.0...v3.1.0)

### Added

- Prep 3.1.0 release [\#1103](https://github.com/sensu/sensu-puppet/pull/1103) ([treydock](https://github.com/treydock))
- Support opting out of tessen phone home [\#1101](https://github.com/sensu/sensu-puppet/pull/1101) ([treydock](https://github.com/treydock))
- Hiera resources [\#1097](https://github.com/sensu/sensu-puppet/pull/1097) ([treydock](https://github.com/treydock))

### Fixed

- Do not raise errors if custom puppet facts are undefined [\#1100](https://github.com/sensu/sensu-puppet/pull/1100) ([treydock](https://github.com/treydock))
- Fix Puppet Strings documentation URL [\#1096](https://github.com/sensu/sensu-puppet/pull/1096) ([treydock](https://github.com/treydock))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
