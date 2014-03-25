if Rails.env.test?
  SegmentIO = Supermarket::SegmentIoAgent.new(Supermarket::Config)
end
