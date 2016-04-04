require 'spec_helper'
require 'vcr_helper'

RSpec.describe Curry::RepositoryMaintainersWorker, type: :worker do

  let(:worker) { Curry::RepositoryMaintainersWorker.new }

  let!(:jane) do
    create(
      :user,
      first_name: 'Jane',
      last_name: 'Doe',
      email: 'janedoe@example.com'
    )
  end

  let!(:xara) do
    create(
      :user,
      first_name: 'Xara',
      last_name: 'Doe',
      email: 'xara@example.com'
    )
  end

  let!(:thom) do
    create(
      :user,
      first_name: 'Thom',
      last_name: 'May',
      email: 'thom@example.com'
    )
  end

  let!(:simple_component) do
    { 'Core' => { 'lieutenant' => 'janedoe' } }
  end

  let!(:full_component) do
    { 'Core' => {
      'lieutenant' => 'janedoe',
      'maintainers' => %w(xara johndoe) }
    }
  end

  let!(:dup_components) do
    { 'Core' => {
      'lieutenant' => 'janedoe',
      'maintainers' => %w(xara janedoe) }
    }
  end

  let!(:sub_components) do
    { 'Core' => {
      'lieutenant' => 'janedoe',
      'maintainers' => 'fred',
      'Sub' => { 'text' => 'foo', 'maintainers' => %w(xara johndoe) }
    }
    }
  end

  before do
    allow(worker).to receive(:people).and_return('janedoe' => { 'GitHub' => 'janedoe' }, 'xara' => { 'GitHub' => 'xara' })
    xara.accounts << create(:account, provider: 'github', username: 'xara')
    jane.accounts << create(:account, provider: 'github', username: 'janedoe')
    thom.accounts << create(:account, provider: 'github', username: 'thommay')
  end

  describe '#perform' do
    let!(:real_worker) { Curry::RepositoryMaintainersWorker.new }
    let!(:paprika) { create(:repository, owner: 'chef', name: 'paprika') }

    it 'should download a maintainers file and parse it' do
      VCR.use_cassette('curry_repository_maintainers', record: :once) do
        real_worker.perform
      end

      expect(real_worker.people).to eql('thommay' => { 'GitHub' => 'thommay' })
    end

    it 'should associate the correct maintainers with the repository' do
      VCR.use_cassette('curry_repository_maintainers', record: :once) do
        real_worker.perform
      end

      expect(paprika.maintainers.length).to be(1)
      expect(paprika.maintainers.first).to eql(thom)
    end
  end

  describe '#components' do
    context 'with a simple component' do
      it 'should return the lieutenant' do
        expect(worker.components(simple_component)).to eql([jane])
      end
    end

    context 'with a full component' do
      it 'should return all recognised users' do
        expect(worker.components(full_component)).to eql([jane, xara])
      end
    end

    context 'with sub components' do
      it 'should return all recognised users' do
        expect(worker.components(sub_components)).to eql([jane, xara])
      end
    end

    context 'with duplicate users' do
      it 'should only include each user once' do
        expect(worker.components(dup_components)).to eql([jane, xara])
      end
    end
  end

  describe '#resolve' do
    context 'with an array' do
      it 'should return the correct users' do
        expect(worker.resolve(%w(janedoe xara))).to eql([jane, xara])
      end

      it 'should filter unexpected users' do
        expect(worker.resolve(%w(janedoe janetdoe xara))).to eql([jane, nil, xara])
      end
    end

    context 'with a string' do
      it 'should return the correct user' do
        expect(worker.resolve('janedoe')).to eql(jane)
      end
    end

    it "should return nil if it can't find a user" do
      expect(worker.resolve('janetdoe')).to be_nil
    end
  end

  describe '#github_user' do
    it 'should return the github userid' do
      expect(worker.github_user('janedoe')).to eq('janedoe')
    end

    it 'should throw an exception if not found' do
      expect { worker.github_user('johndoe') }.to raise_error(NoMethodError)
    end
  end
end
