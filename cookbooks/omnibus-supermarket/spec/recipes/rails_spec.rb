describe 'omnibus-supermarket::rails' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  describe 'rails app nginx site' do
    let(:rails_site_config) { '/var/opt/supermarket/nginx/etc/sites-enabled/rails' }

    it 'renders the site template' do
      expect(chef_run).to create_template(rails_site_config)
    end

    describe 'with ssl' do
      it 'listens on default non_ssl_port' do
        expect(chef_run).to render_file(rails_site_config).with_content { |content|
          expect(content).to include('listen 80')
        }
      end

      it 'listens on default ssl_port' do
        expect(chef_run).to render_file(rails_site_config).with_content { |content|
          expect(content).to include('listen 443')
        }
      end

      it 'sets X-Forwarded-Proto header to "https"' do
        expect(chef_run).to render_file(rails_site_config).with_content { |content|
          expect(content).to include('X-Forwarded-Proto https')
        }
      end
    end

    describe 'with no ssl' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
          node.automatic['memory']['total'] = '16000MB'
          node.automatic['supermarket']['ssl']['enabled'] = false
          node.automatic['supermarket']['nginx']['force_ssl'] = false
        end.converge(described_recipe)
      end

      it 'listens on default non_ssl_port' do
        expect(chef_run).to render_file(rails_site_config).with_content { |content|
          expect(content).to include('listen 80')
        }
      end

      it 'does not listen on ssl_port' do
        expect(chef_run).to render_file(rails_site_config).with_content { |content|
          expect(content).not_to include('listen 443')
        }
      end

      it 'sets X-Forwarded-Proto header to "http"' do
        expect(chef_run).to render_file(rails_site_config).with_content { |content|
          expect(content).to include('X-Forwarded-Proto http')
        }
      end

      it 'does not set X-Forwarded-Proto header to "https"' do
        expect(chef_run).to render_file(rails_site_config).with_content { |content|
          expect(content).not_to include('X-Forwarded-Proto https')
        }
      end
    end
  end
end
