class HideRestrictedFieldsTransformer < Blueprinter::Transformer
  def transform(hash, object, options)
    policy = Pundit.policy(options[:current_user], object)
    policy.restricted_attributes.each do |attr|
      hash[attr] = nil
    end
  end
end
