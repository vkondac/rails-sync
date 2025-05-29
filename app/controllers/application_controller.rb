class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

  def health
    render json: { status: 'OK', timestamp: Time.current.to_i }
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    if header
      @current_user = User.decode_jwt(header)
      render json: { error: 'Unauthorized' }, status: 401 unless @current_user
    else
      render json: { error: 'Missing token' }, status: 401
    end
  end

  def skip_authentication
    # Helper method to skip auth for specific actions
  end
end