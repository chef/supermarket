require 'spec_helper'

describe 'curry routes' do
  it 'has a route to the Curry::Repositories controller' do
    expect(get: '/curry/repositories').to route_to(controller: 'curry/repositories', action: 'index')
    expect(get: curry_repositories_path).to route_to(controller: 'curry/repositories', action: 'index')
  end

  it 'has a route to evaluate an existing repository' do
    expect(post: '/curry/repositories/1/evaluate').
      to route_to(controller: 'curry/repositories', action: 'evaluate', id: '1')
  end
end
