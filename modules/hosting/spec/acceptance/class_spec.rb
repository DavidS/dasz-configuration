require 'spec_helper_acceptance'

describe 'hosting parameters', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'hosting':
        hostmaster => 'david.example.com',
        roundcube_db_password => '12345',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end

