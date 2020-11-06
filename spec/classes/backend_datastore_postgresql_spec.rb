require 'spec_helper'

describe 'sensu::backend::datastore::postgresql', :type => :class do
  on_supported_os.each do |os, facts|
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
          :ensure        => 'present',
          :dsn           => sensitive('postgresql://sensu:changeme@localhost:5432/sensu?sslmode=require'),
          :pool_size     => '20',
          :strict        => 'false',
          :batch_buffer  => '0',
          :batch_size    => '1',
          :batch_workers => '20',
        })
      end

      it do
        should contain_postgresql__server__db('sensu').with({
          :user     => 'sensu',
          :password => /md5/,
        })
      end

      it do
        should contain_file('sensu-backend postgresql_ssl_dir').with({
          'ensure'  => 'directory',
          'path'    => '/var/lib/sensu/.postgresql',
          'owner'   => 'sensu',
          'group'   => 'sensu',
          'mode'    => '0755',
          'require' => 'Package[sensu-go-backend]',
          'notify'  => 'Service[sensu-backend]',
        })
      end
      it { should_not contain_file('sensu-backend postgresql_ca') }
      it { should_not contain_file('sensu-backend postgresql_crl') }
      it { should_not contain_file('sensu-backend postgresql_cert') }
      it { should_not contain_file('sensu-backend postgresql_key') }
      
      context 'sslmode defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_sslmode => 'disable' }
          EOS
        end

        it do
          should contain_sensu_postgres_config('postgresql').with({
            :ensure    => 'present',
            :dsn       => sensitive('postgresql://sensu:changeme@localhost:5432/sensu?sslmode=disable'),
            :pool_size => '20',
          })
        end
      end

      context 'ssl ca source defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_ca_source => 'foo' }
          EOS
        end
        
        it do
          should contain_file('sensu-backend postgresql_ca').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/root.crt',
            'source'  => 'foo',
            'content' => nil,
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0644',
            'notify'  => 'Service[sensu-backend]',
          })
        end
      end

      context 'ssl ca content defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_ca_content => 'foo' }
          EOS
        end
        
        it do
          should contain_file('sensu-backend postgresql_ca').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/root.crt',
            'source'  => nil,
            'content' => 'foo',
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0644',
            'notify'  => 'Service[sensu-backend]',
          })
        end
      end

      context 'ssl crl source defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_crl_source => 'foo' }
          EOS
        end

        it do
          should contain_file('sensu-backend postgresql_crl').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/root.crl',
            'source'  => 'foo',
            'content' => nil,
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0644',
            'notify'  => 'Service[sensu-backend]',
          })
        end
      end

      context 'ssl crl content defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_crl_content => 'foo' }
          EOS
        end

        it do
          should contain_file('sensu-backend postgresql_crl').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/root.crl',
            'source'  => nil,
            'content' => 'foo',
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0644',
            'notify'  => 'Service[sensu-backend]',
          })
        end
      end

      context 'ssl cert source defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_cert_source => 'foo' }
          EOS
        end
        
        it do
          should contain_file('sensu-backend postgresql_cert').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/postgresql.crt',
            'source'  => 'foo',
            'content' => nil,
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0644',
            'notify'  => 'Service[sensu-backend]',
          })
        end
      end

      context 'ssl cert content defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_cert_content => 'foo' }
          EOS
        end
        
        it do
          should contain_file('sensu-backend postgresql_cert').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/postgresql.crt',
            'source'  => nil,
            'content' => 'foo',
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0644',
            'notify'  => 'Service[sensu-backend]',
          })
        end
      end

      context 'ssl key source defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_key_source => 'foo' }
          EOS
        end
        
        it do
          should contain_file('sensu-backend postgresql_key').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/postgresql.key',
            'source'  => 'foo',
            'content' => nil,
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0600',
            'notify'  => 'Service[sensu-backend]',
          })
        end
      end

      context 'ssl key content defined' do
        let(:pre_condition) do
          <<-EOS
          class { '::postgresql::globals': version => '9.6' }
          class { '::postgresql::server': }
          class { 'sensu::backend': postgresql_ssl_key_content => 'foo' }
          EOS
        end
        
        it do
          should contain_file('sensu-backend postgresql_key').with({
            'ensure'  => 'file',
            'path'    => '/var/lib/sensu/.postgresql/postgresql.key',
            'source'  => nil,
            'content' => 'foo',
            'owner'   => 'sensu',
            'group'   => 'sensu',
            'mode'    => '0600',
            'notify'  => 'Service[sensu-backend]',
          })
        end
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
           :dsn       => sensitive('postgresql://sensu:changeme@localhost:5432/sensu?sslmode=require'),
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
