class Task < ActiveRecord::Base

  scope :not_empty, joins(:ontologies).group('tasks.id')

  has_and_belongs_to_many :ontologies

  attr_accessible :name, :description

  validates :name,
    presence: true,
    uniqueness: true,
    length: { within: 0..50 }

  def to_s
    name
  end

  def name_with_ontology_count
    "#{self} (#{self.ontologies.count})"
  end
end
