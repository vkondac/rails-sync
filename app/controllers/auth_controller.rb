class AuthController < ApplicationController
  skip_before_action :authenticate_request

  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = user.generate_jwt
      render json: {
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        }
      }
    else
      render json: { error: 'Invalid credentials' }, status: 401
    end
  end
end