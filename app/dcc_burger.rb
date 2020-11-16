require 'set'
require_relative 'constants/ingredients'
require_relative 'constants/bread_types'
require_relative 'constants/original_burgers'

class DCCBurger
  def order!(type, choice, wallet_money)
    validate_type! type

    if type == 'custom'
      validate_ingredients! choice
      validate_bread_type! choice
      validate_veggie! choice

      custom_burger_price choice
    elsif type == 'original'
      validate_availability! choice
    end

    validate_price! choice, wallet_money
    true
  end

  def custom_burger_price(burger)
    price = 1290

    price -= 50 if burger.veggie
    price += burger.bread_type.price

    burger.ingredients.each do |ingredient|
      price += ingredient.price
    end

    burger.price = price
  end

  private

  def raise_error(message)
    raise StandardError, message
  end

  def validate_type!(type)
    return if %w[original custom].include? type

    raise_error 'Tipo de hamburguesa inválido, puede sólo ser: original, custom'
  end

  def validate_price!(burger, available_money)
    return if burger.price <= available_money

    raise_error 'No tienes suficiente dinero para comprar este producto'
  end

  def validate_availability!(burger)
    return if ORIGINAL_BURGERS.include? burger

    raise_error "Hamburguesa no disponible, puede sólo ser: #{ORIGINAL_BURGERS.map(&:name).join ', '}"
  end

  def validate_ingredients!(custom_burger)
    custom_burger.ingredients.each do |ingredient|
      unless INGREDIENTS.include?(ingredient)
        raise_error "Ingrediente inválido, puede sólo ser: #{INGREDIENTS.map(&:name).join ', '}"
      end
    end
  end

  def validate_bread_type!(custom_burger)
    return if BREAD_TYPES.include?(custom_burger.bread_type)

    raise_error "Pan inválido, puede sólo ser: #{BREAD_TYPES.map(&:name).join ', '}"
  end

  def validate_veggie!(custom_burger)
    return unless custom_burger.veggie

    custom_burger.ingredients.each do |ingredient|
      # if ingredient.type == 'non-veggie'
      if ingredient.type.eql?("non-veggie")
        raise_error 'Quieres una hamburguesa veggie pero tiene un ingrediente no veggie'
      end
    end
  end
end
