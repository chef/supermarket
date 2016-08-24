#########################################################################
# Install a relatively up-to-date version of PhantomJS for app specs
#########################################################################

remote_file 'Retrieve a pre-built PhantomJS' do
  source 'http://cnpmjs.org/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2'
  path "#{node['delivery']['workspace']['cache']}/phantomjs-2.1.1-linux-x86_64.tar.bz2"
end

execute 'Place PhantomJS in path' do
  command <<-CMD
tar xjvf phantomjs-2.1.1-linux-x86_64.tar.bz2 phantomjs-2.1.1-linux-x86_64/bin/phantomjs && \
mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin && \
chmod +x /usr/local/bin/phantomjs
CMD
  cwd node['delivery']['workspace']['cache']
end

