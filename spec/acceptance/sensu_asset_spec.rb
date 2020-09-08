require 'spec_helper_acceptance'

describe 'sensu_asset', if: RSpec.configuration.sensu_mode == 'types' do
  node = hosts_as('sensu-backend')[0]
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_asset { 'test':
        ensure => 'present',
        builds => [
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_amd64.tar.gz",
          "sha512" => "487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d3",
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_armv7.tar.gz",
          "sha512" => "70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68b",
          "filters" => [
            "entity.system.os == 'linux'",
            "entity.system.arch == 'arm'",
            "entity.system.arm_version == 7"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1, proxy2"
          },
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_windows_amd64.tar.gz",
          "sha512" => "10d6411e5c8bd61349897cf8868087189e9ba59c3c206257e1ebc1300706539cf37524ac976d0ed9c8099bdddc50efadacf4f3c89b04a1a8bf5db581f19c157f",
          "filters" => [
            "entity.system.os == 'windows'",
            "entity.system.arch == 'amd64'"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1, proxy2"
          },
        }
        ],
      }
      sensu_asset { 'test-api':
        ensure => 'present',
        builds => [
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_amd64.tar.gz",
          "sha512" => "487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d3",
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_armv7.tar.gz",
          "sha512" => "70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68b",
          "filters" => [
            "entity.system.os == 'linux'",
            "entity.system.arch == 'arm'",
            "entity.system.arm_version == 7"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1, proxy2"
          },
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_windows_amd64.tar.gz",
          "sha512" => "10d6411e5c8bd61349897cf8868087189e9ba59c3c206257e1ebc1300706539cf37524ac976d0ed9c8099bdddc50efadacf4f3c89b04a1a8bf5db581f19c157f",
          "filters" => [
            "entity.system.os == 'windows'",
            "entity.system.arch == 'amd64'"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1, proxy2"
          },
        }
        ],
        provider => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have a valid asset with multiple builds' do
      on node, 'sensuctl asset info test --format json' do
        data = JSON.parse(stdout)
        expect(data['builds'].size).to eq(3)
        expect(data['builds'][0]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_amd64.tar.gz')
        expect(data['builds'][0]['sha512']).to eq('487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d3')
        expect(data['builds'][0]['filters']).to be_nil
        expect(data['builds'][0]['headers']).to be_nil
        expect(data['builds'][1]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_armv7.tar.gz')
        expect(data['builds'][1]['sha512']).to eq('70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68b')
        expect(data['builds'][1]['filters'].size).to eq(3)
        expect(data['builds'][1]['headers']['Authorization']).to eq('Bearer $TOKEN')
        expect(data['builds'][1]['headers']['X-Forwarded-For']).to eq('client1, proxy1, proxy2')
      end
    end

    it 'should have a valid asset with multiple builds using API' do
      on node, 'sensuctl asset info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['builds'].size).to eq(3)
        expect(data['builds'][0]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_amd64.tar.gz')
        expect(data['builds'][0]['sha512']).to eq('487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d3')
        expect(data['builds'][0]['filters']).to be_nil
        expect(data['builds'][0]['headers']).to be_nil
        expect(data['builds'][1]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_linux_armv7.tar.gz')
        expect(data['builds'][1]['sha512']).to eq('70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68b')
        expect(data['builds'][1]['filters'].size).to eq(3)
        expect(data['builds'][1]['headers']['Authorization']).to eq('Bearer $TOKEN')
        expect(data['builds'][1]['headers']['X-Forwarded-For']).to eq('client1, proxy1, proxy2')
      end
    end
  end

  context 'with updates' do
    it 'should work without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_asset { 'test':
        ensure => 'present',
        builds => [
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_amd64.tar.gz",
          "sha512" => "487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d4",
          "filters" => [
            "entity.system.os == 'linux'",
            "entity.system.arch == 'amd64'"
          ],
          "headers"  => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1"
          }
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_armv7.tar.gz",
          "sha512" => "70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68c",
          "filters" => [
            "entity.system.os == 'linux'",
            "entity.system.arch == 'arm'",
            "entity.system.arm_version == 7"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1"
          },
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_windows_amd64.tar.gz",
          "sha512" => "10d6411e5c8bd61349897cf8868087189e9ba59c3c206257e1ebc1300706539cf37524ac976d0ed9c8099bdddc50efadacf4f3c89b04a1a8bf5db581f19c157f",
          "filters" => [
            "entity.system.os == 'windows'",
            "entity.system.arch == 'amd64'"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1"
          },
        }
        ],
      }
      sensu_asset { 'test-api':
        ensure => 'present',
        builds => [
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_amd64.tar.gz",
          "sha512" => "487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d4",
          "filters" => [
            "entity.system.os == 'linux'",
            "entity.system.arch == 'amd64'"
          ],
          "headers"  => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1"
          }
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_armv7.tar.gz",
          "sha512" => "70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68c",
          "filters" => [
            "entity.system.os == 'linux'",
            "entity.system.arch == 'arm'",
            "entity.system.arm_version == 7"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1"
          },
        },
        {
          "url" => "https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.3_windows_amd64.tar.gz",
          "sha512" => "10d6411e5c8bd61349897cf8868087189e9ba59c3c206257e1ebc1300706539cf37524ac976d0ed9c8099bdddc50efadacf4f3c89b04a1a8bf5db581f19c157f",
          "filters" => [
            "entity.system.os == 'windows'",
            "entity.system.arch == 'amd64'"
          ],
          "headers" => {
            "Authorization" => 'Bearer $TOKEN',
            "X-Forwarded-For" => "client1, proxy1"
          },
        }
        ],
        provider => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        # Run it twice and test for idempotency
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    it 'should have a valid asset with multiple builds with updated properties' do
      on node, 'sensuctl asset info test --format json' do
        data = JSON.parse(stdout)
        expect(data['builds'].size).to eq(3)
        expect(data['builds'][0]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_amd64.tar.gz')
        expect(data['builds'][0]['sha512']).to eq('487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d4')
        expect(data['builds'][0]['filters']).to eq(["entity.system.os == 'linux'","entity.system.arch == 'amd64'"])
        expect(data['builds'][0]['headers']['Authorization']).to eq('Bearer $TOKEN')
        expect(data['builds'][0]['headers']['X-Forwarded-For']).to eq('client1, proxy1')
        expect(data['builds'][1]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_armv7.tar.gz')
        expect(data['builds'][1]['sha512']).to eq('70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68c')
        expect(data['builds'][1]['filters'].size).to eq(3)
        expect(data['builds'][1]['headers']['Authorization']).to eq('Bearer $TOKEN')
        expect(data['builds'][1]['headers']['X-Forwarded-For']).to eq('client1, proxy1')
      end
    end

    it 'should have a valid asset with multiple builds with updated properties using API' do
      on node, 'sensuctl asset info test-api --format json' do
        data = JSON.parse(stdout)
        expect(data['builds'].size).to eq(3)
        expect(data['builds'][0]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_amd64.tar.gz')
        expect(data['builds'][0]['sha512']).to eq('487ab34b37da8ce76d2657b62d37b35fbbb240c3546dd463fa0c37dc58a72b786ef0ca396a0a12c8d006ac7fa21923e0e9ae63419a4d56aec41fccb574c1a5d4')
        expect(data['builds'][0]['filters']).to eq(["entity.system.os == 'linux'","entity.system.arch == 'amd64'"])
        expect(data['builds'][0]['headers']['Authorization']).to eq('Bearer $TOKEN')
        expect(data['builds'][0]['headers']['X-Forwarded-For']).to eq('client1, proxy1')
        expect(data['builds'][1]['url']).to eq('https://assets.bonsai.sensu.io/981307deb10ebf1f1433a80da5504c3c53d5c44f/sensu-go-cpu-check_0.0.4_linux_armv7.tar.gz')
        expect(data['builds'][1]['sha512']).to eq('70df8b7e9aa36cf942b972e1781af04815fa560441fcdea1d1538374066a4603fc5566737bfd6c7ffa18314edb858a9f93330a57d430deeb7fd6f75670a8c68c')
        expect(data['builds'][1]['filters'].size).to eq(3)
        expect(data['builds'][1]['headers']['Authorization']).to eq('Bearer $TOKEN')
        expect(data['builds'][1]['headers']['X-Forwarded-For']).to eq('client1, proxy1')
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include sensu::backend
      sensu_asset { 'test': ensure => 'absent' }
      sensu_asset { 'test-api':
        ensure   => 'absent',
        provider => 'sensu_api',
      }
      EOS

      if RSpec.configuration.sensu_use_agent
        site_pp = "node 'sensu-backend' { #{pp} }"
        puppetserver = hosts_as('puppetserver')[0]
        create_remote_file(puppetserver, "/etc/puppetlabs/code/environments/production/manifests/site.pp", site_pp)
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0,2]
        on node, puppet("agent -t --detailed-exitcodes"), acceptable_exit_codes: [0]
      else
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes  => true)
      end
    end

    describe command('sensuctl asset info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
    describe command('sensuctl asset info test-api'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end

