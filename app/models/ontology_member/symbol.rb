# This model is namespaced in the module OntologyMember because the class
# Symbol is already taken by ruby.
module OntologyMember
  class Symbol < ActiveRecord::Base
    include Metadatable
    include Symbol::Searching
    include Symbol::Readability

    belongs_to :ontology
    belongs_to :symbol_group
    has_and_belongs_to_many :sentences
    has_and_belongs_to_many :oops_responses

    attr_accessible :label, :comment

    scope :kind, ->(kind) { where kind:  kind }


    def self.groups_by_kind
      groups = select('kind, count(*) AS count').group(:kind).
        order('count DESC, kind').all
      groups << Struct.new(:kind, :count).new('Symbol', 0) if groups.empty?
      groups
    end

    def to_s
      display_name || name
    end
  end
end