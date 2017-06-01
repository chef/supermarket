require 'spec_helper'
require 'tempfile'

describe 'the set of SASS assets', type: :feature do
  # A custom branding file.
  class BrandingFile
    # append datetime after name for uniqueness.
    def initialize(name, content = nil)
      t = Time.zone.now
      @filename = "#{name}_#{t.to_i}_#{t.usec}.scss"
      @fullname = File.join(BrandingFile.branding_dir, @filename)
      write(content) if content
    end

    def write(content)
      File.write(@fullname, content)
    end

    def delete
      File.delete(@fullname) if File.exist?(@fullname)
    end

    def self.branding_dir
      p = [File.dirname(__FILE__), '..', '..',
           'app', 'assets', 'stylesheets', 'branding']
      File.expand_path(File.join(p))
    end
  end

  before do
    sign_in(create(:user))
    create_list(:cookbook, 2)
  end

  # Compile SCSS file and return the content.
  #
  # Compiles to temp file and then deletes.  Another possibility for
  # checking the styles would have been to visit the actual stylesheet
  # page in the browser, but the Rails asset pipeline is too slow.
  # Speeding things up is an option (ref
  # https://mattbrictson.com/lightning-fast-sass-reloading-in-rails),
  # but that would require other invasive changes.
  def get_compiled_css(source_file_in_app_assets_stylesheets)
    tempfile = Tempfile.new('outputcss')
    f = "app/assets/stylesheets/#{source_file_in_app_assets_stylesheets}"
    t = tempfile.path + '.css'
    # --load-path is needed for foundation/functions
    `sass --compass --update #{f}:#{t} --load-path vendor/assets/stylesheets`
    ret = File.read(t)
    tempfile.delete
    ret
  end

  context 'when a custom branding file redefines the search input background' do
    before do
      @b = BrandingFile.new('zzzz', '$search_input_bg_color: SOMEVALUE;')
    end

    after { @b.delete }

    it 'should color the background of the search bar' do
      expected = /input\[type=\"search\"\].cookbook_search_textfield {\n  background-color: SOMEVALUE;/
      expect(get_compiled_css('cookbooks/search.scss')).to match(expected)
    end
  end

  context 'when many custom branding file redefine the search input background' do
    before do
      @b2 = BrandingFile.new('zzzz2', '$search_input_bg_color: ANOTHERVALUE;')
      @b1 = BrandingFile.new('zzzz1', '$search_input_bg_color: unusedvalue;')
    end

    after do
      @b1.delete
      @b2.delete
    end

    it 'should color the background of the search bar to the last file determined by filename order' do
      expected = /input\[type=\"search\"\].cookbook_search_textfield {\n  background-color: ANOTHERVALUE;/
      expect(get_compiled_css('cookbooks/search.scss')).to match(expected)
    end
  end

  context 'when one custom branding file is deleted' do
    before do
      @b2 = BrandingFile.new('zzzz2', '$search_input_bg_color: ANOTHERVALUE;')
      @b1 = BrandingFile.new('zzzz1', '$search_input_bg_color: unusedvalue;')
    end

    after do
      @b1.delete
      @b2.delete
    end

    it 'should fall back to the other file' do
      expected = /input\[type=\"search\"\].cookbook_search_textfield {\n  background-color: unusedvalue;/
      expect(get_compiled_css('cookbooks/search.scss')).to_not match(expected)
      @b2.delete
      expect(get_compiled_css('cookbooks/search.scss')).to match(expected)
    end
  end

  context 'when a branding file replaces the appheader logo' do
    before do
      content = "$appheader_logo_svg: 'branding/SOMELOGO.svg';
$appheader_logo_png: 'branding/SOMELOGO.png';"
      @b = BrandingFile.new('zzzz', content)
    end

    after { @b.delete }

    it 'should replace the logo' do
      expected_svg = /logochef {\n  background: url\(image-path\("branding\/SOMELOGO.svg"\)\)/
      expected_png = /\.no-svg \.logochef {\n    background: url\(image-path\(\"branding\/SOMELOGO.png\"\)\)/
      css = get_compiled_css('appheader.scss')
      expect(css).to match(expected_svg)
      expect(css).to match(expected_png)
    end
  end
end
