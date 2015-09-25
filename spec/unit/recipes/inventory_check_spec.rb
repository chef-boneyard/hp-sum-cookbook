#
# Cookbook Name:: hp-sum
# Spec:: inventory_check*
#

require 'spec_helper'

describe 'hp-sum::inventory_check' do
  context 'No need to run an inventory check, interval not exceeded.' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['hpsum']['inventory']['lastcheck'] = Time.now.to_i
      end.converge(described_recipe)
    end

    it "logs that 'No need to run the inventory check, still in policy.'" do
      expect(chef_run).to write_log('No need to run the inventory check, still in policy.')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  context 'Needs to run inventory check, lastcheck was nil.' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it "logs that 'Running the inventory check'" do
      expect(chef_run).to write_log('Running the inventory check')
    end

    it 'updates the lastcheck timestamp from nil' do
      expect(chef_run.node['hpsum']['inventory']['lastcheck']).to_not eq(nil)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  context 'Needs to run inventory check, interval exceeded.' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['hpsum']['inventory']['lastcheck'] = 100
      end.converge(described_recipe)
    end

    it "logs that 'Running the inventory check'" do
      expect(chef_run).to write_log('Running the inventory check')
    end

    it 'updates the lastcheck timestamp from 100' do
      expect(chef_run.node['hpsum']['inventory']['lastcheck']).to_not eq(100)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
