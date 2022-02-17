# shared_examples "community stats" do
shared_examples_for "community stats" do |template|
  it "displays cookbooks and chefs as singular if there is only 1" do
    assign(:cookbook_count, 1)
    assign(:user_count, 1)
    render template: template
    expect(rendered).to match(%r{1 Cookbook</span>})
    expect(rendered).to match(%r{1 Chef</span>})
  end

  it "displays cookbooks and chefs as plural if there is more than 1" do
    assign(:cookbook_count, 2)
    assign(:user_count, 2)
    render template: template
    expect(rendered).to match(%r{2 Cookbooks</span>})
    expect(rendered).to match(%r{2 Chefs</span>})
  end

  it "delimits numbers correctly if there are more than 999" do
    assign(:cookbook_count, 1000)
    assign(:user_count, 1000)
    render template: template
    expect(rendered).to match(%r{1,000 Cookbooks</span>})
    expect(rendered).to match(%r{1,000 Chefs</span>})
  end
end
