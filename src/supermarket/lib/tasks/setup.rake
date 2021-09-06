namespace :setup do
  desc "Test all dependencies are installed and at minimum versions"
  task :deps do
    require "minitest/autorun"

    class TestDependencies < Minitest::Test
      def test_postgres_installed
        pgver = Gem::Version.new(`postgres --version`.split.last)
        valid = pgver >= Gem::Version.new("9.2")
        assert(valid, "Postgres 9.2.x and higher is required.")
      end

      def test_postgres_running
        running = system("pgrep -q postgres")
        assert(running, "Postgres does not appear to be running.")
      end

      def test_redis_installed
        rsver = Gem::Version.new(`redis-server --version`.match(/=(\d\.\d.\d)/)[1])
        valid = rsver >= Gem::Version.new("2.4")
        assert(valid, "Redis Server 2.4.x and higher is required.")
      end

      def test_redis_running
        running = system("pgrep -q redis-server")
        assert(running, "Redis Server does not appear to be running.")
      end

      def test_phantomjs_installed
        pjver = Gem::Version.new(`phantomjs --version`.split.last)
        valid = pjver == Gem::Version.new("1.8.2")
        assert(valid, "PhantomJS 1.8.2 is required.")
      end
    end
  end

  desc "spin up docker containers running dependency services"
  task :docker do
    raise "FATAL: Cannot contact running docker services." unless system("docker info")

    system("docker run \
      --detach=true \
      --env POSTGRES_USER=#{ENV["USER"]}  \
      --publish 5432:5432 \
      --name supermarket-pg \
      postgres:13.3")
    system("docker run \
      --detach=true \
      --publish 6379:6379 \
      --name supermarket-redis \
      redis:3.0")
    puts "You'll need to set POSTGRES_IP and REDIS_URL in your environment."
    puts "* POSTGRES_IP should be the IP of the Docker host running the containers."
    puts "* REDIS_URL should be in the form of redis://DOCKER_HOST_IP:6379/0/supermarket"
  end
end
