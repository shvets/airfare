module Retry

  def retry_on_timeout method_name, tries_count
    original_method = :"#{method_name}_no_retry"
    alias_method original_method, method_name

    define_method method_name do |*args|
      begin
        send original_method, *args
      rescue Timeout::Error

        instance_eval "@retry_#{method_name} ||= 0"
        if instance_eval("@retry_#{method_name}")  < tries_count
          instance_eval "@retry_#{method_name} += 1"
          retry
        else
          raise
        end
      end

    end
  end
end