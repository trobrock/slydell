require "slydell/version"

module Slydell
  module ClassMethods
    def track_utilization(method)
      class_eval <<-RB
        alias_method :#{method}_without_tracking, :#{method}

        def #{method}(*args)
          track_utilization do
            #{method}_without_tracking *args
          end
        end
      RB
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  private

  def track_utilization
    reset_window! if @__utilization_tracker.nil? || should_reset_window?
    start_processing = Time.now

    result = with_sleep_tracking { yield }

    stop_processing = Time.now

    time_to_process = stop_processing - start_processing
    time_idle       = start_processing - @__utilization_tracker["last_process_finished"]

    @__utilization_tracker["idle_time"]       += (time_idle + sleep_time)
    @__utilization_tracker["processing_time"] += (time_to_process - sleep_time)
    @__utilization_tracker["processed_jobs"]  += 1
    @__utilization_tracker["last_process_finished"] = stop_processing
    reset_sleep_time!

    StatsTracker.gauge("workling.utilization", utilization)

    result
  end

  def with_sleep_tracking
    Kernel.class_eval <<-RB
      def sleep_with_tracking(duration=nil)
        start = Time.now
        res = sleep_without_tracking duration
        stop = Time.now
        Thread.current["Slydell::sleep"] ||= 0
        Thread.current["Slydell::sleep"] += (stop - start)
        res
      end

      alias_method :sleep_without_tracking, :sleep
      alias_method :sleep, :sleep_with_tracking
    RB

    yield
  ensure
    Kernel.class_eval <<-RB
      alias_method :sleep_with_tracking, :sleep
      alias_method :sleep, :sleep_without_tracking
    RB
  end

  def sleep_time
    Thread.current["Slydell::sleep"]
  end

  def reset_sleep_time!
    Thread.current["Slydell::sleep"] = 0
  end

  def should_reset_window?
    (Time.now - @__utilization_tracker["window_start"]) > 5*60 # 5 minutes
  end

  def utilization
    @__utilization_tracker["processing_time"] /
      (@__utilization_tracker["processing_time"] +
       @__utilization_tracker["idle_time"])
  end

  def reset_window!
    @__utilization_tracker ||= {}
    @__utilization_tracker["window_start"]          = Time.now
    @__utilization_tracker["last_process_finished"] = @__utilization_tracker["window_start"]
    @__utilization_tracker["processed_jobs"]        = 0
    @__utilization_tracker["idle_time"]             = 0
    @__utilization_tracker["processing_time"]       = 0
    reset_sleep_time!
  end
end
