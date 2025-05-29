class CarsController < ApplicationController
  before_action :set_car, only: [:show, :update, :destroy]

  def index
    @cars = Car.all.order(created_at: :desc)
    render json: @cars
  end

  def show
    render json: @car
  end

  def create
    @car = Car.new(car_params)
    @car.id = generate_watermelon_id unless @car.id.present?

    if @car.save
      render json: @car, status: :created
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @car.update(car_params)
      render json: @car
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @car.destroy
    head :no_content
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def car_params
    params.require(:car).permit(:id, :make, :model, :year, :color, :price, :mileage)
  end

  def generate_watermelon_id
    "car_#{Time.current.to_i}_#{SecureRandom.hex(4)}"
  end
end