# Changelog

## [v4.11.0](https://github.com/sensu/sensu-puppet/tree/v4.11.0) (2020-06-29)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.10.0...v4.11.0)

### Added

- READ DESCRIPTION: Improved handling of passwords for sensu\_user [\#1251](https://github.com/sensu/sensu-puppet/pull/1251) ([treydock](https://github.com/treydock))
- Add check name to ArgumentError [\#1249](https://github.com/sensu/sensu-puppet/pull/1249) ([amccrea](https://github.com/amccrea))

### Merged Pull Requests

- Fix Windows acceptance tests and update Postgresql dependency range [\#1252](https://github.com/sensu/sensu-puppet/pull/1252) ([treydock](https://github.com/treydock))
- Fix acceptance tests [\#1250](https://github.com/sensu/sensu-puppet/pull/1250) ([treydock](https://github.com/treydock))

## [v4.10.0](https://github.com/sensu/sensu-puppet/tree/v4.10.0) (2020-04-19)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.8.0...v4.10.0)

### Added

- Improved validations around labels and annotations [\#1245](https://github.com/sensu/sensu-puppet/pull/1245) ([treydock](https://github.com/treydock))
- Better support for agent redact [\#1241](https://github.com/sensu/sensu-puppet/pull/1241) ([treydock](https://github.com/treydock))

### Fixed

- Fix sensu\_license error handling [\#1244](https://github.com/sensu/sensu-puppet/pull/1244) ([treydock](https://github.com/treydock))

### Merged Pull Requests

- Change how it's determined when to run specific acceptance tests [\#1243](https://github.com/sensu/sensu-puppet/pull/1243) ([treydock](https://github.com/treydock))
- Attempt to speed up acceptance tests [\#1242](https://github.com/sensu/sensu-puppet/pull/1242) ([treydock](https://github.com/treydock))

## [v4.8.0](https://github.com/sensu/sensu-puppet/tree/v4.8.0) (2020-04-13)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.7.1...v4.8.0)

### Added

- Support defining agent annotations, labels and config entrys via defined type [\#1240](https://github.com/sensu/sensu-puppet/pull/1240) ([treydock](https://github.com/treydock))

## [v4.7.1](https://github.com/sensu/sensu-puppet/tree/v4.7.1) (2020-04-07)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.7.0...v4.7.1)

### Fixed

- Replacing invalid multibyte chars so it is 100% utf-8 [\#1237](https://github.com/sensu/sensu-puppet/pull/1237) ([mvsm](https://github.com/mvsm))

### Merged Pull Requests

- Postgresql examples [\#1238](https://github.com/sensu/sensu-puppet/pull/1238) ([treydock](https://github.com/treydock))
- Fix vagrant [\#1234](https://github.com/sensu/sensu-puppet/pull/1234) ([treydock](https://github.com/treydock))

## [v4.7.0](https://github.com/sensu/sensu-puppet/tree/v4.7.0) (2020-03-21)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.6.0...v4.7.0)

### Added

- Ignore builtin sensu.io/managed\_by label [\#1228](https://github.com/sensu/sensu-puppet/pull/1228) ([treydock](https://github.com/treydock))

### Merged Pull Requests

- Avoid facter 4, breaks unit tests [\#1232](https://github.com/sensu/sensu-puppet/pull/1232) ([treydock](https://github.com/treydock))
- Add example usage for LDAP [\#1231](https://github.com/sensu/sensu-puppet/pull/1231) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix acceptance tests [\#1229](https://github.com/sensu/sensu-puppet/pull/1229) ([treydock](https://github.com/treydock))

## [v4.6.0](https://github.com/sensu/sensu-puppet/tree/v4.6.0) (2020-03-07)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.5.1...v4.6.0)

### Added

- Allow agents to have subscriptions defined as a resource [\#1227](https://github.com/sensu/sensu-puppet/pull/1227) ([treydock](https://github.com/treydock))
- Support bonsai version with v prefix [\#1223](https://github.com/sensu/sensu-puppet/pull/1223) ([treydock](https://github.com/treydock))
- Manage license through sensu\_license type [\#1218](https://github.com/sensu/sensu-puppet/pull/1218) ([treydock](https://github.com/treydock))

### Fixed

- Fix issue where absent HOME would break Dir.home [\#1226](https://github.com/sensu/sensu-puppet/pull/1226) ([treydock](https://github.com/treydock))

### Merged Pull Requests

- Fix to tests to work with Bolt 2 [\#1225](https://github.com/sensu/sensu-puppet/pull/1225) ([treydock](https://github.com/treydock))
- Lint and CI fixes [\#1224](https://github.com/sensu/sensu-puppet/pull/1224) ([treydock](https://github.com/treydock))

## [v4.5.1](https://github.com/sensu/sensu-puppet/tree/v4.5.1) (2020-02-12)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.5.0...v4.5.1)

### Added

- Add more examples [\#1214](https://github.com/sensu/sensu-puppet/pull/1214) ([treydock](https://github.com/treydock))
- Better organization of class variables [\#1213](https://github.com/sensu/sensu-puppet/pull/1213) ([treydock](https://github.com/treydock))
- Better documentation of private types [\#1212](https://github.com/sensu/sensu-puppet/pull/1212) ([treydock](https://github.com/treydock))

### Fixed

- Several fixes for sensu\_bonsai\_asset [\#1215](https://github.com/sensu/sensu-puppet/pull/1215) ([treydock](https://github.com/treydock))

### Merged Pull Requests

- Fix release process [\#1216](https://github.com/sensu/sensu-puppet/pull/1216) ([treydock](https://github.com/treydock))

## [v4.5.0](https://github.com/sensu/sensu-puppet/tree/v4.5.0) (2020-02-08)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.4.1...v4.5.0)

### Added

- Update puppet-strings examples for composite names [\#1211](https://github.com/sensu/sensu-puppet/pull/1211) ([treydock](https://github.com/treydock))
- Support EL8 [\#1208](https://github.com/sensu/sensu-puppet/pull/1208) ([treydock](https://github.com/treydock))

## [v4.4.1](https://github.com/sensu/sensu-puppet/tree/v4.4.1) (2020-02-01)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.4.0...v4.4.1)

### Added

- Changes to support Sensu Go 5.17.1 [\#1207](https://github.com/sensu/sensu-puppet/pull/1207) ([treydock](https://github.com/treydock))

## [v4.4.0](https://github.com/sensu/sensu-puppet/tree/v4.4.0) (2020-01-31)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.3.0...v4.4.0)

### Added

- Add manage\_agent\_user parameter to sensu::backend [\#1206](https://github.com/sensu/sensu-puppet/pull/1206) ([treydock](https://github.com/treydock))

## [v4.3.0](https://github.com/sensu/sensu-puppet/tree/v4.3.0) (2020-01-29)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.2.1...v4.3.0)

### Added

- Support Sensu Go secrets features [\#1203](https://github.com/sensu/sensu-puppet/pull/1203) ([treydock](https://github.com/treydock))
- Better support for Sensu Go upgrades [\#1201](https://github.com/sensu/sensu-puppet/pull/1201) ([treydock](https://github.com/treydock))

## [v4.2.1](https://github.com/sensu/sensu-puppet/tree/v4.2.1) (2020-01-29)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.2.0...v4.2.1)

### Added

- Remove workaround for sensuctl command json formatting [\#1204](https://github.com/sensu/sensu-puppet/pull/1204) ([treydock](https://github.com/treydock))

### Fixed

- Several fixes for sensu\_bonsai\_asset [\#1202](https://github.com/sensu/sensu-puppet/pull/1202) ([treydock](https://github.com/treydock))
- Remove unnecessary auto requirement [\#1200](https://github.com/sensu/sensu-puppet/pull/1200) ([treydock](https://github.com/treydock))

## [v4.2.0](https://github.com/sensu/sensu-puppet/tree/v4.2.0) (2020-01-20)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.1.0...v4.2.0)

### Added

- Add examples for Slack and InfluxDB [\#1199](https://github.com/sensu/sensu-puppet/pull/1199) ([treydock](https://github.com/treydock))
- Allow SSL files to be defined via content parameters [\#1198](https://github.com/sensu/sensu-puppet/pull/1198) ([treydock](https://github.com/treydock))

## [v4.1.0](https://github.com/sensu/sensu-puppet/tree/v4.1.0) (2020-01-15)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v4.0.0...v4.1.0)

### Added

- Add support for sensuctl 'command' subcommand [\#1195](https://github.com/sensu/sensu-puppet/pull/1195) ([treydock](https://github.com/treydock))

## [v4.0.0](https://github.com/sensu/sensu-puppet/tree/v4.0.0) (2020-01-10)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.14.0...v4.0.0)

### Changed

- BREAKING: Add API providers [\#1191](https://github.com/sensu/sensu-puppet/pull/1191) ([treydock](https://github.com/treydock))
- Add several parameters to sensu::agent class [\#1185](https://github.com/sensu/sensu-puppet/pull/1185) ([treydock](https://github.com/treydock))
- Document upcoming breaking changes [\#1167](https://github.com/sensu/sensu-puppet/pull/1167) ([treydock](https://github.com/treydock))
- BREAKING: Move cli resources to sensu::cli class [\#1164](https://github.com/sensu/sensu-puppet/pull/1164) ([treydock](https://github.com/treydock))
- BREAKING: Update type properties to map to Sensu Go specifications [\#1154](https://github.com/sensu/sensu-puppet/pull/1154) ([treydock](https://github.com/treydock))

### Added

- Document contact routing and bonsai asset bugfix [\#1194](https://github.com/sensu/sensu-puppet/pull/1194) ([treydock](https://github.com/treydock))
- Support 'sensu-backend init' added in Sensu Go 5.16 [\#1192](https://github.com/sensu/sensu-puppet/pull/1192) ([treydock](https://github.com/treydock))
- Misc test fixes [\#1189](https://github.com/sensu/sensu-puppet/pull/1189) ([treydock](https://github.com/treydock))

### Merged Pull Requests

- Style [\#1193](https://github.com/sensu/sensu-puppet/pull/1193) ([ghoneycutt](https://github.com/ghoneycutt))
- \(ci\) Update TravisCI configuration for new Slack channel [\#1190](https://github.com/sensu/sensu-puppet/pull/1190) ([ghoneycutt](https://github.com/ghoneycutt))

## [v3.14.0](https://github.com/sensu/sensu-puppet/tree/v3.14.0) (2019-12-01)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.13.0...v3.14.0)

### Added

- Support defining agent and backend service environment variables [\#1160](https://github.com/sensu/sensu-puppet/pull/1160) ([treydock](https://github.com/treydock))

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

## [v3.9.0](https://github.com/sensu/sensu-puppet/tree/v3.9.0) (2019-10-10)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.8.0...v3.9.0)

### Added

- Add sensu\_resources type that will handle resource purging [\#1158](https://github.com/sensu/sensu-puppet/pull/1158) ([treydock](https://github.com/treydock))
- Add sensu\_gem package provider [\#1156](https://github.com/sensu/sensu-puppet/pull/1156) ([treydock](https://github.com/treydock))

## [v3.8.0](https://github.com/sensu/sensu-puppet/tree/v3.8.0) (2019-09-02)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.7.0...v3.8.0)

## [v3.7.0](https://github.com/sensu/sensu-puppet/tree/v3.7.0) (2019-08-26)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.6.0...v3.7.0)

## [v3.6.0](https://github.com/sensu/sensu-puppet/tree/v3.6.0) (2019-08-16)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.5.0...v3.6.0)

## [v3.5.0](https://github.com/sensu/sensu-puppet/tree/v3.5.0) (2019-07-22)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.4.1...v3.5.0)

## [v3.4.1](https://github.com/sensu/sensu-puppet/tree/v3.4.1) (2019-07-19)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.4.0...v3.4.1)

## [v3.4.0](https://github.com/sensu/sensu-puppet/tree/v3.4.0) (2019-07-11)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.3.0...v3.4.0)

## [v3.3.0](https://github.com/sensu/sensu-puppet/tree/v3.3.0) (2019-05-18)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.2.0...v3.3.0)

## [v3.2.0](https://github.com/sensu/sensu-puppet/tree/v3.2.0) (2019-05-06)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.1.0...v3.2.0)

## [v3.1.0](https://github.com/sensu/sensu-puppet/tree/v3.1.0) (2019-04-19)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v3.0.0...v3.1.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
