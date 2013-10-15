class CommentsController < PolymorphicResource::Base
  belongs_to :ontology, :polymorphic => true

  before_filter :content_kind

  protected

  def content_kind
    @content_kind = :ontologies
  end

end
