class ApplicationController < ActionController::API
  # attr_reader :current_user

  def health
    render json: { status: 'OK', timestamp: Time.current.to_i }
  end

  private
end