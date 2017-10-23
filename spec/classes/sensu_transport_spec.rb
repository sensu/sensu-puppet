require 'spec_helper'

describe 'sensu::transport' do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
    class sensu(
      $check_notify                 = 'Class[sensu]',
      $conf_dir                     = '/etc/sensu/conf.d',
      $transport_type               = 'rabbitmq',
      $transport_reconnect_on_error = 'false',
    ) { }
    include sensu
    ENDofPUPPETcode
  end

  describe 'with default values for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('sensu::transport') }

    content = <<-END.gsub(/^\s+\|/, '')
      |{
      |  "transport": {
      |    "name": "rabbitmq",
      |    "reconnect_on_error": "false"
      |  }
      |}
    END

    it do
      should contain_file('/etc/sensu/conf.d/transport.json').with({
        'ensure'  => 'present',
        'owner'   => 'sensu',
        'group'   => 'sensu',
        'mode'    => '0440',
        'content' => content.chomp, # JSON.pretty_generate doesn't add a final line break
        'notify'  => 'Class[sensu]',
      })
    end
  end

  describe 'with ensure set to valid string absent' do
    let(:params) { { :ensure => 'absent'} }
    it { should contain_file('/etc/sensu/conf.d/transport.json').with_ensure('absent') }
  end

  describe 'variable type and content validations' do
    mandatory_params = {} if mandatory_params.nil?

    validations = {
      'string' => {
        :name    => %w[ensure],
        :valid   => %w[absent present],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, nil],
        :message => 'expects a match for Enum\[\'absent\', \'present\'\],',
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
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'

end
