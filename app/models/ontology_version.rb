class OntologyVersion < ActiveRecord::Base
  
  include OntologyVersion::Parsing

  belongs_to :user
  belongs_to :ontology

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :source_uri

  validates_format_of :source_uri,
    :with => URI::regexp(%w(http https file gopher)),
    :if => :source_uri?

  validate :validates_file_or_source_uri

  validate :validates_size_of_raw_file, :if => :raw_file?


protected

  def validates_file_or_source_uri
    if source_uri? and raw_file?
      errors.add :source_uri, 'Specify source URI OR file.'
    end
  end

  def validates_size_of_raw_file
    if raw_file.size > 10.megabytes.to_i
      errors.add :raw_file, 'Maximum upload size is 10M.'
    end
  end


end
