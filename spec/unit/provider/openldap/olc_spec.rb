require 'spec_helper'

describe Puppet::Type.type(:openldap).provider(:olc) do

  before :each do
    Puppet::Type.type(:openldap).stubs(:defaultprovider).returns described_class
  end

  describe '.instances' do
    it 'should have an instances method' do
      expect(described_class).to respond_to(:instances)
    end

    it 'should get existing objects by running slapcat' do
      described_class.expects(:slapcat).with('-b', 'cn=config', '-o', 'ldif-wrap=no', '-H', 'ldap:///???').returns File.read(my_fixture('slapcat'))
      expect(described_class.instances.map(&:name)).to eq([
        'cn=config',
        'cn=schema,cn=config',
        'cn={0}core,cn=schema,cn=config',
        'olcDatabase={0}config,cn=config',
      ])
    end
  end

  describe '#flush' do
    it 'should import a local LDIF file by filename' do
      provider = described_class.new(Puppet::Type.type(:openldap).new(
        :name  => 'cn={1}cosine,cn=schema,cn=config',
        :ldif  => '/etc/openldap/schema/cosine.ldif',
        :purge => :false,
      ))
      provider.expects(:ldapmodify).with('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', '/etc/openldap/schema/cosine.ldif')
      provider.create
      provider.flush
    end

    it 'should import a local LDIF file by URL' do
      provider = described_class.new(Puppet::Type.type(:openldap).new(
        :name  => 'cn={1}cosine,cn=schema,cn=config',
        :ldif  => 'file:/etc/openldap/schema/cosine.ldif',
        :purge => :false,
      ))
      provider.expects(:ldapmodify).with('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', '/etc/openldap/schema/cosine.ldif')
      provider.create
      provider.flush
    end

    it 'should import an LDIF file by Puppet URL' do
      #provider = described_class.new(Puppet::Type.type(:openldap).new(
      #  :name  => 'cn={1}cosine,cn=schema,cn=config',
      #  :ldif  => 'puppet:///modules/openldap/cosine.ldif',
      #  :purge => :false,
      #))
      #provider.expects(:ldapmodify).with('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', '/etc/openldap/schema/cosine.ldif')
      #provider.create
      #provider.flush
    end
  end
end
