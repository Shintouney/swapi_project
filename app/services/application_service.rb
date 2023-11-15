require 'dry-initializer'
require 'dry-initializer-rails'

class ApplicationService
  extend Dry::Initializer
  Result = Struct.new(:success?, :data, :errors)

  def self.call(**args)
    new(**args).call
  end

  private

  def errors
    @errors ||= []
  end

  def success(data = nil)
    Result.new(true, data, nil)
  end

  def failure(errors = [], data: nil)
    Result.new(false, data, errors)
  end
end
