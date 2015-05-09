namespace :setup do
  desc 'Test all dependencies are installed and at minimum versions'
  task :deps do
    require 'minitest/autorun'

    class TestDependencies < Minitest::Test
      def test_postgres_installed
        pgver = Gem::Version.new(`postgres --version`.split.last)
        valid = pgver >= Gem::Version.new('9.2')
        assert(valid, 'Postgres 9.2.x and higher is required.')
      end

      def test_postgres_running
        running = system('pgrep -q postgres')
        assert(running, 'Postgres does not appear to be running.')
      end

      def test_redis_installed
        rsver = Gem::Version.new(`redis-server --version`.match(/=(\d\.\d.\d)/)[1])
        valid = rsver >= Gem::Version.new('2.4')
        assert(valid, 'Redis Server 2.4.x and higher is required.')
      end

      def test_redis_running
        running = system('pgrep -q redis-server')
        assert(running, 'Redis Server does not appear to be running.')
      end

      def test_phantomjs_installed
        pjver = Gem::Version.new(`phantomjs --version`.split.last)
        valid = pjver == Gem::Version.new('1.8.2')
        assert(valid, 'PhantomJS 1.8.2 is required.')
      end
    end
  end
end
