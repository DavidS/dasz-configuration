require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'puppetmaster.dasz.at' do

  describe 'Test installation' do
    it { should contain_package('puppet').with_ensure('present') }
  end

end

