require 'spec_helper'

describe 'sensu::backend::datastore::postgresql', :type => :class do
  on_supported_os({
    facterversion: '3.8.0',
  }).each do |os, facts|
    if facts[:os]['family'] == 'windows'
      next
    end
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<-EOS
        class { '::postgresql::globals': version => '9.6' }
        class { '::postgresql::server': }
        class { 'sensu::backend': }
        EOS
      end

      it { should compile.with_all_deps }

      it do
        should contain_sensu_postgres_config('postgresql').with({
          :ensure    => 'present',
          :dsn       => 'postgresql://sensu:changeme@localhost:5432/sensu',
          :pool_size => '20',
        })
      end

      it do
        should contain_postgresql__server__db('sensu').with({
          :user     => 'sensu',
          :password => /md5/,
        })
      end

      context 'datastore_ensure => absent' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::backend':
            datastore_ensure => 'absent',
          }
          EOS
        end

        it { should compile.with_all_deps }
        it do
          should contain_sensu_postgres_config('postgresql').with({
           :ensure    => 'absent',
           :dsn       => 'postgresql://sensu:changeme@localhost:5432/sensu',
           :pool_size => '20',
         })
        end
        it { should_not contain_postgresql__server__db('sensu') }
      end

      context 'manage_postgresql => false' do
        let(:pre_condition) do
          <<-EOS
          class { 'sensu::backend':
            manage_postgresql_db => false,
          }
          EOS
        end
        it { should compile.with_all_deps }
        it { should_not contain_postgresql__server__db('sensu') }
      end
    end
  end
end
