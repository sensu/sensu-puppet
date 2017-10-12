require 'spec_helper'

describe 'sensu::plugin', :type => :define do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    class { '::sensu':
      manage_plugins_dir => false,
    }
    ENDofPUPPETcode
  end

  context 'file' do
    let(:title) { 'puppet:///data/plug1' }

    context 'running on Linux' do
      context 'defaults' do
        it do
          should contain_sensu__plugins_dir('puppet:///data/plug1-/etc/sensu/plugins').with({
            :path   => '/etc/sensu/plugins',
          })
        end

        it { should contain_file('/etc/sensu/plugins/plug1').with(
          :source => 'puppet:///data/plug1'
        ) }

      end
    end

    context 'running on Windows' do
      let(:facts) do
        {
          :kernel   => 'windows',
          :osfamily => 'windows',
          :os       => {
            :release => {
              :major => '2012 R2',
            },
          }, # needed for sensu::package
        }
      end
      context 'defaults' do
        it do
          should contain_sensu__plugins_dir('puppet:///data/plug1-C:/opt/sensu/plugins').with({
            :path   => 'C:/opt/sensu/plugins',
          })
        end

        it { should contain_file('C:/opt/sensu/plugins/plug1').with(
          :source => 'puppet:///data/plug1'
        ) }
      end
    end

    context 'setting params' do
      let(:params) { {
        :install_path => '/var/sensu/plugins',
      } }

      it { should contain_file('/var/sensu/plugins/plug1').with(
        :source => 'puppet:///data/plug1'
      ) }
    end
  end

  context 'url' do
    let(:title) { 'https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh' }
    let(:params) do
      {
        :type         => 'url',
        :pkg_checksum => '1d58b78e9785f893889458f8e9fe8627',
      }
    end

    context 'running on Linux' do
      context 'defaults' do
        it do
          should contain_sensu__plugins_dir('https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh-/etc/sensu/plugins').with({
            :path   => '/etc/sensu/plugins',
          })
        end

        it { should contain_remote_file('https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh').with(
          :ensure   => 'present',
          :path     => '/etc/sensu/plugins/check-mem.sh',
          :checksum => '1d58b78e9785f893889458f8e9fe8627'
        ) }

        it do
          should contain_file('/etc/sensu/plugins/check-mem.sh').with({
            :require => [ 'File[/etc/sensu/plugins]', 'Remote_file[https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh]', ],
          })
        end
      end
    end

    context 'running on Windows' do
      let(:facts) do
        {
          :kernel   => 'windows',
          :osfamily => 'windows',
          :os       => {
            :release => {
              :major => '2012 R2',
            }, # needed for sensu::package
          },
        }
      end

      context 'defaults' do
        it do
          should contain_sensu__plugins_dir('https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh-C:/opt/sensu/plugins').with({
            :path   => 'C:/opt/sensu/plugins',
          })
        end

        it { should contain_remote_file('https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh').with(
          :ensure   => 'present',
          :path     => 'C:/opt/sensu/plugins/check-mem.sh',
          :checksum => '1d58b78e9785f893889458f8e9fe8627'
        ) }

        it do
          should contain_file('C:/opt/sensu/plugins/check-mem.sh').with({
            :require => [ 'File[C:/opt/sensu/plugins]', 'Remote_file[https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh]', ],
          })
        end
      end
    end

    context 'setting params' do
      let(:params) { {
        :type         => 'url',
        :install_path => '/var/sensu/plugins',
        :pkg_checksum => '1d58b78e9785f893889458f8e9fe8627'
      } }

      it { should contain_remote_file('https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/check-mem.sh').with(
        :ensure   => 'present',
        :path     => '/var/sensu/plugins/check-mem.sh',
        :checksum => '1d58b78e9785f893889458f8e9fe8627'
      ) }
    end

    context 'new plugin should provide source' do
      let(:title) { 'https://raw.githubusercontent.com/sensu-plugins/sensu-plugins-puppet/master/bin/check-puppet-last-run.rb' }
      let(:params) { {
        :type         => 'url',
        :install_path => '/var/sensu/plugins',
      } }

      it { should contain_remote_file('https://raw.githubusercontent.com/sensu-plugins/sensu-plugins-puppet/master/bin/check-puppet-last-run.rb').with(
        :ensure   => 'present',
        :path     => '/var/sensu/plugins/check-puppet-last-run.rb',
        :source   => 'https://raw.githubusercontent.com/sensu-plugins/sensu-plugins-puppet/master/bin/check-puppet-last-run.rb'
      ) }
    end
  end

  context 'directory' do
    let(:title) { 'puppet:///data/sensu/plugins' }
    let(:params) { { :type => 'directory' } }

    context 'running on Linux' do
      context 'defaults' do
        it do
          should contain_file('/etc/sensu/plugins_for_plugin_puppet:///data/sensu/plugins').with({
            'ensure'  => 'directory',
            'path'    => '/etc/sensu/plugins',
            'mode'    => '0555',
            'source'  => 'puppet:///data/sensu/plugins',
            'recurse' => 'true',
            'purge'   => 'true',
            'force'   => 'true',
          })
        end
      end
    end

    context 'running on Windows' do
      let(:facts) do
        {
          :kernel   => 'windows',
          :osfamily => 'windows',
          :os       => {
            :release => {
              :major => '2012 R2',
            }, # needed for sensu::package
          },
        }
      end

      context 'defaults' do
        it do
          should contain_file('C:/opt/sensu/plugins_for_plugin_puppet:///data/sensu/plugins').with({
            'ensure'  => 'directory',
            'path'    => 'C:/opt/sensu/plugins',
            'mode'    => '0555',
            'source'  => 'puppet:///data/sensu/plugins',
            'recurse' => 'true',
            'purge'   => 'true',
            'force'   => 'true',
          })
        end
      end
    end

    context 'set install_path' do
      let(:params) { { :type => 'directory', :install_path => '/opt/sensu/plugins' } }

      it { should contain_file('/opt/sensu/plugins_for_plugin_puppet:///data/sensu/plugins').with(
        'path' => '/opt/sensu/plugins',
      ) }
    end

    context 'set purge params' do
      let(:params) { { :type => 'directory', :recurse => false, :force => false, :purge => false } }

      it { should contain_file('/etc/sensu/plugins_for_plugin_puppet:///data/sensu/plugins').with(
        'recurse' => false,
        'purge'   => false,
        'force'   => false,
        'mode'    => '0555',
        'owner'   => 'sensu',
        'group'   => 'sensu'
      ) }
    end
  end

  context 'package' do
    let(:title) { 'sensu-plugins' }

    context 'default' do
      let(:params) { { :type => 'package' } }

      it { should contain_package('sensu-plugins').with_ensure('latest') }

      it do
        should contain_package('sensu-plugins').with({
          'ensure'          => 'latest',
          'provider'        => nil,
          'install_options' => nil,
        })
      end
    end

    context 'set pkg_version' do
      let(:params) { { :type => 'package', :pkg_version => '1.1.1' } }

      it { should contain_package('sensu-plugins').with_ensure('1.1.1') }
    end

    context 'set pkg_provider' do
      let(:params) { { :type => 'package', :pkg_provider => 'sensu_gem' } }

      it { should contain_package('sensu-plugins').with_provider('sensu_gem') }
    end

    context 'without pkg_provider set' do
      let(:params) { { :type => 'package' } }

      it { should contain_package('sensu-plugins').with_provider(nil) }
    end

    # without pkg_provider => gem gem_install_options will be ignored
    context 'set gem_install_options' do
      let(:params) { { :type => 'package', :gem_install_options => [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }] } }
      it { should contain_package('sensu-plugins').with_install_options(nil) }
    end

    context 'set gem_install_options and pkg_provider = gem' do
      let(:params) { { :type => 'package', :gem_install_options => [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }], :pkg_provider => 'gem' } }
      it { should contain_package('sensu-plugins').with_install_options([{ '-p' => 'http://user:pass@myproxy.company.org:8080' }]) }
    end
  end

  context 'default' do
    let(:params) { { :type => 'unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  describe 'ordering (#463)' do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    class { '::sensu':
      manage_plugins_dir => false,
    }
    sensu::check { 'ntp':
      command     => 'check_ntp_time -H pool.ntp.org -w 30 -c 60',
      handlers    => 'default',
      subscribers => 'sensu-test',
    }
    ENDofPUPPETcode
  end
    let(:title) { 'puppet:///data/plug1' }
    describe 'notifies the sensu-client service' do
      let(:expected) { { notify: ['Service[sensu-client]'] } }
      it { is_expected.to contain_sensu__plugin(title).with(expected)}
    end
    describe 'comes before sensu checks via Anchor[plugins_before_checks]' do
      let(:expected) { { before: ['Anchor[plugins_before_checks]'] } }
      it { is_expected.to contain_sensu__plugin(title).with(expected)}
    end
  end

  describe 'variable type and content validations' do
    let(:title) { 'puppet:///data/plug1' }
    mandatory_params = {}

    validations = {
      'absolute_path' => {
        :name    => %w[install_path],
        :valid   => %w[/absolute/filepath /absolute/directory/],
        :invalid => ['./relative/path', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::PreformattedError, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
