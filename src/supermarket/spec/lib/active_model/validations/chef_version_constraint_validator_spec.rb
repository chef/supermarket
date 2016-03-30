require 'spec_helper'

describe ActiveModel::Validations::ChefVersionConstraintValidator do
  let(:dependency_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :version

      validates :version, chef_version_constraint: true
    end
  end

  it 'validates the model if the attribute is a version constraint' do
    dependency = dependency_class.new(version: '1.2.3')

    expect(dependency.valid?).to eql(true)
  end

  it 'invalidates the model if the attribute is not a version constraint' do
    dependency = dependency_class.new(version: 'snarfle')

    expect(dependency.valid?).to eql(false)
  end

  it "adds an error to the record's attribute if the attribute is invalid" do
    dependency = dependency_class.new(version: 'snarfle')
    dependency.valid?

    expect(dependency.errors[:version]).to_not be_empty
  end

  it 'includes why the constraint is invalid' do
    dependency = dependency_class.new(version: '2')

    expect { dependency.valid? }
      .to change { dependency.errors[:version] }
      .to include(/'2' does not match 'x.y.z' or 'x.y'/)
  end

  it 'has a configurable error message' do
    dependency_class = Class.new do
      include ActiveModel::Model

      attr_accessor :version

      validates :version, chef_version_constraint: { message: 'oh no' }
    end

    dependency = dependency_class.new(version: 'haha')

    expect { dependency.valid? }
      .to change { dependency.errors[:version] }
      .to include(/oh no/)
  end
end
