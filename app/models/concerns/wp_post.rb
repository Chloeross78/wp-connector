module WpPost
  extend ActiveSupport::Concern

  included do
    serialize :acf_fields
  end

  # TODO (cies): rename to update_wp_post_attributes
  def update_post(json)
    self.class.mappable_wordpress_attributes.each do |wp_attribute|
      send("#{wp_attribute}=", json[wp_attribute])
    end

    self.wp_id        = json['ID']
    # Use gmt date to ignore timezone settings in WordPress
    self.published_at = json['date_gmt']
    self.order        = json['menu_order']

    # active record serialize explodes if the array is empty.
    if json['acf_fields'].blank?
      self.acf_fields = nil
    else
      self.acf_fields = json['acf_fields']
    end

    save!
  end

  module ClassMethods
    # TODO (cies): refactor to constant WpPost::MAPPABLE_ATTRS
    def mappable_wordpress_attributes
      %w( slug title status content excerpt )
    end

    def wp_type
      self.to_s.demodulize.underscore.pluralize
    end
  end
end
