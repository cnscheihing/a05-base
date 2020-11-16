require_relative 'spec_helper'
require_relative '../app/dcc_burger'
require_relative '../app/models/custom_burger'

describe DCCBurger do
  let(:bread_type) { find_bread_type_by_name('brioche') }
  let(:ingredients) { [find_ingredient_by_name('tomate')] }
  let(:dcc_burger) { DCCBurger.new }

  describe 'custom burger' do
    let(:order_type) { 'custom' }

    it 'buys non-veggie custom burger' do
      test_burger = CustomBurger.new(bread_type, ingredients, false)
      expect(dcc_burger.order!(order_type, test_burger, 3000)).to equal(true)
    end

    it 'buys veggie custom burger' do
      test_burger = CustomBurger.new(bread_type, ingredients, true)
      expect(dcc_burger.order!(order_type, test_burger, 3000)).to equal(true)
    end

    it 'correct price for veggie custom burger' do
      test_burger = CustomBurger.new(bread_type, ingredients, true)
      dcc_burger.custom_burger_price(test_burger)
      expect(test_burger.price).to equal(2840)
    end
  end

  describe 'original burger' do
    let(:order_type) { 'original' }

    it 'buys burger' do
      test_burger = find_original_burger_by_name('Big DCC')
      expect(dcc_burger.order!(order_type, test_burger, 6000)).to equal(true)
    end
  end

  describe 'validations' do
    it 'is invalid if not valid type' do
      expect { dcc_burger.order!('noop', nil, 0) }
        .to raise_error(StandardError)
    end

    it 'is invalid if not enough money' do
      test_burger = find_original_burger_by_name('Big DCC')
      expect { dcc_burger.order!('original', test_burger, 0) }
        .to raise_error(StandardError)
    end

    it 'is invalid if non existing original burger' do
      invalid_test_burger = OriginalBurger.new('noop', 0)
      expect { dcc_burger.order!('original', invalid_test_burger, 10_000) }
        .to raise_error(StandardError)
    end

    it 'is invalid if non-existing ingredients' do
      invalid_test_burger = CustomBurger.new(bread_type, [Ingredient.new('noop', 'veggie', 0)], false)
      expect { dcc_burger.order!('custom', invalid_test_burger, 10_000) }
        .to raise_error(StandardError)
    end

    it 'is invalid if non-existing bread type' do
      invalid_test_burger = CustomBurger.new(BreadType.new('noop', 0), ingredients, false)
      expect { dcc_burger.order!('custom', invalid_test_burger, 10_000) }
        .to raise_error(StandardError)
    end

    it 'is invalid if non veggie ingredient on veggie burger' do
      invalid_test_burger = CustomBurger.new(bread_type, [find_ingredient_by_name('tocino')], true)
      expect { dcc_burger.order!('custom', invalid_test_burger, 10_000) }
        .to raise_error(StandardError)
    end
  end
end
