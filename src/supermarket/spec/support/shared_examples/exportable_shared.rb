shared_examples_for 'exportable' do
  context 'as CSV' do
    require 'csv'
    let!(:model) { described_class }
    let!(:exportable_thing) { FactoryBot.create(model.to_s.underscore.to_sym) }
    let!(:export_output) { model.as_csv }
    let!(:reparsed_csv) { CSV.parse export_output }

    it 'has two rows' do
      expect(reparsed_csv.length).to eq(2)
    end

    it 'has header row of model\'s attributes' do
      expect(reparsed_csv.first).to match_array(exportable_thing.attribute_names)
    end

    it 'has a row for a model in a query' do
      exportable_thing_attr_values = exportable_thing.attributes.values_at(*model.column_names)
      exportable_thing_attr_values_stringified = exportable_thing_attr_values.map(&:to_s)
      expect(reparsed_csv.second.map(&:to_s)).to eq(exportable_thing_attr_values_stringified)
    end
  end
end
