module Chargify
  class Migration < Base
    self.prefix = "/subscriptions/:subscription_id/"
  
    def subscription
      self.attributes["id"].present? ? Chargify::Subscription.new(self.attributes) : nil
    end

    def load_remote_errors(remote_errors, save_cache = false)
      case self.class.format
      when ActiveResource::Formats[:xml]
        errors.add :base, Hash.from_xml(remote_errors.response.body)["errors"]
      when ActiveResource::Formats[:json]
        errors.add :base, MultiJson.load(remote_errors.response.body)["errors"]
      end
    end

    class Preview < Base
      self.prefix = "/subscriptions/:subscription_id/migrations/"
      
      def create
        response = post :preview, {}, attributes.to_xml(:root => :migration, :dasherize => false)
        self.attributes = Chargify::Migration::Preview.new.from_xml(response.body).attributes
      end

      private

      def custom_method_new_element_url(method_name, options = {})
        "#{self.class.prefix(prefix_options)}#{method_name}.#{self.class.format.extension}#{self.class.__send__(:query_string, options)}"
      end
    end
  end
end
