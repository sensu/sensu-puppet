# Change Log

## [v2.50.0](https://github.com/sensu/sensu-puppet/tree/v2.50.0)

[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.49.0...v2.50.0)

**Closed issues:**

- Pull Request: sensu::check auto\_resolve [\#857](https://github.com/sensu/sensu-puppet/issues/857)
- Enterprise - Purging files no longer managed fails to notify correct service [\#854](https://github.com/sensu/sensu-puppet/issues/854)
- When removing a check, sensu service not refresh [\#782](https://github.com/sensu/sensu-puppet/issues/782)

**Merged pull requests:**

- Adding auto\_resolve param to sensu::check. Replaces \#858 [\#872](https://github.com/sensu/sensu-puppet/pull/872) ([alvagante](https://github.com/alvagante))
- Restart sensu-enterprise service when configs are purged \#854 [\#871](https://github.com/sensu/sensu-puppet/pull/871) ([alvagante](https://github.com/alvagante))

## [v2.49.0](https://github.com/sensu/sensu-puppet/tree/v2.49.0) (2018-01-16)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.48.0...v2.49.0)

**Implemented enhancements:**

- Allow for management of file and directory permissions [\#825](https://github.com/sensu/sensu-puppet/issues/825)

**Merged pull requests:**

- Add parameters to configure dir and file modes [\#869](https://github.com/sensu/sensu-puppet/pull/869) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.48.0](https://github.com/sensu/sensu-puppet/tree/v2.48.0) (2018-01-15)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.47.0...v2.48.0)

**Implemented enhancements:**

- Not all Sensu Enterprise Dashboard options are available [\#866](https://github.com/sensu/sensu-puppet/issues/866)
- Add support for Debian 9 stretch [\#708](https://github.com/sensu/sensu-puppet/issues/708)

**Merged pull requests:**

- \[866\] Add Sensu Enterprise Dashboard auth and oidc configuration options [\#867](https://github.com/sensu/sensu-puppet/pull/867) ([treydock](https://github.com/treydock))

## [v2.47.0](https://github.com/sensu/sensu-puppet/tree/v2.47.0) (2018-01-15)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.46.0...v2.47.0)

**Implemented enhancements:**

- \(GH-708\) Add support for Debian 9 \(Stretch\) [\#795](https://github.com/sensu/sensu-puppet/pull/795) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.46.0](https://github.com/sensu/sensu-puppet/tree/v2.46.0) (2018-01-15)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.45.0...v2.46.0)

**Closed issues:**

- upgrading to newer version of sensu with newer embeded ruby doesn't reinstall plugins [\#542](https://github.com/sensu/sensu-puppet/issues/542)

**Merged pull requests:**

- \[542\] Add dependencies for sensu\_gem plugins [\#817](https://github.com/sensu/sensu-puppet/pull/817) ([glarizza](https://github.com/glarizza))

## [v2.45.0](https://github.com/sensu/sensu-puppet/tree/v2.45.0) (2018-01-09)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.44.0...v2.45.0)

**Closed issues:**

- Support MacOS client [\#862](https://github.com/sensu/sensu-puppet/issues/862)

**Merged pull requests:**

- Macos [\#863](https://github.com/sensu/sensu-puppet/pull/863) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.44.0](https://github.com/sensu/sensu-puppet/tree/v2.44.0) (2018-01-04)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.43.0...v2.44.0)

**Merged pull requests:**

- Use latest puppetlabs/stdlib \(2.24.0\) and Stdlib::Filemode type [\#865](https://github.com/sensu/sensu-puppet/pull/865) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.43.0](https://github.com/sensu/sensu-puppet/tree/v2.43.0) (2018-01-04)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.42.0...v2.43.0)

**Implemented enhancements:**

- MAX\_OPEN\_FILES should be configurable for Sensu Enterprise [\#849](https://github.com/sensu/sensu-puppet/issues/849)

**Fixed bugs:**

- Roundrobin subscriptions on Windows aren't configured [\#820](https://github.com/sensu/sensu-puppet/issues/820)

**Closed issues:**

- check "type" field lost in json file while upgrading module [\#860](https://github.com/sensu/sensu-puppet/issues/860)
- Sensu puppet doesn't work correctly if started from crontab: "Package\[sensu-plugin\] has failures" [\#859](https://github.com/sensu/sensu-puppet/issues/859)
- test slack integration. [\#856](https://github.com/sensu/sensu-puppet/issues/856)
- Centos 7 - not properly managing sensu-client service [\#855](https://github.com/sensu/sensu-puppet/issues/855)
- CONFIG\_FILE environment variable should be configurable [\#851](https://github.com/sensu/sensu-puppet/issues/851)

**Merged pull requests:**

- Support only the latest releases of Puppet versions 4 and 5 [\#864](https://github.com/sensu/sensu-puppet/pull/864) ([ghoneycutt](https://github.com/ghoneycutt))
- Added config\_file params to CONFIG\_FILE envvar \#851 [\#861](https://github.com/sensu/sensu-puppet/pull/861) ([alvagante](https://github.com/alvagante))
- Fix \#820 [\#846](https://github.com/sensu/sensu-puppet/pull/846) ([alvagante](https://github.com/alvagante))

## [v2.42.0](https://github.com/sensu/sensu-puppet/tree/v2.42.0) (2017-12-04)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.41.0...v2.42.0)

**Closed issues:**

- switch from puppetlabs/rabbitmq to puppet/rabbitmq [\#844](https://github.com/sensu/sensu-puppet/issues/844)

**Merged pull requests:**

- Added support for MAX\_OPEN\_FILES environment variable \#849 [\#850](https://github.com/sensu/sensu-puppet/pull/850) ([alvagante](https://github.com/alvagante))

## [v2.41.0](https://github.com/sensu/sensu-puppet/tree/v2.41.0) (2017-11-27)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.40.1...v2.41.0)

**Merged pull requests:**

- Second attempt for \#844  [\#848](https://github.com/sensu/sensu-puppet/pull/848) ([alvagante](https://github.com/alvagante))
- Revert "Merge pull request \#845 from alvagante/844" [\#847](https://github.com/sensu/sensu-puppet/pull/847) ([ghoneycutt](https://github.com/ghoneycutt))
- Renamed references to puppetlabs to voxpupuli rabbitmq \#844 [\#845](https://github.com/sensu/sensu-puppet/pull/845) ([alvagante](https://github.com/alvagante))

## [v2.40.1](https://github.com/sensu/sensu-puppet/tree/v2.40.1) (2017-11-17)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.40.0...v2.40.1)

**Merged pull requests:**

- \(security\) Update rest-client older version have a vulnerability [\#843](https://github.com/sensu/sensu-puppet/pull/843) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.40.0](https://github.com/sensu/sensu-puppet/tree/v2.40.0) (2017-11-08)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.39.0...v2.40.0)

**Closed issues:**

- Transport class does not use platform specific user and group [\#838](https://github.com/sensu/sensu-puppet/issues/838)

**Merged pull requests:**

- \(GH-840\) Change default mode value for creation of json files [\#841](https://github.com/sensu/sensu-puppet/pull/841) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.39.0](https://github.com/sensu/sensu-puppet/tree/v2.39.0) (2017-11-07)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.38.1...v2.39.0)

**Closed issues:**

- Implement hooks [\#836](https://github.com/sensu/sensu-puppet/issues/836)

**Merged pull requests:**

- Added hooks support \#836 [\#837](https://github.com/sensu/sensu-puppet/pull/837) ([alvagante](https://github.com/alvagante))

## [v2.38.1](https://github.com/sensu/sensu-puppet/tree/v2.38.1) (2017-11-02)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.38.0...v2.38.1)

**Fixed bugs:**

- redact parameter causes errors [\#834](https://github.com/sensu/sensu-puppet/issues/834)

**Merged pull requests:**

- Set a defauly empty array for redact \#834 [\#835](https://github.com/sensu/sensu-puppet/pull/835) ([alvagante](https://github.com/alvagante))

## [v2.38.0](https://github.com/sensu/sensu-puppet/tree/v2.38.0) (2017-10-26)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.37.0...v2.38.0)

**Implemented enhancements:**

- sensu module failing on amazon linux as it is pointing to a incorrect yum repo http url which doesn't exist [\#821](https://github.com/sensu/sensu-puppet/issues/821)

**Fixed bugs:**

- sensu module failing on amazon linux as it is pointing to a incorrect yum repo http url which doesn't exist [\#821](https://github.com/sensu/sensu-puppet/issues/821)

**Closed issues:**

- Sensu Enterprise Service Not Reloading After Checks [\#827](https://github.com/sensu/sensu-puppet/issues/827)
- Cyclical dependencies when using Sensu Enterprise and the Enterprise API [\#815](https://github.com/sensu/sensu-puppet/issues/815)

**Merged pull requests:**

- Manage sensu on amazon Linux \#821 [\#833](https://github.com/sensu/sensu-puppet/pull/833) ([alvagante](https://github.com/alvagante))

## [v2.37.0](https://github.com/sensu/sensu-puppet/tree/v2.37.0) (2017-10-23)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.36.0...v2.37.0)

**Fixed bugs:**

- transport.json not created when transport\_type = rabbitmq [\#809](https://github.com/sensu/sensu-puppet/issues/809)

**Closed issues:**

- Add client register and registration client configs [\#749](https://github.com/sensu/sensu-puppet/issues/749)

**Merged pull requests:**

- Fix for \#809 [\#832](https://github.com/sensu/sensu-puppet/pull/832) ([alvagante](https://github.com/alvagante))
- Added client\_registration option \#749 [\#831](https://github.com/sensu/sensu-puppet/pull/831) ([alvagante](https://github.com/alvagante))

## [v2.36.0](https://github.com/sensu/sensu-puppet/tree/v2.36.0) (2017-10-20)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.35.0...v2.36.0)

**Closed issues:**

- Absolute path set for rabbitmq ssl certs [\#798](https://github.com/sensu/sensu-puppet/issues/798)
- Client config should support servicenow [\#775](https://github.com/sensu/sensu-puppet/issues/775)
- Client config should support puppet [\#774](https://github.com/sensu/sensu-puppet/issues/774)
- Client config should support chef [\#773](https://github.com/sensu/sensu-puppet/issues/773)
- Cannot manage 2008 R2 localised \(french\) [\#769](https://github.com/sensu/sensu-puppet/issues/769)
- Add a test in vagrant for PR \#745 [\#747](https://github.com/sensu/sensu-puppet/issues/747)

**Merged pull requests:**

- Change test versions [\#830](https://github.com/sensu/sensu-puppet/pull/830) ([ghoneycutt](https://github.com/ghoneycutt))
- user on check for windows to use module defaults and notifying sensu-enterprise [\#829](https://github.com/sensu/sensu-puppet/pull/829) ([ghoneycutt](https://github.com/ghoneycutt))
- \[815\] Resolve circular dependency when using sensu::enterprise::dashboard::api [\#816](https://github.com/sensu/sensu-puppet/pull/816) ([glarizza](https://github.com/glarizza))
- Add vagrant tests for add/remove checks with sensu::check [\#814](https://github.com/sensu/sensu-puppet/pull/814) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Added sensu\_user and sensu\_group params to sensu class \#769 [\#813](https://github.com/sensu/sensu-puppet/pull/813) ([alvagante](https://github.com/alvagante))

## [v2.35.0](https://github.com/sensu/sensu-puppet/tree/v2.35.0) (2017-09-06)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.34.0...v2.35.0)

**Closed issues:**

- Client config should support ec2 [\#772](https://github.com/sensu/sensu-puppet/issues/772)

**Merged pull requests:**

- Use variable for ssl\_dir in sensu::rabbitmq::config \#798 [\#808](https://github.com/sensu/sensu-puppet/pull/808) ([alvagante](https://github.com/alvagante))
- Added support to client config for servicenow, ec2, chef, puppet \#772 \#773 \#774 \#775 [\#807](https://github.com/sensu/sensu-puppet/pull/807) ([alvagante](https://github.com/alvagante))

## [v2.34.0](https://github.com/sensu/sensu-puppet/tree/v2.34.0) (2017-08-31)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.33.1...v2.34.0)

**Closed issues:**

- Client config should support http\_socket [\#776](https://github.com/sensu/sensu-puppet/issues/776)
- Refactor inline documentation to puppet strings \(yard\) format [\#757](https://github.com/sensu/sensu-puppet/issues/757)
- Stop using private classes and the anchor pattern [\#709](https://github.com/sensu/sensu-puppet/issues/709)
- redacting passwords from catalogue output [\#515](https://github.com/sensu/sensu-puppet/issues/515)

**Merged pull requests:**

- Added http\_socket param to client config \#776 [\#805](https://github.com/sensu/sensu-puppet/pull/805) ([alvagante](https://github.com/alvagante))

## [v2.33.1](https://github.com/sensu/sensu-puppet/tree/v2.33.1) (2017-08-28)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.33.0...v2.33.1)

**Closed issues:**

- Checks not working as expected [\#801](https://github.com/sensu/sensu-puppet/issues/801)

**Merged pull requests:**

- Force array for some sense::check params \#801 [\#804](https://github.com/sensu/sensu-puppet/pull/804) ([alvagante](https://github.com/alvagante))
- Update the README to clarify support resources [\#802](https://github.com/sensu/sensu-puppet/pull/802) ([obfuscurity](https://github.com/obfuscurity))
- \#709 Remove anchors \(and create\_resources\) [\#763](https://github.com/sensu/sensu-puppet/pull/763) ([alvagante](https://github.com/alvagante))

## [v2.33.0](https://github.com/sensu/sensu-puppet/tree/v2.33.0) (2017-08-23)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.32.0...v2.33.0)

**Closed issues:**

- Default linux path not working on Windows with $has\_cluster [\#790](https://github.com/sensu/sensu-puppet/issues/790)

**Merged pull requests:**

- Quick fix for \#790 [\#800](https://github.com/sensu/sensu-puppet/pull/800) ([alvagante](https://github.com/alvagante))
- Support puppet 5.1 [\#799](https://github.com/sensu/sensu-puppet/pull/799) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.32.0](https://github.com/sensu/sensu-puppet/tree/v2.32.0) (2017-08-18)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.31.0...v2.32.0)

**Implemented enhancements:**

- Modify sensu::check to use defined type sensu::write\_json instead of native type sensu\_check [\#783](https://github.com/sensu/sensu-puppet/issues/783)

**Closed issues:**

- Vagrant uses an older version of rabbitmq [\#760](https://github.com/sensu/sensu-puppet/issues/760)
- Add github templates [\#566](https://github.com/sensu/sensu-puppet/issues/566)

**Merged pull requests:**

- \(GH-566\) Add pull request template [\#797](https://github.com/sensu/sensu-puppet/pull/797) ([ghoneycutt](https://github.com/ghoneycutt))
- \(GH-566\) Add Code of Conduct [\#796](https://github.com/sensu/sensu-puppet/pull/796) ([ghoneycutt](https://github.com/ghoneycutt))
- \(GH-760\) Document rabbitmq's move to Voxpupuli [\#794](https://github.com/sensu/sensu-puppet/pull/794) ([ghoneycutt](https://github.com/ghoneycutt))
- \(\#783\) Add sensu::check content parameter, use sensu::write\_json [\#785](https://github.com/sensu/sensu-puppet/pull/785) ([jeffmccune](https://github.com/jeffmccune))

## [v2.31.0](https://github.com/sensu/sensu-puppet/tree/v2.31.0) (2017-08-14)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.30.1...v2.31.0)

**Closed issues:**

- Remove apt module from metadata [\#791](https://github.com/sensu/sensu-puppet/issues/791)
- minimum apt version wall [\#788](https://github.com/sensu/sensu-puppet/issues/788)
- sensu::plugin does not work on windows without specifying install\_path [\#786](https://github.com/sensu/sensu-puppet/issues/786)

**Merged pull requests:**

- Remove soft dependencies on apt and powershell [\#793](https://github.com/sensu/sensu-puppet/pull/793) ([ghoneycutt](https://github.com/ghoneycutt))
- Puppet strings 4 all \#757 [\#792](https://github.com/sensu/sensu-puppet/pull/792) ([alvagante](https://github.com/alvagante))
- \(GH-786\) sensu::plugin does not work on windows without specifying install\_path [\#789](https://github.com/sensu/sensu-puppet/pull/789) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.30.1](https://github.com/sensu/sensu-puppet/tree/v2.30.1) (2017-07-31)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.30.0...v2.30.1)

**Fixed bugs:**

- Sensu Enterprise API SSL attributes are incorrectly configured [\#784](https://github.com/sensu/sensu-puppet/issues/784)

**Closed issues:**

- Auto generated documentation should show up as a GitHub page [\#777](https://github.com/sensu/sensu-puppet/issues/777)

**Merged pull requests:**

- \(\#784\) Fix Sensu Enterprise API SSL configuration scope [\#787](https://github.com/sensu/sensu-puppet/pull/787) ([jeffmccune](https://github.com/jeffmccune))
- Update link to auto generated docs [\#778](https://github.com/sensu/sensu-puppet/pull/778) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.30.0](https://github.com/sensu/sensu-puppet/tree/v2.30.0) (2017-07-26)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.29.0...v2.30.0)

**Closed issues:**

- Sensu Enterprise HEAP\_SIZE is not configurable [\#767](https://github.com/sensu/sensu-puppet/issues/767)
- Stop using scope.lookupvar\(\) in templates [\#701](https://github.com/sensu/sensu-puppet/issues/701)
- Pass gem\_install\_options to sensu::plugin class [\#599](https://github.com/sensu/sensu-puppet/issues/599)
- etc\_dir should be configurable [\#578](https://github.com/sensu/sensu-puppet/issues/578)

**Merged pull requests:**

- Added heap\_size param \#767 [\#771](https://github.com/sensu/sensu-puppet/pull/771) ([alvagante](https://github.com/alvagante))

## [v2.29.0](https://github.com/sensu/sensu-puppet/tree/v2.29.0) (2017-07-26)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.28.0...v2.29.0)

**Closed issues:**

- to\_type helper's handling of numbers is too loose [\#582](https://github.com/sensu/sensu-puppet/issues/582)

**Merged pull requests:**

- Add confd\_dir parameter [\#758](https://github.com/sensu/sensu-puppet/pull/758) ([bodgit](https://github.com/bodgit))

## [v2.28.0](https://github.com/sensu/sensu-puppet/tree/v2.28.0) (2017-07-25)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.27.0...v2.28.0)

**Implemented enhancements:**

- Create a reference implementation for provider spec tests [\#759](https://github.com/sensu/sensu-puppet/issues/759)

**Closed issues:**

- Allow remediation on check.pp [\#560](https://github.com/sensu/sensu-puppet/issues/560)

**Merged pull requests:**

- Add validation of spec/fixtures/unit/\*\*/\*.json [\#768](https://github.com/sensu/sensu-puppet/pull/768) ([ghoneycutt](https://github.com/ghoneycutt))
- WIP 582  Don't do type convertion on keys of sensu\_client\_config custom param [\#766](https://github.com/sensu/sensu-puppet/pull/766) ([alvagante](https://github.com/alvagante))
- \(\#759\) Add reference spec tests for sensu\_check JSON provider [\#765](https://github.com/sensu/sensu-puppet/pull/765) ([jeffmccune](https://github.com/jeffmccune))
- Add handle\_silenced parameter to handler defined type [\#753](https://github.com/sensu/sensu-puppet/pull/753) ([madAndroid](https://github.com/madAndroid))
- \(GH-578\) etc\_dir should be configurable [\#741](https://github.com/sensu/sensu-puppet/pull/741) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.27.0](https://github.com/sensu/sensu-puppet/tree/v2.27.0) (2017-07-19)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.26.0...v2.27.0)

**Implemented enhancements:**

- Add `rake doc` task to generate documentation from inline comments [\#748](https://github.com/sensu/sensu-puppet/issues/748)
- Add support for deregister client config and deregistration handler [\#550](https://github.com/sensu/sensu-puppet/issues/550)

**Closed issues:**

- plugins should install before checks [\#463](https://github.com/sensu/sensu-puppet/issues/463)

**Merged pull requests:**

- \(\#748\) Add puppet-strings gem and dependencies [\#756](https://github.com/sensu/sensu-puppet/pull/756) ([jeffmccune](https://github.com/jeffmccune))
- \(\#463\) Ensure sensu::plugins are managed before checks [\#755](https://github.com/sensu/sensu-puppet/pull/755) ([jeffmccune](https://github.com/jeffmccune))
- \(\#550\) Add sensu client de-registration [\#750](https://github.com/sensu/sensu-puppet/pull/750) ([jeffmccune](https://github.com/jeffmccune))

## [v2.26.0](https://github.com/sensu/sensu-puppet/tree/v2.26.0) (2017-07-19)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.25.0...v2.26.0)

**Closed issues:**

- Investigate getting sensu\_gem working on windows [\#700](https://github.com/sensu/sensu-puppet/issues/700)
- Use Puppet v4's data types [\#682](https://github.com/sensu/sensu-puppet/issues/682)

**Merged pull requests:**

- Data types [\#761](https://github.com/sensu/sensu-puppet/pull/761) ([ghoneycutt](https://github.com/ghoneycutt))
- \(PR-751\) working with csoleimani [\#752](https://github.com/sensu/sensu-puppet/pull/752) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.25.0](https://github.com/sensu/sensu-puppet/tree/v2.25.0) (2017-07-14)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.24.0...v2.25.0)

**Merged pull requests:**

- \(PR-528\) working with kali-hernandez [\#745](https://github.com/sensu/sensu-puppet/pull/745) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.24.0](https://github.com/sensu/sensu-puppet/tree/v2.24.0) (2017-07-13)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.23.0...v2.24.0)

**Closed issues:**

- support for setting spawn limit via puppet [\#727](https://github.com/sensu/sensu-puppet/issues/727)
- Using rabbitmq\_cluster works only the first time puppet runs [\#598](https://github.com/sensu/sensu-puppet/issues/598)

**Merged pull requests:**

- \(\#727\) Add sensu::spawn\_limit class parameter [\#744](https://github.com/sensu/sensu-puppet/pull/744) ([jeffmccune](https://github.com/jeffmccune))
- \(\#598\) Improve rabbitmq clustering robustness [\#742](https://github.com/sensu/sensu-puppet/pull/742) ([jeffmccune](https://github.com/jeffmccune))

## [v2.23.0](https://github.com/sensu/sensu-puppet/tree/v2.23.0) (2017-07-13)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.22.0...v2.23.0)

**Closed issues:**

- sensu::check resources should support cron scheduling [\#737](https://github.com/sensu/sensu-puppet/issues/737)
- use puppet code instead of ruby code in template [\#731](https://github.com/sensu/sensu-puppet/issues/731)

**Merged pull requests:**

- \(\#737\) Add cron attribute to sensu::check type [\#743](https://github.com/sensu/sensu-puppet/pull/743) ([jeffmccune](https://github.com/jeffmccune))

## [v2.22.0](https://github.com/sensu/sensu-puppet/tree/v2.22.0) (2017-07-13)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.21.0...v2.22.0)

**Closed issues:**

- Vagrant ports for sensu-enterprise-server are off [\#735](https://github.com/sensu/sensu-puppet/issues/735)

**Merged pull requests:**

- \(GH-599\) Pass gem\_install\_options to sensu::plugin class [\#740](https://github.com/sensu/sensu-puppet/pull/740) ([Phil-Friderici](https://github.com/Phil-Friderici))
- \(GH-560\) Add docs for $sensu::check::custom [\#739](https://github.com/sensu/sensu-puppet/pull/739) ([Phil-Friderici](https://github.com/Phil-Friderici))
- \(\#735\) Fix sensu-server-enterprise Vagrant VM [\#738](https://github.com/sensu/sensu-puppet/pull/738) ([jeffmccune](https://github.com/jeffmccune))
- \(GH-701\) Stop using scope.lookupvar\(\) in templates [\#724](https://github.com/sensu/sensu-puppet/pull/724) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.21.0](https://github.com/sensu/sensu-puppet/tree/v2.21.0) (2017-07-12)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.20.1...v2.21.0)

**Closed issues:**

- improvement: proxy\_requests for sensu::check [\#637](https://github.com/sensu/sensu-puppet/issues/637)

**Merged pull requests:**

- \(\#637\) Add check proxy\_requests functionality [\#736](https://github.com/sensu/sensu-puppet/pull/736) ([jeffmccune](https://github.com/jeffmccune))

## [v2.20.1](https://github.com/sensu/sensu-puppet/tree/v2.20.1) (2017-07-11)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.20.0...v2.20.1)

**Closed issues:**

- don't use templates for static files [\#732](https://github.com/sensu/sensu-puppet/issues/732)
- new subscribe check does not restart sensu-api service [\#600](https://github.com/sensu/sensu-puppet/issues/600)

**Merged pull requests:**

- \(\#600\) Reload Sensu API when check configurations change [\#734](https://github.com/sensu/sensu-puppet/pull/734) ([jeffmccune](https://github.com/jeffmccune))
- \(\#562\) Sensu\_filter resources notify Sensu Server and Sensu Enterprise [\#733](https://github.com/sensu/sensu-puppet/pull/733) ([jeffmccune](https://github.com/jeffmccune))

## [v2.20.0](https://github.com/sensu/sensu-puppet/tree/v2.20.0) (2017-07-11)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.19.2...v2.20.0)

**Implemented enhancements:**

- Unable to define Contact Routing for Sensu Enterprise [\#597](https://github.com/sensu/sensu-puppet/issues/597)

**Merged pull requests:**

- \(\#597\) Add sensu::contact type \(Enterprise Only\) [\#728](https://github.com/sensu/sensu-puppet/pull/728) ([jeffmccune](https://github.com/jeffmccune))

## [v2.19.2](https://github.com/sensu/sensu-puppet/tree/v2.19.2) (2017-07-11)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.19.1...v2.19.2)

**Closed issues:**

- Switch to using Hiera data in the module instead of accessing variables in another scope [\#678](https://github.com/sensu/sensu-puppet/issues/678)
- sensu-api service should subscribe to sensu::rabbitmq::config class [\#433](https://github.com/sensu/sensu-puppet/issues/433)

**Merged pull requests:**

- \(\#433\) Reload Service\[sensu\_api\] on RabbitMQ config changes [\#730](https://github.com/sensu/sensu-puppet/pull/730) ([jeffmccune](https://github.com/jeffmccune))

## [v2.19.1](https://github.com/sensu/sensu-puppet/tree/v2.19.1) (2017-07-10)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.19.0...v2.19.1)

**Closed issues:**

- $check\_notify does not load sensu::enterprise::service [\#495](https://github.com/sensu/sensu-puppet/issues/495)

**Merged pull requests:**

- \(GH-388\) Simplify class notifications [\#725](https://github.com/sensu/sensu-puppet/pull/725) ([ghoneycutt](https://github.com/ghoneycutt))
- \(\#495\) Notify Service\[sensu-enterprise\] from Sensu::Check resources [\#720](https://github.com/sensu/sensu-puppet/pull/720) ([jeffmccune](https://github.com/jeffmccune))

## [v2.19.0](https://github.com/sensu/sensu-puppet/tree/v2.19.0) (2017-07-09)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.18.0...v2.19.0)

**Closed issues:**

- rabbitmq\_reconnect\_on\_error parameter is useless [\#717](https://github.com/sensu/sensu-puppet/issues/717)
- Windows - attempts to create a local 'sensu' user [\#617](https://github.com/sensu/sensu-puppet/issues/617)

**Merged pull requests:**

- \(\#717\) Remove rabbitmq\_reconnect\_on\_error [\#722](https://github.com/sensu/sensu-puppet/pull/722) ([jeffmccune](https://github.com/jeffmccune))

## [v2.18.0](https://github.com/sensu/sensu-puppet/tree/v2.18.0) (2017-07-08)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.17.0...v2.18.0)

**Closed issues:**

- REQ - Windows - Support chocolatey as a package manager [\#589](https://github.com/sensu/sensu-puppet/issues/589)

**Merged pull requests:**

- \(\#589\) Add Chocolatey support for Windows [\#723](https://github.com/sensu/sensu-puppet/pull/723) ([jeffmccune](https://github.com/jeffmccune))

## [v2.17.0](https://github.com/sensu/sensu-puppet/tree/v2.17.0) (2017-07-08)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.16.0...v2.17.0)

**Implemented enhancements:**

- Unable to set RabbitMQ Heartbeat option [\#428](https://github.com/sensu/sensu-puppet/issues/428)

**Closed issues:**

- Module does not support the when attribute on filters [\#658](https://github.com/sensu/sensu-puppet/issues/658)

**Merged pull requests:**

- \(\#658\) Manage the when attribute of sensu filters [\#721](https://github.com/sensu/sensu-puppet/pull/721) ([jeffmccune](https://github.com/jeffmccune))

## [v2.16.0](https://github.com/sensu/sensu-puppet/tree/v2.16.0) (2017-07-07)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.15.0...v2.16.0)

**Implemented enhancements:**

- implement an `instances` method for the sensu\_enterprise\_dashboard\_api\_config `json` provider [\#649](https://github.com/sensu/sensu-puppet/issues/649)

**Merged pull requests:**

- \(\#649\) Enumerate sensu\_enterprise\_dashboard\_config instances [\#716](https://github.com/sensu/sensu-puppet/pull/716) ([jeffmccune](https://github.com/jeffmccune))

## [v2.15.0](https://github.com/sensu/sensu-puppet/tree/v2.15.0) (2017-07-07)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.14.0...v2.15.0)

**Closed issues:**

- unable to load facts into a newly installed puppet agent server from puppet master [\#719](https://github.com/sensu/sensu-puppet/issues/719)

**Merged pull requests:**

- Working on PR557 [\#718](https://github.com/sensu/sensu-puppet/pull/718) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.14.0](https://github.com/sensu/sensu-puppet/tree/v2.14.0) (2017-07-06)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.13.0...v2.14.0)

**Closed issues:**

- Add support for Puppet 5 [\#713](https://github.com/sensu/sensu-puppet/issues/713)
- sensu\_enterprise\_dashboard\_api type should use `host` as namevar, not `name` [\#638](https://github.com/sensu/sensu-puppet/issues/638)
- Unable to add ssl and insecure Sensu attributes to API section of dashboard.json [\#584](https://github.com/sensu/sensu-puppet/issues/584)

**Merged pull requests:**

- \(\#638\) Enable multiple Sensu Enterprise Dashboard API endpoints [\#715](https://github.com/sensu/sensu-puppet/pull/715) ([jeffmccune](https://github.com/jeffmccune))

## [v2.13.0](https://github.com/sensu/sensu-puppet/tree/v2.13.0) (2017-07-06)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.12.0...v2.13.0)

**Merged pull requests:**

- \(GH-713\) Support Puppet 5 [\#714](https://github.com/sensu/sensu-puppet/pull/714) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.12.0](https://github.com/sensu/sensu-puppet/tree/v2.12.0) (2017-07-06)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.11.0...v2.12.0)

**Closed issues:**

- Add ability to specify a different release for apt::source [\#711](https://github.com/sensu/sensu-puppet/issues/711)
- Add support for Debian 7 and 8 [\#710](https://github.com/sensu/sensu-puppet/issues/710)

**Merged pull requests:**

- \(GH-710\) support debian 7 and 8 [\#712](https://github.com/sensu/sensu-puppet/pull/712) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.11.0](https://github.com/sensu/sensu-puppet/tree/v2.11.0) (2017-07-06)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.10.0...v2.11.0)

**Closed issues:**

- module should support SSL configuration for API endpoints [\#648](https://github.com/sensu/sensu-puppet/issues/648)

**Merged pull requests:**

- Working on PR501 [\#703](https://github.com/sensu/sensu-puppet/pull/703) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.10.0](https://github.com/sensu/sensu-puppet/tree/v2.10.0) (2017-07-05)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.9.0...v2.10.0)

**Closed issues:**

- Ubuntu16.04 uses the wrong ipaddress [\#695](https://github.com/sensu/sensu-puppet/issues/695)
- redis\_reconnect\_on\_error should default to true [\#685](https://github.com/sensu/sensu-puppet/issues/685)
- Windows - sensu-client.log does not rotate [\#618](https://github.com/sensu/sensu-puppet/issues/618)

**Merged pull requests:**

- \(GH-685\) redis\_reconnect\_on\_error now defaults to true [\#707](https://github.com/sensu/sensu-puppet/pull/707) ([ghoneycutt](https://github.com/ghoneycutt))
- \(GH-695\) Use internal interface in Vagrant testing [\#706](https://github.com/sensu/sensu-puppet/pull/706) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.9.0](https://github.com/sensu/sensu-puppet/tree/v2.9.0) (2017-07-04)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.8.0...v2.9.0)

**Closed issues:**

- Change repos to use HTTPS by default [\#697](https://github.com/sensu/sensu-puppet/issues/697)
- Windows Install [\#626](https://github.com/sensu/sensu-puppet/issues/626)
- HTTPS Apt repo [\#583](https://github.com/sensu/sensu-puppet/issues/583)

**Merged pull requests:**

- \(GH-648\) Add ability to specify SSL options to API config for Enterpr… [\#705](https://github.com/sensu/sensu-puppet/pull/705) ([ghoneycutt](https://github.com/ghoneycutt))
- Use rspec-puppet 2.5.x until 2.6.x is fixed [\#702](https://github.com/sensu/sensu-puppet/pull/702) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.8.0](https://github.com/sensu/sensu-puppet/tree/v2.8.0) (2017-06-30)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.7.0...v2.8.0)

**Closed issues:**

- Vagrant should have clients for other platforms [\#681](https://github.com/sensu/sensu-puppet/issues/681)
- Error installing Sensu on Windows Server 2012R2 [\#646](https://github.com/sensu/sensu-puppet/issues/646)

**Merged pull requests:**

- Fix Package\[sensu\] on windows [\#699](https://github.com/sensu/sensu-puppet/pull/699) ([jeffmccune](https://github.com/jeffmccune))
- \(GH-697\) Use https with public package repositories [\#698](https://github.com/sensu/sensu-puppet/pull/698) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.7.0](https://github.com/sensu/sensu-puppet/tree/v2.7.0) (2017-06-28)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.6.0...v2.7.0)

**Closed issues:**

- the sensu-plugin gem is incorrectly installed with the system ruby instead of the embedded ruby [\#688](https://github.com/sensu/sensu-puppet/issues/688)

**Merged pull requests:**

- \(GH-644\) Use the new apt and yum repositories [\#696](https://github.com/sensu/sensu-puppet/pull/696) ([ghoneycutt](https://github.com/ghoneycutt))
- \(GH-688\) Default sensu-plugin gem to use sensu\_gem provider [\#694](https://github.com/sensu/sensu-puppet/pull/694) ([jeffmccune](https://github.com/jeffmccune))

## [v2.6.0](https://github.com/sensu/sensu-puppet/tree/v2.6.0) (2017-06-28)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.5.0...v2.6.0)

**Closed issues:**

- Drop support for Windows 2008 and 2012 \(non R2\) [\#691](https://github.com/sensu/sensu-puppet/issues/691)
- Drop support for EOL platform ubuntu 12.04 [\#690](https://github.com/sensu/sensu-puppet/issues/690)

**Merged pull requests:**

- EOL platforms [\#693](https://github.com/sensu/sensu-puppet/pull/693) ([ghoneycutt](https://github.com/ghoneycutt))
- Add support for Ubuntu 16.04 LTS [\#692](https://github.com/sensu/sensu-puppet/pull/692) ([ghoneycutt](https://github.com/ghoneycutt))
- \(GH-681\) Add EL6 platform as a client to Vagrant [\#689](https://github.com/sensu/sensu-puppet/pull/689) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.5.0](https://github.com/sensu/sensu-puppet/tree/v2.5.0) (2017-06-27)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.4.0...v2.5.0)

**Closed issues:**

- Ensure file validation tests are being done [\#680](https://github.com/sensu/sensu-puppet/issues/680)
- Use a newer puppetlabs\_spec\_helper that includes syntax validation [\#679](https://github.com/sensu/sensu-puppet/issues/679)
- Implement support for arbitrary top-level configuration hashes [\#661](https://github.com/sensu/sensu-puppet/issues/661)
- Unable to define handler specific config properly [\#647](https://github.com/sensu/sensu-puppet/issues/647)
- Getting 'cluster' error from module and then after updating getting 'heartbeat' error [\#634](https://github.com/sensu/sensu-puppet/issues/634)
- Update repository URLs and release new module version [\#606](https://github.com/sensu/sensu-puppet/issues/606)

**Merged pull requests:**

- \(GH-680\) Add file validation checks for Vagrantfile and shell scripts \(\*.sh\) [\#687](https://github.com/sensu/sensu-puppet/pull/687) ([ghoneycutt](https://github.com/ghoneycutt))
- \(GH-679\) Upgrade puppetlabs\_spec\_helper and puppet-lint [\#686](https://github.com/sensu/sensu-puppet/pull/686) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.4.0](https://github.com/sensu/sensu-puppet/tree/v2.4.0) (2017-06-27)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.3.1...v2.4.0)

**Closed issues:**

- Vagrant environment does not work [\#676](https://github.com/sensu/sensu-puppet/issues/676)

**Merged pull requests:**

- Migrate vagrant to CentOS 7 and Puppet v4 [\#677](https://github.com/sensu/sensu-puppet/pull/677) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.3.1](https://github.com/sensu/sensu-puppet/tree/v2.3.1) (2017-06-27)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.3.0...v2.3.1)

**Closed issues:**

- sensu::write\_json requires that owner and group be specified [\#683](https://github.com/sensu/sensu-puppet/issues/683)
- Heads up about new contributors [\#673](https://github.com/sensu/sensu-puppet/issues/673)

**Merged pull requests:**

- \(GH-683\) Fix having to specify owner/group for sensu::write\_json [\#684](https://github.com/sensu/sensu-puppet/pull/684) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.3.0](https://github.com/sensu/sensu-puppet/tree/v2.3.0) (2017-06-21)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.2.1...v2.3.0)

**Closed issues:**

- Fix package suffix spec test [\#670](https://github.com/sensu/sensu-puppet/issues/670)
- all sort of integrations [\#666](https://github.com/sensu/sensu-puppet/issues/666)
- test [\#665](https://github.com/sensu/sensu-puppet/issues/665)
- Could not find init script or upstart conf file for 'sensu-enterprise' [\#662](https://github.com/sensu/sensu-puppet/issues/662)
- Error: no parameter named 'heartbeat' at \[...\]/modules/sensu/manifests/rabbitmq/config.pp:126 [\#659](https://github.com/sensu/sensu-puppet/issues/659)

**Merged pull requests:**

- Release v2.3.0 [\#675](https://github.com/sensu/sensu-puppet/pull/675) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix \#670 - Package release string for EL platform [\#674](https://github.com/sensu/sensu-puppet/pull/674) ([ghoneycutt](https://github.com/ghoneycutt))
- Update readme example for write\_json [\#672](https://github.com/sensu/sensu-puppet/pull/672) ([robbyt](https://github.com/robbyt))
- Add ability to write arbitrary JSON to a file [\#671](https://github.com/sensu/sensu-puppet/pull/671) ([ghoneycutt](https://github.com/ghoneycutt))
- Standardize files to ignore [\#669](https://github.com/sensu/sensu-puppet/pull/669) ([ghoneycutt](https://github.com/ghoneycutt))
- TravisCI to explicitly test supported versions of Puppet [\#668](https://github.com/sensu/sensu-puppet/pull/668) ([ghoneycutt](https://github.com/ghoneycutt))
- fix apt errors by adding os facts to debian and ubuntu examples [\#663](https://github.com/sensu/sensu-puppet/pull/663) ([cwjohnston](https://github.com/cwjohnston))
- Avoid running sensu enterprise service in opensource installation [\#660](https://github.com/sensu/sensu-puppet/pull/660) ([devcfgc](https://github.com/devcfgc))
- redhat version fix [\#615](https://github.com/sensu/sensu-puppet/pull/615) ([andyroyle](https://github.com/andyroyle))

## [v2.2.1](https://github.com/sensu/sensu-puppet/tree/v2.2.1) (2017-05-30)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.2.0...v2.2.1)

**Implemented enhancements:**

- Drop support for old versions of Puppet and Ruby in next major version? [\#577](https://github.com/sensu/sensu-puppet/issues/577)

**Fixed bugs:**

- sensu::check unable to remove a check property [\#535](https://github.com/sensu/sensu-puppet/issues/535)

**Closed issues:**

- All of the json files \(client, api, etc.\) in /etc/sensu/conf.d remain empty [\#657](https://github.com/sensu/sensu-puppet/issues/657)
- RHEL 7 - Sensu Enterprise service is not being managed correctly [\#655](https://github.com/sensu/sensu-puppet/issues/655)
- Sensu packages cannot be authenticated [\#654](https://github.com/sensu/sensu-puppet/issues/654)
- Version parameter fails to work with new package naming [\#641](https://github.com/sensu/sensu-puppet/issues/641)
- sensu-0.28.5-2.msi checksum mismatch [\#630](https://github.com/sensu/sensu-puppet/issues/630)
- Provider sensu\_gem is not functional on this host [\#629](https://github.com/sensu/sensu-puppet/issues/629)
- Add Enterprise contact routing management [\#624](https://github.com/sensu/sensu-puppet/issues/624)
- Does not install latest version [\#622](https://github.com/sensu/sensu-puppet/issues/622)
- sense::handler creates deprecated "Filters" entry in resulting yaml [\#620](https://github.com/sensu/sensu-puppet/issues/620)
- Windows: Provider sensu\_gem is not functional on this host [\#607](https://github.com/sensu/sensu-puppet/issues/607)
- Source parameter not purged when removed from check [\#601](https://github.com/sensu/sensu-puppet/issues/601)
- Windows: Fails to create sensu user [\#586](https://github.com/sensu/sensu-puppet/issues/586)
- Doesn't create a transport.json file [\#556](https://github.com/sensu/sensu-puppet/issues/556)

**Merged pull requests:**

- Fix service inconsistencies in enterprise classes [\#656](https://github.com/sensu/sensu-puppet/pull/656) ([dzeleski](https://github.com/dzeleski))
- Remove Puppet 3.8 from unit tests, update minimum Puppet version in metadata [\#650](https://github.com/sensu/sensu-puppet/pull/650) ([cwjohnston](https://github.com/cwjohnston))
- Update version string validation to allow for redhat platform suffix [\#645](https://github.com/sensu/sensu-puppet/pull/645) ([cwjohnston](https://github.com/cwjohnston))
- Bump puppetlabs/apt dependency [\#643](https://github.com/sensu/sensu-puppet/pull/643) ([aquister](https://github.com/aquister))
- Fix some lint issues and test spec warnings [\#640](https://github.com/sensu/sensu-puppet/pull/640) ([cryptk](https://github.com/cryptk))
- support for redis as a transport [\#639](https://github.com/sensu/sensu-puppet/pull/639) ([RiRa12621](https://github.com/RiRa12621))
- Updating sensu\_gem provider to check for RUBY\_PLATFORM [\#632](https://github.com/sensu/sensu-puppet/pull/632) ([cdenneen](https://github.com/cdenneen))
- Added windows\_repo\_prefix to allow for internal mirrors [\#631](https://github.com/sensu/sensu-puppet/pull/631) ([cdenneen](https://github.com/cdenneen))
- Disable user creation on osfamily = windows by default [\#628](https://github.com/sensu/sensu-puppet/pull/628) ([cdenneen](https://github.com/cdenneen))
- Add handle\_flapping option to sensu::handler [\#627](https://github.com/sensu/sensu-puppet/pull/627) ([johanek](https://github.com/johanek))
- Added package\_checksum [\#625](https://github.com/sensu/sensu-puppet/pull/625) ([cdenneen](https://github.com/cdenneen))
- Add fix to resolve rabbitmq cluster heartbeat config failure. [\#623](https://github.com/sensu/sensu-puppet/pull/623) ([dzeleski](https://github.com/dzeleski))
- Add support to rotate windows logs [\#621](https://github.com/sensu/sensu-puppet/pull/621) ([dzeleski](https://github.com/dzeleski))
- use gem.cmd instead of gem.bat [\#616](https://github.com/sensu/sensu-puppet/pull/616) ([andyroyle](https://github.com/andyroyle))
- Support `ensure` property on sensu::enterprise::dashboard::api [\#613](https://github.com/sensu/sensu-puppet/pull/613) ([cwjohnston](https://github.com/cwjohnston))
- Select debian/ubuntu release for apt repo [\#611](https://github.com/sensu/sensu-puppet/pull/611) ([johanek](https://github.com/johanek))
- update repository urls yum [\#610](https://github.com/sensu/sensu-puppet/pull/610) ([goodwolf](https://github.com/goodwolf))
- Drop support for Ruby 1.9 [\#605](https://github.com/sensu/sensu-puppet/pull/605) ([ghoneycutt](https://github.com/ghoneycutt))
- set the log-level in the windows client xml config [\#604](https://github.com/sensu/sensu-puppet/pull/604) ([andyroyle](https://github.com/andyroyle))
- Sort properties in sensu\_check provider [\#603](https://github.com/sensu/sensu-puppet/pull/603) ([ttarczynski](https://github.com/ttarczynski))
- Remove sensu check property with absent [\#602](https://github.com/sensu/sensu-puppet/pull/602) ([ttarczynski](https://github.com/ttarczynski))
- sensu-puppet-add heartbeat feature [\#596](https://github.com/sensu/sensu-puppet/pull/596) ([derkgort](https://github.com/derkgort))
- Fix for enabling strict\_variables [\#593](https://github.com/sensu/sensu-puppet/pull/593) ([madAndroid](https://github.com/madAndroid))
- sensu\_check provider: fix missed value [\#592](https://github.com/sensu/sensu-puppet/pull/592) ([pjfbashton](https://github.com/pjfbashton))
- Add contributing.md [\#591](https://github.com/sensu/sensu-puppet/pull/591) ([jaxxstorm](https://github.com/jaxxstorm))
- Update travis [\#590](https://github.com/sensu/sensu-puppet/pull/590) ([jaxxstorm](https://github.com/jaxxstorm))
- Initital fix for sensu on windows [\#588](https://github.com/sensu/sensu-puppet/pull/588) ([dzeleski](https://github.com/dzeleski))
- Use default redact [\#580](https://github.com/sensu/sensu-puppet/pull/580) ([paramite](https://github.com/paramite))
- transorm input with munge in type rather than in sensu\_check/json.rb provider [\#573](https://github.com/sensu/sensu-puppet/pull/573) ([ttarczynski](https://github.com/ttarczynski))
- add timeout support for handlers [\#547](https://github.com/sensu/sensu-puppet/pull/547) ([lobeck](https://github.com/lobeck))

## [v2.2.0](https://github.com/sensu/sensu-puppet/tree/v2.2.0) (2016-11-27)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.1.0...v2.2.0)

**Fixed bugs:**

- Windows: Invalid Relationship [\#569](https://github.com/sensu/sensu-puppet/issues/569)
- Tests still failing [\#533](https://github.com/sensu/sensu-puppet/issues/533)

**Closed issues:**

- Update README.md with compatibility [\#568](https://github.com/sensu/sensu-puppet/issues/568)
- does sensu-puppet work well in updating to 0.26  [\#561](https://github.com/sensu/sensu-puppet/issues/561)
- $::sensu::purge\['config'\] causes file path error on Windows agents [\#558](https://github.com/sensu/sensu-puppet/issues/558)
- Update subdue for 0.26 [\#553](https://github.com/sensu/sensu-puppet/issues/553)
- Add support for aggregates array [\#549](https://github.com/sensu/sensu-puppet/issues/549)
- subdue should be optional for sensu check definition [\#548](https://github.com/sensu/sensu-puppet/issues/548)
- Update Puppet Forge releases [\#545](https://github.com/sensu/sensu-puppet/issues/545)
- error while installing ruby\_dep,  Bundler cannot continue [\#540](https://github.com/sensu/sensu-puppet/issues/540)
- rake: uninitialized constant Syck with ruby 2.3.1 [\#539](https://github.com/sensu/sensu-puppet/issues/539)
- Add some new maintainers [\#522](https://github.com/sensu/sensu-puppet/issues/522)
- Using sensu\_gem provider before sensu::client is installed? [\#520](https://github.com/sensu/sensu-puppet/issues/520)
- yum repository [\#519](https://github.com/sensu/sensu-puppet/issues/519)
- sentinel supports in sensu redis.json [\#514](https://github.com/sensu/sensu-puppet/issues/514)
- enable support for change in aggregates [\#512](https://github.com/sensu/sensu-puppet/issues/512)
- Travis builds failing even on no code change [\#511](https://github.com/sensu/sensu-puppet/issues/511)
- Sensu puppet module causes invalid parameter prefetch on some runs of puppet [\#507](https://github.com/sensu/sensu-puppet/issues/507)
- Sensu plugin install fails when using URLs [\#506](https://github.com/sensu/sensu-puppet/issues/506)
- Sensu puppet module causes invalid parameter prefetch on some runs of puppet [\#504](https://github.com/sensu/sensu-puppet/issues/504)
- Cannot create /etc/sensu/conf.d/redis.json without "password" [\#503](https://github.com/sensu/sensu-puppet/issues/503)
- Add support for Redis Sentinels Config [\#499](https://github.com/sensu/sensu-puppet/issues/499)
- Check subdue modified every run [\#497](https://github.com/sensu/sensu-puppet/issues/497)
- Trailing comma issue in config [\#492](https://github.com/sensu/sensu-puppet/issues/492)
- Sensu Windows: sensu\_rabbitmq\_config type needs base\_path param passed [\#489](https://github.com/sensu/sensu-puppet/issues/489)
- Wrong default value of rabbitmq\_vhost [\#473](https://github.com/sensu/sensu-puppet/issues/473)
- Release new version "Tag the repo" [\#472](https://github.com/sensu/sensu-puppet/issues/472)
- support for new deregistration options [\#470](https://github.com/sensu/sensu-puppet/issues/470)
- 'gem list --remote' does not respect proxy settings [\#460](https://github.com/sensu/sensu-puppet/issues/460)
- Question about overriding check command [\#459](https://github.com/sensu/sensu-puppet/issues/459)
- `gem --list` hangs - need a way to set a timeout [\#452](https://github.com/sensu/sensu-puppet/issues/452)
- Sensu-client service enable is not idempotent on CentOS 7 [\#448](https://github.com/sensu/sensu-puppet/issues/448)
- Differentiate between sensu-plugin gem and the sensu-plugins [\#432](https://github.com/sensu/sensu-puppet/issues/432)
- Changing Handler type fails with 'keys' error [\#360](https://github.com/sensu/sensu-puppet/issues/360)
- Support for multiple broker connection options with RabbitMQ [\#269](https://github.com/sensu/sensu-puppet/issues/269)
- Add functionality to configure mutators [\#230](https://github.com/sensu/sensu-puppet/issues/230)

**Merged pull requests:**

- Module bump [\#587](https://github.com/sensu/sensu-puppet/pull/587) ([jaxxstorm](https://github.com/jaxxstorm))
- Add support for multi-host Rabbitmq config [\#581](https://github.com/sensu/sensu-puppet/pull/581) ([dhgwilliam](https://github.com/dhgwilliam))
- fix tests on Ruby 1.8 [\#579](https://github.com/sensu/sensu-puppet/pull/579) ([ttarczynski](https://github.com/ttarczynski))
- pin semantic\_puppet gem at \< 0.1.4 on Ruby 1.8 or earlier [\#576](https://github.com/sensu/sensu-puppet/pull/576) ([cwjohnston](https://github.com/cwjohnston))
- Small puppet-lint fix [\#575](https://github.com/sensu/sensu-puppet/pull/575) ([ttarczynski](https://github.com/ttarczynski))
- use constant SENSU\_CHECK\_PROPERTIES instead of hardcoded check\_args in sensu\_check provider [\#572](https://github.com/sensu/sensu-puppet/pull/572) ([ttarczynski](https://github.com/ttarczynski))
- Add sensu compatibility info in README.md [\#571](https://github.com/sensu/sensu-puppet/pull/571) ([ttarczynski](https://github.com/ttarczynski))
- \[enterprise dashboard\] move package resource inside conditional [\#570](https://github.com/sensu/sensu-puppet/pull/570) ([cwjohnston](https://github.com/cwjohnston))
- Add an issue template [\#567](https://github.com/sensu/sensu-puppet/pull/567) ([jaxxstorm](https://github.com/jaxxstorm))
- remove subdue property with 'absent' [\#565](https://github.com/sensu/sensu-puppet/pull/565) ([ttarczynski](https://github.com/ttarczynski))
- Tests for subdue 2.0 [\#564](https://github.com/sensu/sensu-puppet/pull/564) ([ttarczynski](https://github.com/ttarczynski))
- Remove subdue from handler [\#563](https://github.com/sensu/sensu-puppet/pull/563) ([ttarczynski](https://github.com/ttarczynski))
- Add support for new aggregates type in 0.26 [\#554](https://github.com/sensu/sensu-puppet/pull/554) ([jaxxstorm](https://github.com/jaxxstorm))
- Add ruby 2.2 tests [\#552](https://github.com/sensu/sensu-puppet/pull/552) ([jaxxstorm](https://github.com/jaxxstorm))
- Fixes for Windows clients with Enterprise [\#544](https://github.com/sensu/sensu-puppet/pull/544) ([jacobmw](https://github.com/jacobmw))
- small fixes in docs [\#543](https://github.com/sensu/sensu-puppet/pull/543) ([ttarczynski](https://github.com/ttarczynski))
- Fixing tests [\#538](https://github.com/sensu/sensu-puppet/pull/538) ([jaxxstorm](https://github.com/jaxxstorm))
- validate subdue is a hash [\#536](https://github.com/sensu/sensu-puppet/pull/536) ([fessyfoo](https://github.com/fessyfoo))
- Allow undef handlers and subscribers [\#531](https://github.com/sensu/sensu-puppet/pull/531) ([thejandroman](https://github.com/thejandroman))
- Pin the package provider for RedHat osfamily [\#530](https://github.com/sensu/sensu-puppet/pull/530) ([thejandroman](https://github.com/thejandroman))
- Pin listen to a working pre-ruby2.2 version [\#529](https://github.com/sensu/sensu-puppet/pull/529) ([thejandroman](https://github.com/thejandroman))
- Better explain diff between diff sensu-plugin [\#526](https://github.com/sensu/sensu-puppet/pull/526) ([jaxxstorm](https://github.com/jaxxstorm))
- Switch default vhost to /sensu [\#525](https://github.com/sensu/sensu-puppet/pull/525) ([jaxxstorm](https://github.com/jaxxstorm))
- Add support for stringified aggregates [\#524](https://github.com/sensu/sensu-puppet/pull/524) ([jaxxstorm](https://github.com/jaxxstorm))
- Add support for client deregistration [\#523](https://github.com/sensu/sensu-puppet/pull/523) ([jaxxstorm](https://github.com/jaxxstorm))
- Fix tests [\#517](https://github.com/sensu/sensu-puppet/pull/517) ([jaxxstorm](https://github.com/jaxxstorm))
- small puppet-lint fixes [\#513](https://github.com/sensu/sensu-puppet/pull/513) ([ttarczynski](https://github.com/ttarczynski))
- Small fix in docs [\#510](https://github.com/sensu/sensu-puppet/pull/510) ([ttarczynski](https://github.com/ttarczynski))
- Support redis sentinels and add master property [\#509](https://github.com/sensu/sensu-puppet/pull/509) ([modax](https://github.com/modax))
- fix issue \#497 [\#498](https://github.com/sensu/sensu-puppet/pull/498) ([bovy89](https://github.com/bovy89))
- Use 127.0.0.1 instead of localhost for hosts, it could resolve to ::1 [\#494](https://github.com/sensu/sensu-puppet/pull/494) ([portertech](https://github.com/portertech))
- Updated config.pp to add base\_path [\#490](https://github.com/sensu/sensu-puppet/pull/490) ([r0b0tAnthony](https://github.com/r0b0tAnthony))
- Install rake \< 11.0.0 for ruby \< 1.9.3 [\#487](https://github.com/sensu/sensu-puppet/pull/487) ([atrepca](https://github.com/atrepca))
- add source to remote\_file for urls in plugin.pp [\#486](https://github.com/sensu/sensu-puppet/pull/486) ([chrissav](https://github.com/chrissav))

## [v2.1.0](https://github.com/sensu/sensu-puppet/tree/v2.1.0) (2016-02-29)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v2.0.0...v2.1.0)

**Closed issues:**

- Error no parameter named socket in sensu\_client\_config [\#474](https://github.com/sensu/sensu-puppet/issues/474)
- Repuppet fails [\#469](https://github.com/sensu/sensu-puppet/issues/469)
- Could not start service - plugin file permissions [\#465](https://github.com/sensu/sensu-puppet/issues/465)
- redis.json removed on purge { config =\> true } [\#461](https://github.com/sensu/sensu-puppet/issues/461)
- Please put a Github Tag/Release on v2.0.0 commit [\#455](https://github.com/sensu/sensu-puppet/issues/455)
- should sensu:;plugin support purge for gems ? [\#450](https://github.com/sensu/sensu-puppet/issues/450)
- Error: Could not convert change 'socket' to string: undefined method `keys' for nil:NilClass [\#447](https://github.com/sensu/sensu-puppet/issues/447)
- Authentication issue when attempting to install sensu package [\#444](https://github.com/sensu/sensu-puppet/issues/444)
- Could not autoload puppet/type/sensu\_filter: uninitialized constant PuppetX::Sensu::ToType [\#441](https://github.com/sensu/sensu-puppet/issues/441)
- Add option not to manage handlers dir [\#430](https://github.com/sensu/sensu-puppet/issues/430)
- manage\_plugins\_dir doesn't seem to do anything [\#429](https://github.com/sensu/sensu-puppet/issues/429)
- Please, push new version to forge with updated apt dependencies [\#413](https://github.com/sensu/sensu-puppet/issues/413)
- What version of puppet are you running? [\#404](https://github.com/sensu/sensu-puppet/issues/404)
- Client.json integers are saved as double quoted strings on first run [\#399](https://github.com/sensu/sensu-puppet/issues/399)

**Merged pull requests:**

- version bump: 2.1.0 [\#483](https://github.com/sensu/sensu-puppet/pull/483) ([jlambert121](https://github.com/jlambert121))
- add support for configuring sensu-enterprise-dashboard audit logging [\#482](https://github.com/sensu/sensu-puppet/pull/482) ([cwjohnston](https://github.com/cwjohnston))
- add support for configuring sensu-enterprise-dashboard gitlab auth [\#481](https://github.com/sensu/sensu-puppet/pull/481) ([cwjohnston](https://github.com/cwjohnston))
- add support for configuring sensu-enterprise-dashboard ssl listener [\#480](https://github.com/sensu/sensu-puppet/pull/480) ([cwjohnston](https://github.com/cwjohnston))
- Feature prefetch attribute [\#479](https://github.com/sensu/sensu-puppet/pull/479) ([chrissav](https://github.com/chrissav))
- Add filters and filter\_defaults to init with create\_resources, missing puppetdoc [\#478](https://github.com/sensu/sensu-puppet/pull/478) ([dmsimard](https://github.com/dmsimard))
- Add tests when using checks parameter in init [\#477](https://github.com/sensu/sensu-puppet/pull/477) ([dmsimard](https://github.com/dmsimard))
- Added parameter sensu::install\_repo as the first condition to manage … [\#475](https://github.com/sensu/sensu-puppet/pull/475) ([mrodm](https://github.com/mrodm))
- Add support for using the same source for  different sensu handlers [\#471](https://github.com/sensu/sensu-puppet/pull/471) ([salimane](https://github.com/salimane))
- add defaults for create\_resources\(\) [\#468](https://github.com/sensu/sensu-puppet/pull/468) ([EslamElHusseiny](https://github.com/EslamElHusseiny))
- add create\_resources\(\) for mutators the same way for handlers, checks [\#467](https://github.com/sensu/sensu-puppet/pull/467) ([EslamElHusseiny](https://github.com/EslamElHusseiny))
- Redaction support [\#466](https://github.com/sensu/sensu-puppet/pull/466) ([jaxxstorm](https://github.com/jaxxstorm))
- support purging with enterprise version [\#462](https://github.com/sensu/sensu-puppet/pull/462) ([jcochard](https://github.com/jcochard))
- fix issue \#399 [\#458](https://github.com/sensu/sensu-puppet/pull/458) ([bovy89](https://github.com/bovy89))
- Fixing regression bug. [\#457](https://github.com/sensu/sensu-puppet/pull/457) ([zbintliff](https://github.com/zbintliff))
- sensu fails to start as client\_port is a string. [\#456](https://github.com/sensu/sensu-puppet/pull/456) ([sathlan](https://github.com/sathlan))
- Enterprise dashboard config password [\#449](https://github.com/sensu/sensu-puppet/pull/449) ([agarstang](https://github.com/agarstang))
- Updating links in README.md to point to the right branch [\#446](https://github.com/sensu/sensu-puppet/pull/446) ([jlk](https://github.com/jlk))
- Ensure "apt-get update" runs after adding apt source [\#445](https://github.com/sensu/sensu-puppet/pull/445) ([jlk](https://github.com/jlk))
- update client config to use socket hash [\#443](https://github.com/sensu/sensu-puppet/pull/443) ([gsalisbury](https://github.com/gsalisbury))
- Add ruby-dev to be installed whilst provisioning process. [\#442](https://github.com/sensu/sensu-puppet/pull/442) ([zylad](https://github.com/zylad))
- Added subdue attribute to sensu\_check type [\#440](https://github.com/sensu/sensu-puppet/pull/440) ([liamjbennett](https://github.com/liamjbennett))
- Adding option to manage the mutators dir [\#439](https://github.com/sensu/sensu-puppet/pull/439) ([gsalisbury](https://github.com/gsalisbury))
- Adding windows support. [\#438](https://github.com/sensu/sensu-puppet/pull/438) ([liamjbennett](https://github.com/liamjbennett))
- update supported puppet versions [\#437](https://github.com/sensu/sensu-puppet/pull/437) ([jlambert121](https://github.com/jlambert121))
- add ttl to check provider [\#436](https://github.com/sensu/sensu-puppet/pull/436) ([gsalisbury](https://github.com/gsalisbury))
- Add functionality to configure mutators \#230 [\#435](https://github.com/sensu/sensu-puppet/pull/435) ([gsalisbury](https://github.com/gsalisbury))
- Update package repository URLs [\#434](https://github.com/sensu/sensu-puppet/pull/434) ([portertech](https://github.com/portertech))
- Adding option to manage the handlers dir [\#431](https://github.com/sensu/sensu-puppet/pull/431) ([jaxxstorm](https://github.com/jaxxstorm))
- strict\_variables bugfix for redhat ::osfamily [\#427](https://github.com/sensu/sensu-puppet/pull/427) ([smithtrevor](https://github.com/smithtrevor))
- version bump: 2.0.0 [\#426](https://github.com/sensu/sensu-puppet/pull/426) ([jlambert121](https://github.com/jlambert121))

## [v2.0.0](https://github.com/sensu/sensu-puppet/tree/v2.0.0) (2015-09-24)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.5.5...v2.0.0)

**Closed issues:**

- Setting handlers to undef for a checks does not trigger change in respective json config file. [\#414](https://github.com/sensu/sensu-puppet/issues/414)
- Pull request \#407 breaks the show for me. [\#412](https://github.com/sensu/sensu-puppet/issues/412)
- Master requires apt module \>= 2.0, not 1.8 [\#411](https://github.com/sensu/sensu-puppet/issues/411)
- How to keep the sensu-plugin gem installed ? [\#410](https://github.com/sensu/sensu-puppet/issues/410)
- Undefined variable "file\_ensure" in sensu::handler [\#406](https://github.com/sensu/sensu-puppet/issues/406)
- json providers can not "unset" properties [\#394](https://github.com/sensu/sensu-puppet/issues/394)
- sensu-api not restarted when check definitions change [\#392](https://github.com/sensu/sensu-puppet/issues/392)
- issue with "Do not use 'handle' and 'handlers' together. Your 'handle' value has been overridden with 'handlers'" [\#391](https://github.com/sensu/sensu-puppet/issues/391)
- How to make sensu::plugins do an array merge in hiera  [\#387](https://github.com/sensu/sensu-puppet/issues/387)
- plugins directory permissions inconsistent  [\#385](https://github.com/sensu/sensu-puppet/issues/385)
- Invalid package provider 'sensu\_gem' [\#383](https://github.com/sensu/sensu-puppet/issues/383)
- Create resources not doing deep merging in hiera  [\#382](https://github.com/sensu/sensu-puppet/issues/382)
- sensu::checks failing when subscribers are specified [\#381](https://github.com/sensu/sensu-puppet/issues/381)
- need updates to support subdue and possibly other new config sections [\#380](https://github.com/sensu/sensu-puppet/issues/380)
- Error trying to apply a filter [\#375](https://github.com/sensu/sensu-puppet/issues/375)
- Filters throwing failed: 'undefined method `sort' for nil:NilClass' error [\#374](https://github.com/sensu/sensu-puppet/issues/374)
- getting Notice: Do not use 'handle' and 'handlers' together. Your 'handle' value has been overridden with 'handlers' [\#371](https://github.com/sensu/sensu-puppet/issues/371)
- Invalid parameter reconnect\_on\_error [\#369](https://github.com/sensu/sensu-puppet/issues/369)
- allow merging of hiera configs instead of only taking lowest in hierarchy [\#366](https://github.com/sensu/sensu-puppet/issues/366)
- Sensu\_redis\_config changes on every run [\#357](https://github.com/sensu/sensu-puppet/issues/357)
- Creating checks with hiera [\#354](https://github.com/sensu/sensu-puppet/issues/354)
- First run on a new client node fails checks which depend on plugins [\#353](https://github.com/sensu/sensu-puppet/issues/353)
- Client\_custom overrides client\_port [\#342](https://github.com/sensu/sensu-puppet/issues/342)
- sensu\_gem provider proxy support [\#339](https://github.com/sensu/sensu-puppet/issues/339)
- sensu::client::config keepalives 'change' every run [\#336](https://github.com/sensu/sensu-puppet/issues/336)
- operatingsystemmajrelease is lsbmajdistrelease in puppet 3 [\#330](https://github.com/sensu/sensu-puppet/issues/330)
- Unable to purge handlers, extensions, or mutators [\#328](https://github.com/sensu/sensu-puppet/issues/328)
- Unable to install sensu without rubygems  [\#322](https://github.com/sensu/sensu-puppet/issues/322)
- windows support [\#317](https://github.com/sensu/sensu-puppet/issues/317)
- sensu-plugin is "removed" every puppet run [\#298](https://github.com/sensu/sensu-puppet/issues/298)

**Merged pull requests:**

- allow setting of path [\#425](https://github.com/sensu/sensu-puppet/pull/425) ([fessyfoo](https://github.com/fessyfoo))
- Add require on apt::update for puppetlabs-apt 2.x [\#424](https://github.com/sensu/sensu-puppet/pull/424) ([br0ch0n](https://github.com/br0ch0n))
- Correcting issue \#318  [\#423](https://github.com/sensu/sensu-puppet/pull/423) ([standaloneSA](https://github.com/standaloneSA))
- allow handle and handlers together [\#422](https://github.com/sensu/sensu-puppet/pull/422) ([jlambert121](https://github.com/jlambert121))
- set sysconfig parameters when defined [\#421](https://github.com/sensu/sensu-puppet/pull/421) ([jlambert121](https://github.com/jlambert121))
- Make the sensu enterprise dashboard not show up unbidden [\#419](https://github.com/sensu/sensu-puppet/pull/419) ([hashbrowncipher](https://github.com/hashbrowncipher))
- Move file\_ensure out of conditional [\#418](https://github.com/sensu/sensu-puppet/pull/418) ([hashbrowncipher](https://github.com/hashbrowncipher))
- update apt module dep [\#416](https://github.com/sensu/sensu-puppet/pull/416) ([jlambert121](https://github.com/jlambert121))
- fix redis\_db type def [\#415](https://github.com/sensu/sensu-puppet/pull/415) ([crpeck](https://github.com/crpeck))
- Fix Sensu Enterprise services when not using enterprise [\#409](https://github.com/sensu/sensu-puppet/pull/409) ([Pryz](https://github.com/Pryz))
- Enable provider for sensu plugins [\#408](https://github.com/sensu/sensu-puppet/pull/408) ([rhoml](https://github.com/rhoml))
- Added support to redis db and auto\_reconnect parameters [\#407](https://github.com/sensu/sensu-puppet/pull/407) ([bovy89](https://github.com/bovy89))
- Set fqdn for sensu client name [\#402](https://github.com/sensu/sensu-puppet/pull/402) ([mdevreugd](https://github.com/mdevreugd))
- Add `purge` parameter to control all purging, deprecate `purge\_config… [\#401](https://github.com/sensu/sensu-puppet/pull/401) ([nhinds](https://github.com/nhinds))
- \[WIP\] Sensu Enterprise & Enterprise Dashboard support [\#400](https://github.com/sensu/sensu-puppet/pull/400) ([dhgwilliam](https://github.com/dhgwilliam))
- add \*.swp \(vim buffer files\) to .gitignore [\#398](https://github.com/sensu/sensu-puppet/pull/398) ([jhoblitt](https://github.com/jhoblitt))
- remove world readable permissions from redis.json [\#397](https://github.com/sensu/sensu-puppet/pull/397) ([jhoblitt](https://github.com/jhoblitt))
- convert sensu\_client\_subscription Puppet::notice -\> Puppet::debug [\#395](https://github.com/sensu/sensu-puppet/pull/395) ([jhoblitt](https://github.com/jhoblitt))
- remove world readable permissions from \<handler\>.json [\#393](https://github.com/sensu/sensu-puppet/pull/393) ([jhoblitt](https://github.com/jhoblitt))
- added subdue to sensu\_handler type to handle properly subdue option [\#390](https://github.com/sensu/sensu-puppet/pull/390) ([bovy89](https://github.com/bovy89))
- fixed 385, add owner group sensu:sensu to plugins dir and plugins files [\#386](https://github.com/sensu/sensu-puppet/pull/386) ([hurrycaine](https://github.com/hurrycaine))
- change default for filters param of sensu::handler \(fix \#374\) [\#379](https://github.com/sensu/sensu-puppet/pull/379) ([somic](https://github.com/somic))
- Relax the apt module version restriction [\#378](https://github.com/sensu/sensu-puppet/pull/378) ([johnf](https://github.com/johnf))
- fix source param in sensu\_check [\#377](https://github.com/sensu/sensu-puppet/pull/377) ([kam1kaze](https://github.com/kam1kaze))
- fix subscribers parameter in sensu\_check [\#376](https://github.com/sensu/sensu-puppet/pull/376) ([kam1kaze](https://github.com/kam1kaze))
- fix filters docstring in sensu::handler [\#370](https://github.com/sensu/sensu-puppet/pull/370) ([somic](https://github.com/somic))
- Added support for JIT clients [\#368](https://github.com/sensu/sensu-puppet/pull/368) ([rk295](https://github.com/rk295))
- update travis, gems, lint [\#364](https://github.com/sensu/sensu-puppet/pull/364) ([jlambert121](https://github.com/jlambert121))
- update yum repo location [\#363](https://github.com/sensu/sensu-puppet/pull/363) ([jlambert121](https://github.com/jlambert121))
- ensure plugins installed before client service started [\#362](https://github.com/sensu/sensu-puppet/pull/362) ([jlambert121](https://github.com/jlambert121))
- Updating APT source to use new apt module version [\#361](https://github.com/sensu/sensu-puppet/pull/361) ([bleuchtang](https://github.com/bleuchtang))
- allow modification of hasrestart attribute for services [\#359](https://github.com/sensu/sensu-puppet/pull/359) ([somic](https://github.com/somic))
- Filter attributes are a property, not a param [\#358](https://github.com/sensu/sensu-puppet/pull/358) ([bashtoni](https://github.com/bashtoni))
- Hiera Lookups [\#352](https://github.com/sensu/sensu-puppet/pull/352) ([bleuchtang](https://github.com/bleuchtang))
- fixed spelling error in parameters descriptions [\#350](https://github.com/sensu/sensu-puppet/pull/350) ([paulpet](https://github.com/paulpet))
- Fix problem introduced in \#346 and simplification of create [\#349](https://github.com/sensu/sensu-puppet/pull/349) ([cataphract](https://github.com/cataphract))
- Boolean properties and misc [\#346](https://github.com/sensu/sensu-puppet/pull/346) ([cataphract](https://github.com/cataphract))
- Boolean checking/converting on sensu\_redis\_config [\#345](https://github.com/sensu/sensu-puppet/pull/345) ([superseb](https://github.com/superseb))
- Add install\_options for \(sensu-\)gem provider\(s\) [\#344](https://github.com/sensu/sensu-puppet/pull/344) ([bjwschaap](https://github.com/bjwschaap))
- Add port to check\_args so it doesn't gets cleared by custom property [\#343](https://github.com/sensu/sensu-puppet/pull/343) ([superseb](https://github.com/superseb))

## [v1.5.5](https://github.com/sensu/sensu-puppet/tree/v1.5.5) (2015-04-10)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.5.0...v1.5.5)

**Closed issues:**

- reconnect\_on\_error: reconnect\_on\_error changed 'true' to 'true' [\#338](https://github.com/sensu/sensu-puppet/issues/338)
- Unable to configure client port [\#335](https://github.com/sensu/sensu-puppet/issues/335)
- New configuration: gem uninstall sensu-plugin  is failing in 1.5.0 [\#318](https://github.com/sensu/sensu-puppet/issues/318)
- Invalid parameter provider on Package\[sensu-plugin\] [\#308](https://github.com/sensu/sensu-puppet/issues/308)
- no support for redis\_password [\#305](https://github.com/sensu/sensu-puppet/issues/305)
- The sensu purge\_config option now removes rpm deployed plugins [\#304](https://github.com/sensu/sensu-puppet/issues/304)
- Cannot install gems to develop sensu-puppet [\#301](https://github.com/sensu/sensu-puppet/issues/301)
- Can't remove JSON keys by \(un\)setting class parameters [\#300](https://github.com/sensu/sensu-puppet/issues/300)
- sensu custom json reordered on each run [\#271](https://github.com/sensu/sensu-puppet/issues/271)
- Support defining extensions [\#157](https://github.com/sensu/sensu-puppet/issues/157)

**Merged pull requests:**

- Make client port configurable, issue \#335 [\#341](https://github.com/sensu/sensu-puppet/pull/341) ([superseb](https://github.com/superseb))
- Apply same boolean checking/converting on sensu\_rabbitmq\_config as in sensu\_client\_config, fixes \#338 [\#340](https://github.com/sensu/sensu-puppet/pull/340) ([superseb](https://github.com/superseb))
- adding ability to store rabbitmq cert/keys in hiera/vars instead of just... [\#337](https://github.com/sensu/sensu-puppet/pull/337) ([dkiser](https://github.com/dkiser))
- Fix issue with array checking when no array present. [\#334](https://github.com/sensu/sensu-puppet/pull/334) ([jonathanio](https://github.com/jonathanio))
- Add support for :reconnect\_on\_error. [\#333](https://github.com/sensu/sensu-puppet/pull/333) ([jonathanio](https://github.com/jonathanio))
- Fix \#318: Introducing custom uninstall in sensu\_gem [\#332](https://github.com/sensu/sensu-puppet/pull/332) ([queeno](https://github.com/queeno))
- Allow configuration of the init MAX\_TIMEOUT [\#331](https://github.com/sensu/sensu-puppet/pull/331) ([whpearson](https://github.com/whpearson))
- Restrict access to the client config file to protect client tokens [\#329](https://github.com/sensu/sensu-puppet/pull/329) ([jinnko](https://github.com/jinnko))
- catch blacksmith load issues [\#327](https://github.com/sensu/sensu-puppet/pull/327) ([jlambert121](https://github.com/jlambert121))
- Fix type typo [\#326](https://github.com/sensu/sensu-puppet/pull/326) ([bbanzai](https://github.com/bbanzai))
- to\_type convert :undef into string [\#323](https://github.com/sensu/sensu-puppet/pull/323) ([keymone](https://github.com/keymone))
- add option to purge plugins directory [\#321](https://github.com/sensu/sensu-puppet/pull/321) ([yyejun](https://github.com/yyejun))
- Fix redis noauth [\#316](https://github.com/sensu/sensu-puppet/pull/316) ([bashtoni](https://github.com/bashtoni))
- remove metadata-json-lint limitation [\#315](https://github.com/sensu/sensu-puppet/pull/315) ([jlambert121](https://github.com/jlambert121))
- Make sure filters dir exists before creating any [\#314](https://github.com/sensu/sensu-puppet/pull/314) ([bashtoni](https://github.com/bashtoni))
- Keepalived config not merged since you are specifying the json in the puppet hash variable [\#313](https://github.com/sensu/sensu-puppet/pull/313) ([victorgp](https://github.com/victorgp))
- Fix dependency chain when deploy plugins directory [\#312](https://github.com/sensu/sensu-puppet/pull/312) ([bashtoni](https://github.com/bashtoni))
- typo fixed [\#311](https://github.com/sensu/sensu-puppet/pull/311) ([confiq](https://github.com/confiq))
- ensure erlang is installed for acceptance tests [\#310](https://github.com/sensu/sensu-puppet/pull/310) ([jlambert121](https://github.com/jlambert121))
- Revert "Add parameter to allow purging plugins, handlers, extensions and... [\#307](https://github.com/sensu/sensu-puppet/pull/307) ([jlambert121](https://github.com/jlambert121))
- Added Redis password support [\#306](https://github.com/sensu/sensu-puppet/pull/306) ([jamtur01](https://github.com/jamtur01))
- Sort array properties before comparison [\#303](https://github.com/sensu/sensu-puppet/pull/303) ([dpeters](https://github.com/dpeters))
- Add parameter to allow purging plugins, handlers, extensions and mutators [\#302](https://github.com/sensu/sensu-puppet/pull/302) ([nhinds](https://github.com/nhinds))
- Plugin version [\#299](https://github.com/sensu/sensu-puppet/pull/299) ([jlambert121](https://github.com/jlambert121))

## [v1.5.0](https://github.com/sensu/sensu-puppet/tree/v1.5.0) (2015-01-16)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.4.0...v1.5.0)

**Merged pull requests:**

- Added support for loading and configuring extensions. [\#297](https://github.com/sensu/sensu-puppet/pull/297) ([jonathanio](https://github.com/jonathanio))

## [v1.4.0](https://github.com/sensu/sensu-puppet/tree/v1.4.0) (2015-01-13)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.3.1...v1.4.0)

**Closed issues:**

- lint validation [\#282](https://github.com/sensu/sensu-puppet/issues/282)
- box file is 404 in Vagrant cloud [\#281](https://github.com/sensu/sensu-puppet/issues/281)
- Defining checks via hiera [\#279](https://github.com/sensu/sensu-puppet/issues/279)
- Missing release 1.3.1 from git? [\#275](https://github.com/sensu/sensu-puppet/issues/275)
- New version of amqp deployed today 1.5.0, breaks client mq connection [\#266](https://github.com/sensu/sensu-puppet/issues/266)
- Check defined on server \(subscription check\) results in changes on every run [\#265](https://github.com/sensu/sensu-puppet/issues/265)
- Invalid parameter ssl\_transport on Sensu\_rabbitmq\_config [\#263](https://github.com/sensu/sensu-puppet/issues/263)
- Document what prerequisites are required [\#262](https://github.com/sensu/sensu-puppet/issues/262)

**Merged pull requests:**

- add ability to specify provider for sensu-plugin package [\#296](https://github.com/sensu/sensu-puppet/pull/296) ([jlambert121](https://github.com/jlambert121))
- enable travis container environment [\#295](https://github.com/sensu/sensu-puppet/pull/295) ([jlambert121](https://github.com/jlambert121))
- update gemfile [\#294](https://github.com/sensu/sensu-puppet/pull/294) ([jlambert121](https://github.com/jlambert121))
- fix for future parser [\#292](https://github.com/sensu/sensu-puppet/pull/292) ([jlambert121](https://github.com/jlambert121))
- add puppet requirements, dependency bounds, OS support [\#289](https://github.com/sensu/sensu-puppet/pull/289) ([jlambert121](https://github.com/jlambert121))
- update vagrantfile [\#288](https://github.com/sensu/sensu-puppet/pull/288) ([jlambert121](https://github.com/jlambert121))
- enhance acceptance tests, update spec tests [\#287](https://github.com/sensu/sensu-puppet/pull/287) ([jlambert121](https://github.com/jlambert121))
- Revert "Flapjack support for puppet" [\#286](https://github.com/sensu/sensu-puppet/pull/286) ([jlambert121](https://github.com/jlambert121))
- Fixes for dependencies and subscribers properties in sensu::check. [\#285](https://github.com/sensu/sensu-puppet/pull/285) ([jonathanio](https://github.com/jonathanio))
- Flapjack support for puppet [\#284](https://github.com/sensu/sensu-puppet/pull/284) ([poolski](https://github.com/poolski))
- lint fixes [\#283](https://github.com/sensu/sensu-puppet/pull/283) ([jlambert121](https://github.com/jlambert121))
- Made handle and handlers mutually exclusive [\#280](https://github.com/sensu/sensu-puppet/pull/280) ([jamtur01](https://github.com/jamtur01))
- Adds puppetforge version number [\#278](https://github.com/sensu/sensu-puppet/pull/278) ([spuder](https://github.com/spuder))
- Update sensu\_gem provider [\#277](https://github.com/sensu/sensu-puppet/pull/277) ([adamcrews](https://github.com/adamcrews))
- Vagrant [\#276](https://github.com/sensu/sensu-puppet/pull/276) ([spuder](https://github.com/spuder))
- Add sensu\_gem package provider [\#274](https://github.com/sensu/sensu-puppet/pull/274) ([adamcrews](https://github.com/adamcrews))
- Override path of yum repo if rhel or centos 7. [\#272](https://github.com/sensu/sensu-puppet/pull/272) ([m7ov](https://github.com/m7ov))
- Update tests for unsupported OSes [\#270](https://github.com/sensu/sensu-puppet/pull/270) ([jlambert121](https://github.com/jlambert121))
- fix rabbitmq ssl config [\#268](https://github.com/sensu/sensu-puppet/pull/268) ([patrick-minted](https://github.com/patrick-minted))
- fix filter json [\#267](https://github.com/sensu/sensu-puppet/pull/267) ([patrick-minted](https://github.com/patrick-minted))
- add support for insecure HTTPS in sensu::plugin [\#264](https://github.com/sensu/sensu-puppet/pull/264) ([dhgwilliam](https://github.com/dhgwilliam))

## [v1.3.1](https://github.com/sensu/sensu-puppet/tree/v1.3.1) (2014-10-18)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.3.0...v1.3.1)

**Closed issues:**

- Missing dependency [\#260](https://github.com/sensu/sensu-puppet/issues/260)
- Update README.md to include sensu version compatibility. [\#258](https://github.com/sensu/sensu-puppet/issues/258)
- Custom keepalive settings result in changes on every run [\#257](https://github.com/sensu/sensu-puppet/issues/257)
- Could not load downloaded file /var/lib/puppet/lib/puppet/provider/sensu\_client\_config/json.rb: no such file to load -- rubygems [\#256](https://github.com/sensu/sensu-puppet/issues/256)
- Add compatibility for Sensu 0.13 [\#209](https://github.com/sensu/sensu-puppet/issues/209)
- use\_embedded\_ruby doesn't work on centos [\#208](https://github.com/sensu/sensu-puppet/issues/208)
- checks: removing type =\> metric doesn't remove it from the config json [\#166](https://github.com/sensu/sensu-puppet/issues/166)
- sensu::check is trying to escape double quotes passed in a part of the check command [\#158](https://github.com/sensu/sensu-puppet/issues/158)
- SSL & rabbitmq config..? [\#143](https://github.com/sensu/sensu-puppet/issues/143)

**Merged pull requests:**

- Corrects dependency problems in read me [\#261](https://github.com/sensu/sensu-puppet/pull/261) ([spuder](https://github.com/spuder))

## [v1.3.0](https://github.com/sensu/sensu-puppet/tree/v1.3.0) (2014-10-12)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.2.1...v1.3.0)

**Closed issues:**

- Add "What is Sensu" to the README.md [\#251](https://github.com/sensu/sensu-puppet/issues/251)

**Merged pull requests:**

- Use the command parameter if it's defined alongside the source parameter [\#255](https://github.com/sensu/sensu-puppet/pull/255) ([bodgit](https://github.com/bodgit))
- Add custom variables to subscriptions [\#225](https://github.com/sensu/sensu-puppet/pull/225) ([bodgit](https://github.com/bodgit))

## [v1.2.1](https://github.com/sensu/sensu-puppet/tree/v1.2.1) (2014-09-28)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.2.0...v1.2.1)

**Closed issues:**

- Description of module [\#252](https://github.com/sensu/sensu-puppet/issues/252)
- Title of module [\#250](https://github.com/sensu/sensu-puppet/issues/250)
- Wiki [\#239](https://github.com/sensu/sensu-puppet/issues/239)

**Merged pull requests:**

- plugin: Rewrite the logic of define\_plugins\_dir [\#254](https://github.com/sensu/sensu-puppet/pull/254) ([Spredzy](https://github.com/Spredzy))
- Ignore .vagrant/ [\#253](https://github.com/sensu/sensu-puppet/pull/253) ([petems](https://github.com/petems))

## [v1.2.0](https://github.com/sensu/sensu-puppet/tree/v1.2.0) (2014-09-23)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.1.0...v1.2.0)

**Closed issues:**

- Use of str2bool for a value that's already a bool [\#245](https://github.com/sensu/sensu-puppet/issues/245)
- setting install\_repo to false breaks module [\#233](https://github.com/sensu/sensu-puppet/issues/233)
- how to configure logstash handler? [\#226](https://github.com/sensu/sensu-puppet/issues/226)
- Sensu\_client\_config and subscriptions are always retriggered at every puppet run, leading to no-checks being run under certain circumstances [\#216](https://github.com/sensu/sensu-puppet/issues/216)
- Needed apt-get update after adding new apt-key [\#201](https://github.com/sensu/sensu-puppet/issues/201)
- Plugin directory source doesn't work [\#197](https://github.com/sensu/sensu-puppet/issues/197)
- Sensu client config notify on no change [\#187](https://github.com/sensu/sensu-puppet/issues/187)

**Merged pull requests:**

- Add rabbitmq\_ssl parameter to enable SSL transport to RabbitMQ [\#249](https://github.com/sensu/sensu-puppet/pull/249) ([misterdorm](https://github.com/misterdorm))
- A \(better\) fix for Issue \#197 [\#248](https://github.com/sensu/sensu-puppet/pull/248) ([zanloy](https://github.com/zanloy))
- Fix check of $sensu::install\_repo [\#246](https://github.com/sensu/sensu-puppet/pull/246) ([octete](https://github.com/octete))
- Fixissue197 [\#244](https://github.com/sensu/sensu-puppet/pull/244) ([zanloy](https://github.com/zanloy))
- Revert "Fixissue197" [\#242](https://github.com/sensu/sensu-puppet/pull/242) ([jamtur01](https://github.com/jamtur01))
- Fixissue197 [\#241](https://github.com/sensu/sensu-puppet/pull/241) ([zanloy](https://github.com/zanloy))
- Fixing dependencies parameter on sensu\_check type [\#240](https://github.com/sensu/sensu-puppet/pull/240) ([Phracks](https://github.com/Phracks))
- Support for transport pipe configuration [\#238](https://github.com/sensu/sensu-puppet/pull/238) ([sdklein](https://github.com/sdklein))
- Add optional pipe property to sensu\_handler [\#237](https://github.com/sensu/sensu-puppet/pull/237) ([yeungda](https://github.com/yeungda))
- Basic working Beaker spec for Sensu [\#236](https://github.com/sensu/sensu-puppet/pull/236) ([petems](https://github.com/petems))
- Add warning for dashboard [\#235](https://github.com/sensu/sensu-puppet/pull/235) ([petems](https://github.com/petems))
- Fix for issue \#233: accomodating for install\_repo, with specs [\#234](https://github.com/sensu/sensu-puppet/pull/234) ([bjwschaap](https://github.com/bjwschaap))
- Fix client keepalive cycling [\#232](https://github.com/sensu/sensu-puppet/pull/232) ([johnf](https://github.com/johnf))
- Fix filter attributes [\#229](https://github.com/sensu/sensu-puppet/pull/229) ([johnf](https://github.com/johnf))
- Fix handler filter [\#228](https://github.com/sensu/sensu-puppet/pull/228) ([johnf](https://github.com/johnf))
- Add condition if sensu::install\_repo is false [\#227](https://github.com/sensu/sensu-puppet/pull/227) ([wallies](https://github.com/wallies))
- Set a GEM\_PATH variable in /etc/default/sensu [\#203](https://github.com/sensu/sensu-puppet/pull/203) ([octete](https://github.com/octete))

## [v1.1.0](https://github.com/sensu/sensu-puppet/tree/v1.1.0) (2014-08-16)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v1.0.0...v1.1.0)

**Closed issues:**

- Invalid parameter bind on Sensu\_api\_config [\#223](https://github.com/sensu/sensu-puppet/issues/223)
- Sensu service needs to start before API service [\#219](https://github.com/sensu/sensu-puppet/issues/219)
- Passwordless dashboard not idempotent [\#205](https://github.com/sensu/sensu-puppet/issues/205)
- Dependency cycle when using sensu::handler in the same catalogue as sensu server [\#186](https://github.com/sensu/sensu-puppet/issues/186)
- Forge package contains 'hidden' OSX files [\#185](https://github.com/sensu/sensu-puppet/issues/185)
- Allow configuration of "bind" parameter for API and Dashboard [\#182](https://github.com/sensu/sensu-puppet/issues/182)
- Add support for service management via runit [\#181](https://github.com/sensu/sensu-puppet/issues/181)
- sensu-api should refresh when a new check is added [\#180](https://github.com/sensu/sensu-puppet/issues/180)
- $releasever in yum only works on redhat [\#179](https://github.com/sensu/sensu-puppet/issues/179)
- sensu::check notifies the server even when not running the service [\#171](https://github.com/sensu/sensu-puppet/issues/171)
- After updating/creating a check, puppet will not refresh sensu-client reliably.  [\#169](https://github.com/sensu/sensu-puppet/issues/169)
- Filter definition requires a client subscription [\#167](https://github.com/sensu/sensu-puppet/issues/167)
- No way to configure bind for services? [\#163](https://github.com/sensu/sensu-puppet/issues/163)
- Idempotence problems with sensu\_dashboard\_config [\#162](https://github.com/sensu/sensu-puppet/issues/162)
- Feature: Add support for check dependencies [\#161](https://github.com/sensu/sensu-puppet/issues/161)
- Subscriptions don't have a require on the sensu package [\#159](https://github.com/sensu/sensu-puppet/issues/159)
- crashing check.pp and api/config.pp [\#154](https://github.com/sensu/sensu-puppet/issues/154)
- You've released v1.0.0 of your module but not tagged the SHA1 [\#150](https://github.com/sensu/sensu-puppet/issues/150)
- Intermittent catalog error [\#148](https://github.com/sensu/sensu-puppet/issues/148)
- Service\['sensu-client'\] doesn't get refreshed when checks are purged [\#145](https://github.com/sensu/sensu-puppet/issues/145)
- Standalone checks are default true? [\#144](https://github.com/sensu/sensu-puppet/issues/144)
- handler hash ordering causing unneeded changes [\#133](https://github.com/sensu/sensu-puppet/issues/133)

**Merged pull requests:**

- Fix conf base path [\#224](https://github.com/sensu/sensu-puppet/pull/224) ([johnf](https://github.com/johnf))
- Added the transport option as a supported handler type for Sensu 0.13 [\#222](https://github.com/sensu/sensu-puppet/pull/222) ([solarkennedy](https://github.com/solarkennedy))
- Deprecate dashboard [\#221](https://github.com/sensu/sensu-puppet/pull/221) ([johnf](https://github.com/johnf))
- Apt key and Repo dependency [\#220](https://github.com/sensu/sensu-puppet/pull/220) ([johnf](https://github.com/johnf))
- fixes one final bug from \#200 / \#217 [\#218](https://github.com/sensu/sensu-puppet/pull/218) ([misterdorm](https://github.com/misterdorm))
- several fixes for things that were botched on \#200 [\#217](https://github.com/sensu/sensu-puppet/pull/217) ([misterdorm](https://github.com/misterdorm))
- Remove default username for sensu [\#214](https://github.com/sensu/sensu-puppet/pull/214) ([rhoml](https://github.com/rhoml))
- Remove unused $notify in check.pp [\#212](https://github.com/sensu/sensu-puppet/pull/212) ([max-koehler](https://github.com/max-koehler))
- Make the rabbitmq\_vhost defaults match the docs [\#211](https://github.com/sensu/sensu-puppet/pull/211) ([bodgit](https://github.com/bodgit))
- sensu-plugin: Allow one to install the gem [\#210](https://github.com/sensu/sensu-puppet/pull/210) ([Spredzy](https://github.com/Spredzy))
- plugin: Allow to retrieve plugin from URL [\#207](https://github.com/sensu/sensu-puppet/pull/207) ([Spredzy](https://github.com/Spredzy))
- adding occurrences and refresh parameters to sensu\_check type and sensu:... [\#200](https://github.com/sensu/sensu-puppet/pull/200) ([misterdorm](https://github.com/misterdorm))
- Parameters for apt GPG key ID and GPG key source [\#199](https://github.com/sensu/sensu-puppet/pull/199) ([yasn77](https://github.com/yasn77))
- Add Bind Options for Client, Dashboard, and API [\#198](https://github.com/sensu/sensu-puppet/pull/198) ([livingeek](https://github.com/livingeek))
- Merge \#195 [\#196](https://github.com/sensu/sensu-puppet/pull/196) ([jlambert121](https://github.com/jlambert121))
- rename .gemfile to Gemfile [\#194](https://github.com/sensu/sensu-puppet/pull/194) ([jlambert121](https://github.com/jlambert121))
- restart client,server,api based on what the machine has provisioned [\#193](https://github.com/sensu/sensu-puppet/pull/193) ([jlambert121](https://github.com/jlambert121))
- remove duplicate require [\#192](https://github.com/sensu/sensu-puppet/pull/192) ([jlambert121](https://github.com/jlambert121))
- add dependencies to sensu::check [\#191](https://github.com/sensu/sensu-puppet/pull/191) ([jlambert121](https://github.com/jlambert121))
- notify client and/or server if enabled [\#190](https://github.com/sensu/sensu-puppet/pull/190) ([jlambert121](https://github.com/jlambert121))
- add puppet 3.5, 3.6 testing [\#189](https://github.com/sensu/sensu-puppet/pull/189) ([jlambert121](https://github.com/jlambert121))
- Documentation bug fix [\#188](https://github.com/sensu/sensu-puppet/pull/188) ([ves](https://github.com/ves))
- Change default vhost to not include a slash and other readme fixes [\#184](https://github.com/sensu/sensu-puppet/pull/184) ([matjohn2](https://github.com/matjohn2))
- Use `lookupvar` to find variables in `sensu::` namespace [\#183](https://github.com/sensu/sensu-puppet/pull/183) ([hryk](https://github.com/hryk))
- Fix warnings from ruby like this: [\#178](https://github.com/sensu/sensu-puppet/pull/178) ([bobtfish](https://github.com/bobtfish))
- updated native types and providers to use base\_path/config when puppet i... [\#176](https://github.com/sensu/sensu-puppet/pull/176) ([logicminds](https://github.com/logicminds))
- Use $url param to build apt-key url [\#175](https://github.com/sensu/sensu-puppet/pull/175) ([patdowney](https://github.com/patdowney))
- Changed repo check from operatingsystem to osfamily [\#173](https://github.com/sensu/sensu-puppet/pull/173) ([george-b](https://github.com/george-b))
- Fix sensu dashboard config type conversion to always be a string [\#170](https://github.com/sensu/sensu-puppet/pull/170) ([solarkennedy](https://github.com/solarkennedy))
- Machines which don't have internet access can't pull the repo key [\#165](https://github.com/sensu/sensu-puppet/pull/165) ([bobtfish](https://github.com/bobtfish))
- Add hasrestart & hasstatus to service management. [\#164](https://github.com/sensu/sensu-puppet/pull/164) ([rhoml](https://github.com/rhoml))
- fix updating handler socket =\> host value [\#160](https://github.com/sensu/sensu-puppet/pull/160) ([danshultz](https://github.com/danshultz))
- Converted timeout to numeric [\#156](https://github.com/sensu/sensu-puppet/pull/156) ([zdenekjanda](https://github.com/zdenekjanda))
- Fixed incorrect documentation in check configuration [\#152](https://github.com/sensu/sensu-puppet/pull/152) ([jbehrends](https://github.com/jbehrends))
- make booleans booleans and fix filters [\#151](https://github.com/sensu/sensu-puppet/pull/151) ([crewton](https://github.com/crewton))
- fix default dashboard port in type [\#149](https://github.com/sensu/sensu-puppet/pull/149) ([jlambert121](https://github.com/jlambert121))
- remove default parameter from readme [\#146](https://github.com/sensu/sensu-puppet/pull/146) ([jlambert121](https://github.com/jlambert121))

## [v1.0.0](https://github.com/sensu/sensu-puppet/tree/v1.0.0) (2014-01-31)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v0.7.6...v1.0.0)

**Closed issues:**

- Use str2bool\(\) from stdlib [\#124](https://github.com/sensu/sensu-puppet/issues/124)
- Adding/removing a standalone check to a node does not cause the sensu-client service to reload [\#123](https://github.com/sensu/sensu-puppet/issues/123)
- Config json files are empty \(only if I run puppet from server\) [\#118](https://github.com/sensu/sensu-puppet/issues/118)
- Invalid parameter socket on sensu::handler definition [\#116](https://github.com/sensu/sensu-puppet/issues/116)
- Unable to specify occurences for a check [\#115](https://github.com/sensu/sensu-puppet/issues/115)
- Invalid symlink [\#101](https://github.com/sensu/sensu-puppet/issues/101)
- Ability to define filters [\#88](https://github.com/sensu/sensu-puppet/issues/88)
- Invalid parameter safe\_mode [\#79](https://github.com/sensu/sensu-puppet/issues/79)
- Default all checks in module to standalone [\#62](https://github.com/sensu/sensu-puppet/issues/62)
- SSL Certificate warnings [\#10](https://github.com/sensu/sensu-puppet/issues/10)

**Merged pull requests:**

- update rabbitmq default port [\#147](https://github.com/sensu/sensu-puppet/pull/147) ([jlambert121](https://github.com/jlambert121))
- Support for timeout,aggregate,handle and publish parameters to sensu\_check [\#142](https://github.com/sensu/sensu-puppet/pull/142) ([zdenekjanda](https://github.com/zdenekjanda))
- Minor docs fixes and increment Modulefile [\#140](https://github.com/sensu/sensu-puppet/pull/140) ([jamtur01](https://github.com/jamtur01))
- add documentation for dashboard and api parameters [\#139](https://github.com/sensu/sensu-puppet/pull/139) ([jlambert121](https://github.com/jlambert121))
- types and provider parent load paths fixed [\#138](https://github.com/sensu/sensu-puppet/pull/138) ([jlambert121](https://github.com/jlambert121))
- increase parent path [\#137](https://github.com/sensu/sensu-puppet/pull/137) ([jlambert121](https://github.com/jlambert121))
- Fix puppet lib loading issues [\#136](https://github.com/sensu/sensu-puppet/pull/136) ([zdenekjanda](https://github.com/zdenekjanda))
- Exclude brackets from the name as this makes sensu barf [\#135](https://github.com/sensu/sensu-puppet/pull/135) ([bobtfish](https://github.com/bobtfish))
- Allow sensu user to be created by other means [\#134](https://github.com/sensu/sensu-puppet/pull/134) ([wleese](https://github.com/wleese))
- documents sensu handler config how to [\#132](https://github.com/sensu/sensu-puppet/pull/132) ([jaimegago](https://github.com/jaimegago))
- remove str2bool, add repo\_source [\#130](https://github.com/sensu/sensu-puppet/pull/130) ([jlambert121](https://github.com/jlambert121))
- fix trailing comma for 1.8.7 [\#129](https://github.com/sensu/sensu-puppet/pull/129) ([jlambert121](https://github.com/jlambert121))
- make travis happy with ruby 1.8.7 [\#128](https://github.com/sensu/sensu-puppet/pull/128) ([jlambert121](https://github.com/jlambert121))
- add filters [\#127](https://github.com/sensu/sensu-puppet/pull/127) ([jlambert121](https://github.com/jlambert121))
- module rewrite [\#126](https://github.com/sensu/sensu-puppet/pull/126) ([jlambert121](https://github.com/jlambert121))
- Add support to set loglevel [\#125](https://github.com/sensu/sensu-puppet/pull/125) ([wleese](https://github.com/wleese))
- Exclude brackets from check names as this makes sensu barf [\#122](https://github.com/sensu/sensu-puppet/pull/122) ([bobtfish](https://github.com/bobtfish))
- Make integers come out in JSON as integers. [\#121](https://github.com/sensu/sensu-puppet/pull/121) ([bobtfish](https://github.com/bobtfish))
- Added API parameters for user and password [\#119](https://github.com/sensu/sensu-puppet/pull/119) ([solarkennedy](https://github.com/solarkennedy))
- add puppet 3.4, remove puppet 3.0 testing [\#117](https://github.com/sensu/sensu-puppet/pull/117) ([jlambert121](https://github.com/jlambert121))
- update puppet versions, add ruby 2.0, remove ruby-head [\#111](https://github.com/sensu/sensu-puppet/pull/111) ([jlambert121](https://github.com/jlambert121))
- fix rerun of socket port [\#110](https://github.com/sensu/sensu-puppet/pull/110) ([antonlindstrom](https://github.com/antonlindstrom))

## [v0.7.6](https://github.com/sensu/sensu-puppet/tree/v0.7.6) (2013-12-01)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v0.7.5...v0.7.6)

**Closed issues:**

- Add parameter to enable/disable notifies on config change [\#112](https://github.com/sensu/sensu-puppet/issues/112)
- Sensu API fails if there is no `/etc/sensu/config.json` [\#105](https://github.com/sensu/sensu-puppet/issues/105)
- Handler for udp type not created correctly [\#102](https://github.com/sensu/sensu-puppet/issues/102)

**Merged pull requests:**

- Added sensu::manage\_services to optionally disable internal service management. [\#113](https://github.com/sensu/sensu-puppet/pull/113) ([vmadman](https://github.com/vmadman))
- Allow setting RUBYOPT [\#109](https://github.com/sensu/sensu-puppet/pull/109) ([doismellburning](https://github.com/doismellburning))
- if udp handler socket defined -\> to\_i [\#108](https://github.com/sensu/sensu-puppet/pull/108) ([jlambert121](https://github.com/jlambert121))
- set version on dependencies in Modulefile [\#107](https://github.com/sensu/sensu-puppet/pull/107) ([antonlindstrom](https://github.com/antonlindstrom))
- Several fixes [\#106](https://github.com/sensu/sensu-puppet/pull/106) ([LarsFronius](https://github.com/LarsFronius))
- fix for issue 102 [\#104](https://github.com/sensu/sensu-puppet/pull/104) ([jlambert121](https://github.com/jlambert121))
- Construct correct yum repo URL with facts [\#103](https://github.com/sensu/sensu-puppet/pull/103) ([nodoubleg](https://github.com/nodoubleg))
- Fixed RedHat support. We are running Red Hat Enterprise Linux Server rel... [\#100](https://github.com/sensu/sensu-puppet/pull/100) ([twissmueller](https://github.com/twissmueller))
- convert custom params to appropriate types [\#99](https://github.com/sensu/sensu-puppet/pull/99) ([j-russell](https://github.com/j-russell))
- conf.d should be a directory not a file [\#96](https://github.com/sensu/sensu-puppet/pull/96) ([stephenrjohnson](https://github.com/stephenrjohnson))
- proper scoping for template var [\#95](https://github.com/sensu/sensu-puppet/pull/95) ([jlambert121](https://github.com/jlambert121))
- updated purge\_configs and file perms [\#94](https://github.com/sensu/sensu-puppet/pull/94) ([jlambert121](https://github.com/jlambert121))
-  Purge /etc/sensu/conf.d/{checks,handlers} as well [\#93](https://github.com/sensu/sensu-puppet/pull/93) ([philandstuff](https://github.com/philandstuff))
- Documentation fix: refresh values [\#91](https://github.com/sensu/sensu-puppet/pull/91) ([bashtoni](https://github.com/bashtoni))
- allow you to disable dashboard authentication [\#82](https://github.com/sensu/sensu-puppet/pull/82) ([chaoranxie](https://github.com/chaoranxie))

## [v0.7.5](https://github.com/sensu/sensu-puppet/tree/v0.7.5) (2013-06-20)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v0.5.0...v0.7.5)

**Closed issues:**

- Disable dashboard user/password [\#81](https://github.com/sensu/sensu-puppet/issues/81)
- client key/values? [\#80](https://github.com/sensu/sensu-puppet/issues/80)
- Getting class sensu::repo working with amazon linux [\#70](https://github.com/sensu/sensu-puppet/issues/70)
- Ability to add additional client / check configuration in Check type. [\#61](https://github.com/sensu/sensu-puppet/issues/61)
- Question about how to use the sensu::check [\#59](https://github.com/sensu/sensu-puppet/issues/59)
- http://forge.puppetlabs.com/sensu/sensu.json [\#50](https://github.com/sensu/sensu-puppet/issues/50)

**Merged pull requests:**

- Add custom client attributes [\#90](https://github.com/sensu/sensu-puppet/pull/90) ([fpletz](https://github.com/fpletz))
- Don't skips tests for service\_server and service\_client [\#89](https://github.com/sensu/sensu-puppet/pull/89) ([pburkholder](https://github.com/pburkholder))
- default check standalone value is true [\#86](https://github.com/sensu/sensu-puppet/pull/86) ([jlambert121](https://github.com/jlambert121))
- Check arg [\#85](https://github.com/sensu/sensu-puppet/pull/85) ([bogue1979](https://github.com/bogue1979))
- Prevent re-running sensu::check every puppet run  [\#84](https://github.com/sensu/sensu-puppet/pull/84) ([sdklein](https://github.com/sdklein))
- Prevent executing sensu::check resource every puppet run [\#78](https://github.com/sensu/sensu-puppet/pull/78) ([j-russell](https://github.com/j-russell))
- Remove deprecation warning [\#77](https://github.com/sensu/sensu-puppet/pull/77) ([jlambert121](https://github.com/jlambert121))
- Expose the occurrences check parameter [\#76](https://github.com/sensu/sensu-puppet/pull/76) ([bashtoni](https://github.com/bashtoni))
- ensure safe\_mode param is a boolean [\#74](https://github.com/sensu/sensu-puppet/pull/74) ([jlambert121](https://github.com/jlambert121))
- Containment [\#73](https://github.com/sensu/sensu-puppet/pull/73) ([jlambert121](https://github.com/jlambert121))
- Notifu notification [\#72](https://github.com/sensu/sensu-puppet/pull/72) ([bogue1979](https://github.com/bogue1979))
- Add safe\_mode for checks [\#71](https://github.com/sensu/sensu-puppet/pull/71) ([bashtoni](https://github.com/bashtoni))
- Added template support for /etc/default/sensu [\#69](https://github.com/sensu/sensu-puppet/pull/69) ([sdklein](https://github.com/sdklein))
- Fixed minor error in README.md [\#68](https://github.com/sensu/sensu-puppet/pull/68) ([max-koehler](https://github.com/max-koehler))
- Change yumrepo attribute 'name' to 'descr' to suppress yum warning [\#67](https://github.com/sensu/sensu-puppet/pull/67) ([j-russell](https://github.com/j-russell))
- update pending checks to validate errors [\#66](https://github.com/sensu/sensu-puppet/pull/66) ([jlambert121](https://github.com/jlambert121))
- Integers in checks [\#65](https://github.com/sensu/sensu-puppet/pull/65) ([jlambert121](https://github.com/jlambert121))
- Handler config [\#64](https://github.com/sensu/sensu-puppet/pull/64) ([jlambert121](https://github.com/jlambert121))
- Sensu check modifications. [\#63](https://github.com/sensu/sensu-puppet/pull/63) ([phobos182](https://github.com/phobos182))
- Realname [\#60](https://github.com/sensu/sensu-puppet/pull/60) ([jamtur01](https://github.com/jamtur01))
- Add a notify between server and client when both are running [\#57](https://github.com/sensu/sensu-puppet/pull/57) ([garethr](https://github.com/garethr))
- allow installing plugins via package, dir sync, or file [\#56](https://github.com/sensu/sensu-puppet/pull/56) ([jlambert121](https://github.com/jlambert121))
- Made some minor docs updates [\#55](https://github.com/sensu/sensu-puppet/pull/55) ([jamtur01](https://github.com/jamtur01))
- Readme update [\#54](https://github.com/sensu/sensu-puppet/pull/54) ([jlambert121](https://github.com/jlambert121))
- Add dependency on the package to the plugin and handler directories [\#52](https://github.com/sensu/sensu-puppet/pull/52) ([garethr](https://github.com/garethr))
- add default handler in readme example [\#51](https://github.com/sensu/sensu-puppet/pull/51) ([antonlindstrom](https://github.com/antonlindstrom))

## [v0.5.0](https://github.com/sensu/sensu-puppet/tree/v0.5.0) (2013-03-16)
[Full Changelog](https://github.com/sensu/sensu-puppet/compare/v0.0.1...v0.5.0)

**Closed issues:**

- check config standalone boolean [\#34](https://github.com/sensu/sensu-puppet/issues/34)
- Error: Must pass rabbitmq\_password to Class\[Sensu\] [\#31](https://github.com/sensu/sensu-puppet/issues/31)
- Add support for standalone checks [\#28](https://github.com/sensu/sensu-puppet/issues/28)
- issue with running the sensu module, Invalid resource type sensu at /root/p\_sensu/site.pp:4 on node [\#25](https://github.com/sensu/sensu-puppet/issues/25)
- Puppet 3.1.0 shows warning due to Puppet.features.rubygems? require in json.rb [\#23](https://github.com/sensu/sensu-puppet/issues/23)

**Merged pull requests:**

- update example configuration in README [\#49](https://github.com/sensu/sensu-puppet/pull/49) ([antonlindstrom](https://github.com/antonlindstrom))
- fix capitalization of resource references [\#48](https://github.com/sensu/sensu-puppet/pull/48) ([antonlindstrom](https://github.com/antonlindstrom))
- ensure type is set first puppet run [\#47](https://github.com/sensu/sensu-puppet/pull/47) ([jlambert121](https://github.com/jlambert121))
- output boolean type for standalone and aggregate [\#46](https://github.com/sensu/sensu-puppet/pull/46) ([jlambert121](https://github.com/jlambert121))
- fix for setting handler parameters first run [\#45](https://github.com/sensu/sensu-puppet/pull/45) ([jlambert121](https://github.com/jlambert121))
- property naming fix [\#44](https://github.com/sensu/sensu-puppet/pull/44) ([jlambert121](https://github.com/jlambert121))
- Add optional arguments to sensu\_check provider. Set sane defaults. [\#43](https://github.com/sensu/sensu-puppet/pull/43) ([phobos182](https://github.com/phobos182))
- fix subscription recompilation every run [\#42](https://github.com/sensu/sensu-puppet/pull/42) ([jlambert121](https://github.com/jlambert121))
- add flag to allow sensu to purge unmanaged config files [\#41](https://github.com/sensu/sensu-puppet/pull/41) ([jlambert121](https://github.com/jlambert121))
- Update checks [\#40](https://github.com/sensu/sensu-puppet/pull/40) ([jlambert121](https://github.com/jlambert121))
- add exchanges, mutators, handler cleanup [\#39](https://github.com/sensu/sensu-puppet/pull/39) ([jlambert121](https://github.com/jlambert121))
- Add standalone / aggregate to the sensu\_check define. [\#38](https://github.com/sensu/sensu-puppet/pull/38) ([phobos182](https://github.com/phobos182))
- Add a boolean flag in checks for Aggregates. [\#37](https://github.com/sensu/sensu-puppet/pull/37) ([phobos182](https://github.com/phobos182))
- prevent sensu\_client\_subscription from rebuilding every run [\#36](https://github.com/sensu/sensu-puppet/pull/36) ([jlambert121](https://github.com/jlambert121))
- Sensu handler severities is an array type. [\#35](https://github.com/sensu/sensu-puppet/pull/35) ([phobos182](https://github.com/phobos182))
- Fixed a bunch of typos, incorrect variable names and linting errors [\#33](https://github.com/sensu/sensu-puppet/pull/33) ([jamtur01](https://github.com/jamtur01))
- Handler install [\#32](https://github.com/sensu/sensu-puppet/pull/32) ([jlambert121](https://github.com/jlambert121))
- Handler type updates [\#30](https://github.com/sensu/sensu-puppet/pull/30) ([jlambert121](https://github.com/jlambert121))
- Added standalone property [\#29](https://github.com/sensu/sensu-puppet/pull/29) ([jamtur01](https://github.com/jamtur01))
- install plugins [\#27](https://github.com/sensu/sensu-puppet/pull/27) ([jlambert121](https://github.com/jlambert121))
- fix spec name [\#26](https://github.com/sensu/sensu-puppet/pull/26) ([jlambert121](https://github.com/jlambert121))
- Misc. linting fixes [\#24](https://github.com/sensu/sensu-puppet/pull/24) ([jamtur01](https://github.com/jamtur01))
- cleaned up rabbitmq spec tests [\#22](https://github.com/sensu/sensu-puppet/pull/22) ([jlambert121](https://github.com/jlambert121))
- Sensu check update [\#21](https://github.com/sensu/sensu-puppet/pull/21) ([jlambert121](https://github.com/jlambert121))
- Sensu subscription [\#20](https://github.com/sensu/sensu-puppet/pull/20) ([jlambert121](https://github.com/jlambert121))
- move each service config to conf.d - no munging config.json [\#19](https://github.com/sensu/sensu-puppet/pull/19) ([jlambert121](https://github.com/jlambert121))
- Enhance package options [\#18](https://github.com/sensu/sensu-puppet/pull/18) ([jlambert121](https://github.com/jlambert121))
- Class redesign [\#17](https://github.com/sensu/sensu-puppet/pull/17) ([jlambert121](https://github.com/jlambert121))
- repo parameter for yum wasn't used [\#16](https://github.com/sensu/sensu-puppet/pull/16) ([jlambert121](https://github.com/jlambert121))
- rename defines that should be classes [\#15](https://github.com/sensu/sensu-puppet/pull/15) ([jlambert121](https://github.com/jlambert121))
- Lint cleanup [\#14](https://github.com/sensu/sensu-puppet/pull/14) ([jlambert121](https://github.com/jlambert121))
- initial spec tests [\#13](https://github.com/sensu/sensu-puppet/pull/13) ([jlambert121](https://github.com/jlambert121))

## [v0.0.1](https://github.com/sensu/sensu-puppet/tree/v0.0.1) (2013-02-12)
**Closed issues:**

- Exported resources are no longer needed [\#5](https://github.com/sensu/sensu-puppet/issues/5)
- Could not evaluate: No ability to determine if sensu\_clean\_config exists [\#1](https://github.com/sensu/sensu-puppet/issues/1)

**Merged pull requests:**

- Added Modulefile [\#12](https://github.com/sensu/sensu-puppet/pull/12) ([jamtur01](https://github.com/jamtur01))
- Update README.md [\#11](https://github.com/sensu/sensu-puppet/pull/11) ([KrisBuytaert](https://github.com/KrisBuytaert))
- Update manifests/rabbitmq.pp [\#8](https://github.com/sensu/sensu-puppet/pull/8) ([tsabirgaliev](https://github.com/tsabirgaliev))
- repo -\> package ordering [\#7](https://github.com/sensu/sensu-puppet/pull/7) ([tsabirgaliev](https://github.com/tsabirgaliev))
- SImple fix for older versions of ruby [\#4](https://github.com/sensu/sensu-puppet/pull/4) ([chrisleavoy](https://github.com/chrisleavoy))
- \[init\] sensu init scripts support restart [\#3](https://github.com/sensu/sensu-puppet/pull/3) ([portertech](https://github.com/portertech))
- Getting my feet wet with sensu-puppet [\#2](https://github.com/sensu/sensu-puppet/pull/2) ([shaftoe](https://github.com/shaftoe))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
