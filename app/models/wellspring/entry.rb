module Wellspring
  class Entry < ActiveRecord::Base
    include Wellspring::Concerns::Searchable

    scope :published, -> { where('published_at <= ?', Time.zone.now) }
    scope :any_tags, -> (tags){ where('tags && ARRAY[?]', tags) }

    validates :title, presence: true
    validates :slug, uniqueness: { scope: :type, allow_blank: true }

    before_save :create_slug

    def to_param
      "#{id}-#{slug}"
    end

    def create_slug
      self.slug = self.title.parameterize
    end

    def self.content_attr(attr_name, attr_type = :string)
      content_attributes[attr_name] = attr_type

      define_method(attr_name) do
        self.payload ||= {}
        self.payload[attr_name.to_s]
      end

      define_method("#{attr_name}=".to_sym) do |value|
        self.payload ||= {}
        self.payload[attr_name.to_s] = value
      end
    end

    def self.content_attributes
      @content_attributes ||= {}
    end
  end
end
