# encoding: UTF-8
class Hash
  def symbolize_all_keys
    {}.tap do |results|
      self.each do |key, value|
        if value.is_a?(Array)
          symbolized_value = value.map { |item| item.is_a?(Hash) ? item.symbolize_all_keys : item }
        else
          symbolized_value = value.is_a?(Hash) ? value.symbolize_all_keys : value
        end

        results[(key.to_sym rescue key)] = symbolized_value
      end
    end
  end
end
