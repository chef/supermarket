if Rails.env.test?
  SegmentIO = Supermarket::SegmentIoAgent.new(ENV)
end
