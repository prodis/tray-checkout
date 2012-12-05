# encoding: UTF-8

module Tray
  module Checkout
    PAYMENT_METHOD = {
      diners: 2,
      visa: 3,
      mastercard: 4,
      american_express: 5,
      boleto: 6,
      itau_shopline: 7,
      pagamento_com_saldo: 8,
      peela: 14,
      discover: 15,
      elo: 16
    }

    TRANSACTION_STATUS = {
      waiting_payment: 4,
      processing: 5,
      approved: 6,
      canceled: 7,
      disputing: 24,
      monitoring: 87,
      recovering: 88,
      disapproved: 89
    }

    CONTACT_TYPE = {
      home: "H",
      mobile: "M",
      work: "W"
    }

    ADDRESS_TYPE = {
      billing: "B",
      delivery: "D"
    }

    SEX = {
      male: "M",
      female: "F"
    }

    MARITAL_STATUS = {
      single: "S",
      married: "M",
      separated: "A",
      divorced: "D",
      widowed: "W"
    }
  end
end
