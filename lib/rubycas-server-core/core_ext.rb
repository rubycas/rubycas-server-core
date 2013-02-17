class Hash
  # take keys of hash and transform those to a symbols
  def self.symbolize_keys(value)
    value.map!{|el| Hash.symbolize_keys(el)} if value.is_a?(Array)
    return value if not value.is_a?(Hash)
    hash = value.inject({}){|memo,(k,v)| memo[k.to_sym] =
      Hash.symbolize_keys(v); memo}
    return hash
  end

end
