# encoding: UTF-8
class String
  unless method_defined?(:blank?)
    puts 'NOT DEFINED'
    #def blank?
      #/\A[[:space:]]*\z/ === self
    #end
  else
    puts 'DEFINED'
  end
end
