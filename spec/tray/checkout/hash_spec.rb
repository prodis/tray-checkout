# encoding: UTF-8
require 'spec_helper'

describe Hash do
  describe "#symbolize_all_keys" do
    it "symbolize keys" do
      hash = { "text" => "Um texto", "number" => 456 }
      hash.symbolize_all_keys.should == { text: "Um texto", number: 456 }
    end

    context "when hash has nested hashes" do
      it "symbolize keys in nested hashes too" do
        hash = { 
          "customer" => { 
            "name" => "Pedro Bonamides",
            "email" => "pedro@bo.com.br", 
            "address" => {
              "street" => "Avenida Pedro Álvares Cabral", 
              "number" => "123", 
              "city" => "São Paulo", 
              "state" => "SP", 
              "postal_code" => "04094050", 
            }, 
          }
        }
        hash.symbolize_all_keys.should == {
          customer: { 
            name: "Pedro Bonamides",
            email: "pedro@bo.com.br", 
            address: {
              street: "Avenida Pedro Álvares Cabral", 
              number: "123", 
              city: "São Paulo", 
              state: "SP", 
              postal_code: "04094050", 
            }, 
          }
        }
      end
    end

    context "when hash value is Array with hash elements" do
      it "symbolize keys in array elements too" do
        hash = {
          "error_response" => {
            "errors" => [
              { "code" => 3042, "message" => "Transação não encontrada" },
              { "code" => 9999, "message" => "Qualquer outra mensagem" }
            ],
            "numbers" => [0, 1, 2, 3, 4, 5],
            "texts" => ["Akira", "Fernando", "José"]
          }
        }
        hash.symbolize_all_keys.should == {
          error_response: {
            errors: [
              { code: 3042, message: "Transação não encontrada" },
              { code: 9999, message: "Qualquer outra mensagem" }
            ],
            numbers: [0, 1, 2, 3, 4, 5],
            texts: ["Akira", "Fernando", "José"]
          }
        }
      end
    end
  end
end
