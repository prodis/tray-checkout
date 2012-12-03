# encoding: UTF-8
class Hash
  def symbolize_all_keys!
    symbolize_all_keys_in self
  end

  private

  def symbolize_all_keys_in(hash)
    case
    when hash.is_a?(Array)
      hash.each { |value| symbolize_all_keys_in(value) }
    when hash.is_a?(Hash)
      hash.symbolize_keys!

      hash.each_value do |value|
        value.symbolize_keys! if value.is_a?(Hash)
        symbolize_all_keys_in(value)
      end
    end
  end
end
