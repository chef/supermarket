require "spec_helper"

RSpec.describe Supermarket::HoneySampler do
  let(:trace_id) { "TRACE_ID" }

  context "without a noisy command" do
    it "does not sample" do
      result = described_class.sample({ "request.path" => "/me", "trace.trace_id" => trace_id })
      expect(result).to eq([true, 1])
    end
  end

  context "with a redis command" do
    it "samples if its in NOISY_REDIS_COMMANDS" do
      is_sampled, rate = described_class.sample({ "redis.command" => "TIME", "trace.trace_id" => trace_id })
      expect(is_sampled).to be_in [true, false]
      expect(rate).to match(300)
    end

    it "samples if the command is BRPOP" do
      is_sampled, rate = described_class.sample({ "redis.command" => "BRPOP", "trace.trace_id" => trace_id })
      expect(is_sampled).to be_in [true, false]
      expect(rate).to match(5000)
    end

    it "samples if the command starts with TTL" do
      is_sampled, rate = described_class.sample({ "redis.command" => "TTL this and that",
                                                  "trace.trace_id" => trace_id })
      expect(is_sampled).to be_in [true, false]
      expect(rate).to match(300)
    end

    it "samples if the command starts with GET rack:" do
      is_sampled, rate = described_class.sample({ "redis.command" => "GET rack::something",
                                                  "trace.trace_id" => trace_id })
      expect(is_sampled).to be_in [true, false]
      expect(rate).to match(300)
    end

    it "samples if the command starts with SET rack:" do
      is_sampled, rate = described_class.sample({ "redis.command" => "SET rack::something",
                                                  "trace.trace_id" => trace_id })
      expect(is_sampled).to be_in [true, false]
      expect(rate).to match(300)
    end
  end

  context "with a active_record SQL command" do
    it "samples if its in NOISY_SQL_COMMANDS" do
      is_sampled, rate = described_class.sample({ "sql.active_record.sql" => "COMMIT", "trace.trace_id" => trace_id })
      expect(is_sampled).to be_in [true, false]
      expect(rate).to match(300)
    end
  end

  context "with a health check from load balancers" do
    let(:trace) {
      {
        "request.header.user_agent" => "ELB-HealthChecker/1.0",
        "trace.trace_id" => trace_id,
      }
    }

    it "samples if check is successful" do
      is_sampled, rate = described_class.sample(trace.merge({ "response.status_code" => 200 }))
      expect(is_sampled).to be_in [true, false]
      expect(rate).to match(300)
    end

    it "does not sample if check is unsuccessful" do
      result = described_class.sample(trace.merge({ "response.status_code" => 500 }))
      expect(result).to eq([true, 1])
    end
  end
end
