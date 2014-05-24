require 'spec_helper_acceptance'

describe 'dasz::defaults', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'dasz::defaults': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end

